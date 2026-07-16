import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum HistoryItemAction { continueWatching, viewRoomDetails, remove }

class HistoryOptionsSheet extends StatelessWidget {
  const HistoryOptionsSheet({super.key, required this.isUnfinished});

  final bool isUnfinished;

  static Future<HistoryItemAction?> show(BuildContext context, {required bool isUnfinished}) {
    return showModalBottomSheet<HistoryItemAction>(
      context: context,
      backgroundColor: AppColors.historyElevatedCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => HistoryOptionsSheet(isUnfinished: isUnfinished),
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
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.historyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isUnfinished)
              _Tile(
                icon: Icons.play_circle_outline_rounded,
                label: l10n.historyMenuContinueWatching,
                onTap: () => Navigator.of(context).pop(HistoryItemAction.continueWatching),
              ),
            _Tile(
              icon: Icons.meeting_room_outlined,
              label: l10n.historyMenuViewRoomDetails,
              onTap: () => Navigator.of(context).pop(HistoryItemAction.viewRoomDetails),
            ),
            _Tile(
              icon: Icons.delete_outline_rounded,
              label: l10n.historyMenuRemove,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(HistoryItemAction.remove),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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
    final Color color = isDestructive ? AppColors.historyDanger : AppColors.historyPrimaryText;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
