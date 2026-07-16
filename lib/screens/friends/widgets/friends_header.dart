import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'friends_animated_entry.dart';

class FriendsHeader extends StatelessWidget {
  const FriendsHeader({
    super.key,
    required this.onSearchTap,
    required this.onNotificationsTap,
    required this.onAddFriendTap,
    this.hasUnreadNotifications = false,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAddFriendTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.drawerFriends,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.friendsScreenSubtitle,
                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.friendsTextGray),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _HeaderIconButton(
          icon: Icons.person_add_alt_1_rounded,
          semanticLabel: l10n.addFriendTitle,
          onTap: onAddFriendTap,
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.search_rounded,
          semanticLabel: l10n.friendsSearchButtonLabel,
          onTap: onSearchTap,
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          semanticLabel: l10n.drawerNotifications,
          showDot: hasUnreadNotifications,
          onTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: FriendsPressableScale(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.friendsCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.friendsBorder),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.white, size: 22),
              ),
              if (showDot)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.friendsPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.friendsBackground, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
