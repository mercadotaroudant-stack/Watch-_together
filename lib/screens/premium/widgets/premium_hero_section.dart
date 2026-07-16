import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The "Upgrade your watch together experience" hero block, with a
/// glowing purple crown illustration built from [Icons.workspace_premium_rounded]
/// (matching the crown icon already used for premium elsewhere in the
/// app, e.g. `RoomDetailsScreen`'s host badge) rather than a new image
/// asset.
class PremiumHeroSection extends StatelessWidget {
  const PremiumHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.premiumHeroTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.premiumHeroSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.premiumSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.premiumPrimaryPurple.withOpacity(0.35),
                        AppColors.premiumPrimaryPurple.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 68,
                  color: AppColors.premiumAccentPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
