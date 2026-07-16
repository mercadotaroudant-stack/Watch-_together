import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationsMenuAction { markAllAsRead, clearRead }

/// The Notifications app bar's 3-dot menu — only the two actions the
/// real implementation actually supports, per spec ("do not add
/// unsupported fake actions").
class NotificationsMenuSheet extends StatelessWidget {
  const NotificationsMenuSheet({super.key});

  static Future<NotificationsMenuAction?> show(BuildContext context) {
    return showModalBottomSheet<NotificationsMenuAction>(
      context: context,
      backgroundColor: AppColors.notificationsElevatedSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const NotificationsMenuSheet(),
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.homeBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _OptionTile(
              icon: Icons.done_all_rounded,
              label: l10n.notificationsMarkAllAsRead,
              onTap: () => Navigator.of(context).pop(NotificationsMenuAction.markAllAsRead),
            ),
            _OptionTile(
              icon: Icons.delete_sweep_outlined,
              label: l10n.notificationsClearRead,
              onTap: () => Navigator.of(context).pop(NotificationsMenuAction.clearRead),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.homeSecondaryText),
      title: Text(label, style: GoogleFonts.poppins(color: AppColors.white, fontSize: 15)),
    );
  }
}
