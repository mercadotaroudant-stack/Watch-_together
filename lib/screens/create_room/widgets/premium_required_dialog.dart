import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// "This feature requires Premium. Upgrade now?" — shown when a
/// non-premium user's Video URL resolves to an M3U8 link.
///
/// Returns `true` if the person tapped Upgrade, `false`/`null`
/// otherwise; the caller decides what Upgrade actually does (navigate
/// to the Premium screen) so this dialog stays a pure yes/no prompt.
class PremiumRequiredDialog {
  static Future<bool?> show(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.createRoomCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.premiumRequiredDialogTitle,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.white),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.premiumRequiredDialogMessage,
          style: GoogleFonts.poppins(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.upgradeNow,
              style: GoogleFonts.poppins(
                color: AppColors.createRoomPrimaryHover,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
