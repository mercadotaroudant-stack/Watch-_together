import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum FriendAction {
  viewProfile,
  inviteToRoom,
  voiceCall,
  videoCall,
  removeFriend,
  blockUser,
  reportUser,
}

/// The full 3-dot menu: View Profile, Invite To Room, Remove Friend,
/// Block User, Report User.
class FriendOptionsSheet extends StatelessWidget {
  const FriendOptionsSheet({super.key});

  static Future<FriendAction?> show(BuildContext context) {
    return showModalBottomSheet<FriendAction>(
      context: context,
      backgroundColor: AppColors.friendsCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const FriendOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            _OptionTile(
              icon: Icons.person_outline_rounded,
              label: l10n.participantsMenuViewProfile,
              onTap: () => Navigator.of(context).pop(FriendAction.viewProfile),
            ),
            _OptionTile(
              icon: Icons.video_call_outlined,
              label: l10n.friendsMenuInviteToRoom,
              onTap: () => Navigator.of(context).pop(FriendAction.inviteToRoom),
            ),
            _OptionTile(
              icon: Icons.person_remove_alt_1_rounded,
              label: l10n.friendsMenuRemoveFriend,
              onTap: () => Navigator.of(context).pop(FriendAction.removeFriend),
            ),
            _OptionTile(
              icon: Icons.block_rounded,
              label: l10n.friendsMenuBlockUser,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(FriendAction.blockUser),
            ),
            _OptionTile(
              icon: Icons.flag_rounded,
              label: l10n.friendsMenuReportUser,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(FriendAction.reportUser),
            ),
          ],
        ),
      ),
    );
  }
}

/// The long-press quick-actions sheet: Invite To Room, Voice Call
/// (future), Video Call (future), Remove Friend.
class FriendQuickActionsSheet extends StatelessWidget {
  const FriendQuickActionsSheet({super.key});

  static Future<FriendAction?> show(BuildContext context) {
    return showModalBottomSheet<FriendAction>(
      context: context,
      backgroundColor: AppColors.friendsCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const FriendQuickActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            _OptionTile(
              icon: Icons.video_call_outlined,
              label: l10n.friendsMenuInviteToRoom,
              onTap: () => Navigator.of(context).pop(FriendAction.inviteToRoom),
            ),
            _OptionTile(
              icon: Icons.call_outlined,
              label: l10n.friendsMenuVoiceCall,
              onTap: () => Navigator.of(context).pop(FriendAction.voiceCall),
            ),
            _OptionTile(
              icon: Icons.videocam_outlined,
              label: l10n.friendsMenuVideoCall,
              onTap: () => Navigator.of(context).pop(FriendAction.videoCall),
            ),
            _OptionTile(
              icon: Icons.person_remove_alt_1_rounded,
              label: l10n.friendsMenuRemoveFriend,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(FriendAction.removeFriend),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.friendsBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive ? AppColors.error : AppColors.white;

    return Semantics(
      button: true,
      label: label,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: color),
        ),
      ),
    );
  }
}
