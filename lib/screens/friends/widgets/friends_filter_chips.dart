import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../friends_filter.dart';
import 'friends_animated_entry.dart';

class FriendsFilterChips extends StatelessWidget {
  final FriendsFilter selected;
  final ValueChanged<FriendsFilter> onSelected;
  final int requestsCount;
  final int sentCount;

  const FriendsFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.requestsCount,
    this.sentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: l10n.friendsChipAllFriends,
            selected: selected == FriendsFilter.all,
            onTap: () => onSelected(FriendsFilter.all),
          ),
          const SizedBox(width: 12),
          _Chip(
            label: l10n.onlineLabel,
            selected: selected == FriendsFilter.online,
            leadingDot: AppColors.friendsOnline,
            onTap: () => onSelected(FriendsFilter.online),
          ),
          const SizedBox(width: 12),
          _Chip(
            label: l10n.friendsChipRequests,
            selected: selected == FriendsFilter.requests,
            badgeCount: requestsCount,
            onTap: () => onSelected(FriendsFilter.requests),
          ),
          const SizedBox(width: 12),
          _Chip(
            label: l10n.friendsChipSent,
            selected: selected == FriendsFilter.sent,
            badgeCount: sentCount,
            onTap: () => onSelected(FriendsFilter.sent),
          ),
          const SizedBox(width: 12),
          _Chip(
            label: l10n.friendsChipBlocked,
            selected: selected == FriendsFilter.blocked,
            onTap: () => onSelected(FriendsFilter.blocked),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.leadingDot,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? leadingDot;

  @override
  Widget build(BuildContext context) {
    return FriendsPressableScale(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.friendsPrimary : AppColors.friendsCard,
          borderRadius: BorderRadius.circular(24),
          border: selected ? null : Border.all(color: AppColors.friendsBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingDot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: leadingDot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.friendsTextGray,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.friendsSecondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount! > 9 ? '9+' : '$badgeCount',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
