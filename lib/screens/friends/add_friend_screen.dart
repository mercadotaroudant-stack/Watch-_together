import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/friends_screen_provider.dart';
import '../../providers/repository_providers.dart';
import 'utils/friend_relationship_status.dart';
import 'widgets/add_friend_result_card.dart';

/// The real "Add Friend" / "Find Friends" screen (previously just a
/// "Coming Soon" snackbar off the Friends screen's empty state).
///
/// Searches actual `users` documents via
/// [UserRepository.searchByDisplayNameLowercasePrefix] — debounced,
/// never on every keystroke, never a full-collection scan. Every
/// result's button state comes from the same live
/// [liveFriendsProvider]/[liveFriendRequestsProvider]/
/// [liveSentRequestsProvider] streams the rest of the Friends feature
/// already uses, so it can never show "Add Friend" for someone you're
/// already friends/pending with.
class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

enum _SearchState { idle, loading, loaded, error }

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  _SearchState _state = _SearchState.idle;
  List<UserModel> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    final String query = raw.trim();

    if (query.isEmpty) {
      setState(() {
        _state = _SearchState.idle;
        _results = const [];
      });
      return;
    }

    setState(() => _state = _SearchState.loading);
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final String? myUid = ref.read(currentUserIdProvider);
    try {
      final results = await ref
          .read(userRepositoryProvider)
          .searchByDisplayNameLowercasePrefix(query.toLowerCase());
      if (!mounted) return;
      // Never show the authenticated user in their own results.
      final filtered = results.where((u) => u.uid != myUid).toList();
      setState(() {
        _results = filtered;
        _state = _SearchState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _SearchState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final Set<String> friendIds =
        (ref.watch(liveFriendsProvider).valueOrNull ?? const []).map((f) => f.user.uid).toSet();
    final Set<String> incomingIds = (ref.watch(liveFriendRequestsProvider).valueOrNull ?? const [])
        .map((r) => r.requester.uid)
        .toSet();
    final Set<String> outgoingIds =
        (ref.watch(liveSentRequestsProvider).valueOrNull ?? const []).map((f) => f.user.uid).toSet();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                  ),
                  Expanded(
                    child: Text(
                      l10n.addFriendTitle,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchField(controller: _controller, onChanged: _onChanged),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(l10n, friendIds, incomingIds, outgoingIds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    Set<String> friendIds,
    Set<String> incomingIds,
    Set<String> outgoingIds,
  ) {
    switch (_state) {
      case _SearchState.idle:
        return _MessageState(icon: Icons.person_search_rounded, message: l10n.addFriendSearchPrompt);
      case _SearchState.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.homePrimary));
      case _SearchState.error:
        return _MessageState(
          icon: Icons.error_outline_rounded,
          message: l10n.addFriendSearchError,
          actionLabel: l10n.retry,
          onAction: () => _runSearch(_controller.text.trim()),
        );
      case _SearchState.loaded:
        if (_results.isEmpty) {
          return _MessageState(icon: Icons.search_off_rounded, message: l10n.addFriendNoResults);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final UserModel user = _results[index];
            final status = friendRelationshipStatusFor(
              uid: user.uid,
              friendIds: friendIds,
              incomingRequesterIds: incomingIds,
              outgoingRecipientIds: outgoingIds,
            );
            return AddFriendResultCard(user: user, status: status);
          },
        );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.white),
        decoration: InputDecoration(
          hintText: l10n.addFriendSearchHint,
          hintStyle: GoogleFonts.poppins(fontSize: 15, color: AppColors.homeMutedText),
          prefixIcon: const Icon(Icons.search_rounded, size: 24, color: AppColors.homeMutedText),
          filled: true,
          fillColor: AppColors.homeCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.homeBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.homeBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.homeBadgePurple, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.homeMutedText),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.homeSecondaryText),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
