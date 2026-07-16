import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Reserves space at the bottom of the screen for a future AdMob
/// banner. Purely a placeholder — no ads SDK is wired in this phase.
class BannerAdPlaceholder extends StatelessWidget {
  const BannerAdPlaceholder({super.key});

  static const double _height = 80;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: _height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.roomCard,
        border: Border(top: BorderSide(color: AppColors.roomBorder)),
      ),
      child: Text(
        l10n.bannerAdPlaceholder,
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.secondaryText),
      ),
    );
  }
}
