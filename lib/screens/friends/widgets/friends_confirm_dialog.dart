import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

Future<bool> showFriendsConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  bool isDestructive = false,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.friendsCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.friendsBorder),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.white),
      ),
      content: Text(
        message,
        style: GoogleFonts.poppins(color: AppColors.friendsTextGray, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel, style: GoogleFonts.poppins(color: AppColors.friendsTextGray)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isDestructive ? AppColors.error : AppColors.friendsPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
