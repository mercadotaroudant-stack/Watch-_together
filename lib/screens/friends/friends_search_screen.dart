import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/presence_status.dart';
import '../../providers/friends_screen_provider.dart';
import 'friends_actions.dart';
import 'widgets/friend_avatar.dart';
import 'widgets/friend_options_sheet.dart';

/// The Friends screen's search page — reads the same live streams the
/// main screen does ([liveFriendsProvider]/[liveFriendRequestsProvider]/
/// [liveBlockedUsersProvider]) and filters them client-side as the user
/// types, so results update instantly with every keystroke and stay
/// live if a match's presence/relationship changes while this screen is
/// open.
class FriendsSearchScreen extends ConsumerStatefulWidget {
  const FriendsSearchScreen({super.key});

  @override
  ConsumerState<FriendsSearchScreen> createState() => _FriendsSearchScreenState();
}

class _FriendsSearchScreenState extends ConsumerState<FriendsSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(String name) => name.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final actions = FriendsActions(ref);

    final friendsAsync = ref.watch(liveFriendsProvider);
    final requestsAsync = ref.watch(liveFriendRequestsProvider);
    final blockedAsync = ref.watch(liveBlockedUsersProvider);

    final List<FriendProfile> friends =
        (friendsAsync.valueOrNull ?? const []).where((f) => _matches(f.user.displayName ?? '')).toList();
    final List<FriendRequestDisplay> requests = (requestsAsync.valueOrNull ?? const [])
        .where((r) => _matches(r.requester.displayName ?? ''))
        .toList();
    final List<FriendProfile> blocked =
        (blockedAsync.valueOrNull ?? const []).where((f) => _matches(f.user.displayName ?? '')).toList();

    final bool hasQuery = _query.trim().isNotEmpty;
    final bool hasResults = friends.isNotEmpty || requests.isNotEmpty || blocked.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.friendsBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.friendsCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.friendsBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.friendsTextGray, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: (value) => setState(() => _query = value),
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: l10n.friendsSearchHint,
                                hintStyle:
                                    GoogleFonts.poppins(fontSize: 14, color: AppColors.friendsTextGray),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !hasQuery
                  ? const SizedBox.shrink()
                  : !hasResults
                      ? Center(
                          child: Text(
                            l10n.friendsNoSearchResults,
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.friendsTextGray),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            if (friends.isNotEmpty) ...[
                              _SectionLabel(l10n.friendsAllFriendsSectionTitle),
                              for (final f in friends)
                                _SearchFriendRow(
                                  name: f.user.displayName ?? '—',
                                  photoUrl: f.user.photoUrl,
                                  presence: presenceOf(f.user),
                                  onMenuTap: () async {
                                    final action = await FriendOptionsSheet.show(context);
                                    if (action == null || !context.mounted) return;
                                    switch (action) {
                                      case FriendAction.removeFriend:
                                        await actions.removeFriend(context,
                                            friendId: f.user.uid, friendName: f.user.displayName ?? '');
                                        break;
                                      case FriendAction.blockUser:
                                        await actions.blockUser(context,
                                            userId: f.user.uid, userName: f.user.displayName ?? '');
                                        break;
                                      case FriendAction.reportUser:
                                        await actions.reportUser(context,
                                            userId: f.user.uid, userName: f.user.displayName ?? '');
                                        break;
                                      default:
                                        actions.showComingSoon(context);
                                    }
                                  },
                                ),
                              const SizedBox(height: 16),
                            ],
                            if (requests.isNotEmpty) ...[
                              _SectionLabel(l10n.friendsChipRequests),
                              for (final r in requests)
                                _SearchRequestRow(
                                  name: r.requester.displayName ?? '—',
                                  photoUrl: r.requester.photoUrl,
                                  onAccept: () => actions.acceptRequest(
                                    context,
                                    requesterId: r.requester.uid,
                                    requesterName: r.requester.displayName ?? '',
                                  ),
                                  onReject: () =>
                                      actions.declineRequest(context, requesterId: r.requester.uid),
                                ),
                              const SizedBox(height: 16),
                            ],
                            if (blocked.isNotEmpty) ...[
                              _SectionLabel(l10n.friendsChipBlocked),
                              for (final b in blocked)
                                _SearchBlockedRow(
                                  name: b.user.displayName ?? '—',
                                  photoUrl: b.user.photoUrl,
                                  onUnblock: () => actions.unblockUser(
                                    context,
                                    userId: b.user.uid,
                                    userName: b.user.displayName ?? '',
                                  ),
                                ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.friendsTextGray),
      ),
    );
  }
}

class _SearchFriendRow extends StatelessWidget {
  const _SearchFriendRow({
    required this.name,
    required this.photoUrl,
    required this.presence,
    required this.onMenuTap,
  });

  final String name;
  final String? photoUrl;
  final PresenceStatus presence;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FriendAvatar(name: name, photoUrl: photoUrl, size: 48, presence: presence),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.friendsTextGray),
          ),
        ],
      ),
    );
  }
}

class _SearchRequestRow extends StatelessWidget {
  const _SearchRequestRow({
    required this.name,
    required this.photoUrl,
    required this.onAccept,
    required this.onReject,
  });

  final String name;
  final String? photoUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FriendAvatar(name: name, photoUrl: photoUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
          ),
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.close_rounded, color: AppColors.friendsTextGray),
          ),
          IconButton(
            onPressed: onAccept,
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.friendsPrimary),
          ),
        ],
      ),
    );
  }
}

class _SearchBlockedRow extends StatelessWidget {
  const _SearchBlockedRow({required this.name, required this.photoUrl, required this.onUnblock});

  final String name;
  final String? photoUrl;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FriendAvatar(name: name, photoUrl: photoUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
          ),
          TextButton(
            onPressed: onUnblock,
            child: Text(
              AppLocalizations.of(context)!.friendsMenuUnblockUser,
              style: GoogleFonts.poppins(color: AppColors.friendsPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
