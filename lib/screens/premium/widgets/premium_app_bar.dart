import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The Premium screen's top bar: a 44x44 back button plus the "Go
/// Premium" wordmark. Per the reference design the wordmark itself
/// isn't translated (it still reads "Go Premium" in the Arabic mock) —
/// only its layout direction follows the current locale.
class PremiumAppBar extends StatelessWidget {
  const PremiumAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward
                    : Icons.arrow_back,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Go ',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                TextSpan(
                  text: 'Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.premiumAccentPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
