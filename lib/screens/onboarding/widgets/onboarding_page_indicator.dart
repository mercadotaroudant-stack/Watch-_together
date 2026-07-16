import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The three-dot page indicator: inactive dots are small filled circles,
/// the active dot stretches into a pill. Each dot animates its own
/// size/color change (driven by [AnimatedContainer]) rather than the
/// indicator rebuilding wholesale, matching the "animated transition"
/// requirement.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  static const Duration _duration = Duration(milliseconds: 300);
  static const double _dotSize = 8;
  static const double _activeDotWidth = 24;
  static const Color _inactiveColor = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Semantics(
            label: l10n.onboardingPageIndicatorLabel(index + 1, pageCount),
            selected: isActive,
            child: AnimatedContainer(
              duration: _duration,
              curve: Curves.easeInOut,
              width: isActive ? _activeDotWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : _inactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      }),
    );
  }
}
