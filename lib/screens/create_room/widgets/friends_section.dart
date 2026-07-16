import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/friends_provider.dart';
import 'create_room_text_field.dart';

/// Section 3 — search-and-select from the current user's already-accepted
/// friends list (pulled via [friendsWithProfilesProvider]). Nothing here
/// creates friendships; it only picks who gets an invite once the room
/// is created.
class FriendsSection extends ConsumerStatefulWidget {
  const FriendsSection({
    super.key,
    required this.selectedFriendIds,
    required this.onToggle,
  });

  final Set<String> selectedFriendIds;
  final ValueChanged<String> onToggle;

  @override
  ConsumerState<FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends ConsumerState<FriendsSection> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<UserModel>> friendsAsync = ref.watch(friendsWithProfilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateRoomTextField(
          controller: _searchController,
          hintText: l10n.searchFriendsHint,
          prefixIcon: Icons.search_rounded,
          onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 12),
        friendsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.createRoomPrimary),
              ),
            ),
          ),
          error: (error, stackTrace) => Text(
            l10n.noFriendsFoundMessage,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.secondaryText),
          ),
          data: (friends) {
            final List<UserModel> filtered = _query.isEmpty
                ? friends
                : friends
                    .where((f) => (f.displayName ?? '').toLowerCase().contains(_query))
                    .toList();

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.noFriendsFoundMessage,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.secondaryText),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 8;
                const int columns = 3;
                final double tileWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final friend in filtered)
                      SizedBox(
                        width: tileWidth,
                        child: _FriendTile(
                          friend: friend,
                          selected: widget.selectedFriendIds.contains(friend.uid),
                          onTap: () => widget.onToggle(friend.uid),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        if (widget.selectedFriendIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.friendsSelectedCount(widget.selectedFriendIds.length),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.createRoomPrimaryHover,
            ),
          ),
        ],
      ],
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend, required this.selected, required this.onTap});

  final UserModel friend;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name = friend.displayName?.trim().isNotEmpty == true ? friend.displayName! : '—';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.createRoomBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.createRoomPrimary : AppColors.createRoomBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // No external image loading here, matching this
                      // app's current avatar convention (see
                      // HostInfoCard) — an initial-letter avatar stands
                      // in for [friend.photoUrl] until Phase 4 wires
                      // real photo uploads/loading.
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.createRoomPrimary, AppColors.createRoomPrimaryHover],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      if (friend.isOnline)
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.createRoomBackground, width: 2),
                            ),
                          ),
                        ),
                      Positioned(
                        left: -2,
                        top: -2,
                        child: AnimatedScale(
                          scale: selected ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: AppColors.createRoomPrimary,
                            child: Icon(Icons.check_rounded, size: 12, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
