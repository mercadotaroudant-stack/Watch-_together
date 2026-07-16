import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum RoomOption { share, copyCode, invite, report }

/// The bottom sheet opened by the room details app bar's three-dot menu.
///
/// Returns the selected [RoomOption] via [Navigator.pop] — the caller
/// decides what each option actually does (clipboard copy, share sheet,
/// etc.), keeping this widget purely presentational.
class RoomOptionsBottomSheet extends StatelessWidget {
  const RoomOptionsBottomSheet({super.key});

  static Future<RoomOption?> show(BuildContext context) {
    return showModalBottomSheet<RoomOption>(
      context: context,
      backgroundColor: AppColors.roomCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const RoomOptionsBottomSheet(),
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
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.roomBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _OptionTile(
              icon: Icons.ios_share_rounded,
              label: l10n.shareRoom,
              onTap: () => Navigator.of(context).pop(RoomOption.share),
            ),
            _OptionTile(
              icon: Icons.copy_rounded,
              label: l10n.copyRoomCode,
              onTap: () => Navigator.of(context).pop(RoomOption.copyCode),
            ),
            _OptionTile(
              icon: Icons.person_add_alt_1_rounded,
              label: l10n.inviteFriends,
              onTap: () => Navigator.of(context).pop(RoomOption.invite),
            ),
            _OptionTile(
              icon: Icons.flag_rounded,
              label: l10n.reportRoom,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(RoomOption.report),
            ),
          ],
        ),
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
