import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homePrimary.withOpacity(0.12),
              boxShadow: [
                BoxShadow(color: AppColors.homePrimary.withOpacity(0.18), blurRadius: 40, spreadRadius: 4),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.notifications_none_rounded, size: 72, color: AppColors.homePrimary.withOpacity(0.9)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.notificationsEmptyTitle,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.notificationsEmptyDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.homeSecondaryText),
          ),
        ],
      ),
    );
  }
}
