import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'friend_avatar.dart';
import 'friends_animated_entry.dart';

class FriendRequestCard extends StatelessWidget {
  const FriendRequestCard({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.mutualFriendsCount,
    required this.onAccept,
    required this.onReject,
  });

  final String name;
  final String? photoUrl;
  final int mutualFriendsCount;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.friendsCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.friendsBorder),
      ),
      child: Row(
        children: [
          FriendAvatar(name: name, photoUrl: photoUrl, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.friendsWantsToBeFriend,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.friendsTextGray),
                ),
                if (mutualFriendsCount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.friendsTextGray),
                      const SizedBox(width: 4),
                      Text(
                        l10n.friendsMutualCount(mutualFriendsCount),
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.friendsTextGray),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.close_rounded,
            background: const Color(0xFF1C1C24),
            iconColor: AppColors.white,
            semanticLabel: l10n.friendsRejectRequestSemanticLabel,
            onTap: onReject,
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: Icons.check_rounded,
            background: AppColors.friendsPrimary,
            iconColor: AppColors.white,
            semanticLabel: l10n.friendsAcceptRequestSemanticLabel,
            onTap: onAccept,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: FriendsPressableScale(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}
