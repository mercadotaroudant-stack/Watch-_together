import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/presence_status.dart';
import 'friend_avatar.dart';
import 'friends_animated_entry.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.presence,
    required this.showDivider,
    required this.onChatTap,
    required this.onMenuTap,
    required this.onLongPress,
  });

  final String name;
  final String? photoUrl;
  final PresenceStatus presence;
  final bool showDivider;
  final VoidCallback onChatTap;
  final VoidCallback onMenuTap;
  final VoidCallback onLongPress;

  String _statusLabel(AppLocalizations l10n) {
    switch (presence) {
      case PresenceStatus.online:
        return l10n.onlineLabel;
      case PresenceStatus.away:
        return l10n.friendsStatusAway;
      case PresenceStatus.offline:
        return l10n.friendsStatusOffline;
    }
  }

  Color _statusColor() {
    switch (presence) {
      case PresenceStatus.online:
        return AppColors.friendsOnline;
      case PresenceStatus.away:
        return AppColors.friendsAway;
      case PresenceStatus.offline:
        return AppColors.friendsOffline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.friendsBorder))
              : null,
        ),
        child: Row(
          children: [
            FriendAvatar(name: name, photoUrl: photoUrl, size: 64, presence: presence),
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel(l10n),
                        style: GoogleFonts.poppins(fontSize: 13, color: _statusColor()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _RoundIconButton(icon: Icons.chat_bubble_outline_rounded, onTap: onChatTap),
            const SizedBox(width: 8),
            _RoundIconButton(icon: Icons.more_vert_rounded, onTap: onMenuTap),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FriendsPressableScale(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: AppColors.friendsTextGray, size: 22),
      ),
    );
  }
}
