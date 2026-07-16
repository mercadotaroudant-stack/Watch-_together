import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The confirmation dialog shown when tapping "Logout" in [AppDrawer].
///
/// Returns `true` via [Navigator.pop] if the user confirms, `false`/`null`
/// otherwise — the caller (`AppDrawer`) is the one that actually performs
/// the sign-out, so this widget stays a pure yes/no prompt.
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutConfirmDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.logoutDialogTitle,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      content: Text(
        l10n.logoutDialogMessage,
        style: GoogleFonts.poppins(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.cancel,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.logout,
            style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
