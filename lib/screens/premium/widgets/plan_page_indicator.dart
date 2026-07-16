import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class PlanPageIndicator extends StatelessWidget {
  const PlanPageIndicator({required this.pageCount, required this.activeIndex, super.key});

  final int pageCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (index) {
            final bool isActive = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.premiumActiveDot : AppColors.premiumInactiveDot,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.premiumSwipeHint,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.premiumMutedText),
        ),
      ],
    );
  }
}
