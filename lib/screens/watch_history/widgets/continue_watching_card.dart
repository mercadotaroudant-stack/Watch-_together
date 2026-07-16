import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.historyCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.historyBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.historyGradientStart, AppColors.historyGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.history_rounded, color: AppColors.white, size: 38),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.historyContinueWatchingTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.historyPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.historyContinueWatchingSubtitle,
                      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.historySecondaryText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 28, color: AppColors.historyBrightPurple),
            ],
          ),
        ),
      ),
    );
  }
}
