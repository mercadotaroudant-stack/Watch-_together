import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';

/// Monthly/Yearly toggle. [yearlySavingsPercent], when non-null, is the
/// *real* saving computed from actual Play prices (12x monthly vs the
/// yearly price) — never a hardcoded "Save 20%". The badge is hidden
/// entirely until a real number is available.
class BillingPeriodSelector extends StatelessWidget {
  const BillingPeriodSelector({
    required this.selected,
    required this.onChanged,
    required this.yearlySavingsPercent,
    super.key,
  });

  final PremiumPlan selected;
  final ValueChanged<PremiumPlan> onChanged;
  final int? yearlySavingsPercent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.premiumBillingTrackBackground,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.premiumBillingTrackBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: l10n.premiumBillingMonthly,
              selected: selected == PremiumPlan.monthly,
              onTap: () => onChanged(PremiumPlan.monthly),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: l10n.premiumBillingYearly,
              selected: selected == PremiumPlan.yearly,
              onTap: () => onChanged(PremiumPlan.yearly),
              trailing: yearlySavingsPercent == null
                  ? null
                  : _SaveBadge(
                      text: l10n.premiumYearlySaveBadge(yearlySavingsPercent!),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.premiumPrimaryPurple, AppColors.premiumGradientEnd],
                )
              : null,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.premiumSecondaryText,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SaveBadge extends StatelessWidget {
  const _SaveBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.premiumMaxAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.premiumMaxBadgeText,
        ),
      ),
    );
  }
}
