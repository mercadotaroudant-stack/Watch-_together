import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_page_data.dart';
import 'onboarding_illustration.dart';

/// One full onboarding page's content — illustration, title, and
/// subtitle, vertically centered.
///
/// [isActive] drives both the illustration's fade+scale (500ms, see
/// [OnboardingIllustration]) and this widget's own title/subtitle fade
/// (300ms) — both animate whenever this page becomes (or stops being)
/// the current page, rather than only on first build, so swiping
/// back-and-forth replays the entrance every time.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.data,
    required this.isActive,
  });

  final OnboardingPageData data;
  final bool isActive;

  static const Duration _textFadeDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: screenHeight * 0.55,
            width: double.infinity,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                heightFactor: 0.9,
                child: OnboardingIllustration(
                  primaryIcon: data.primaryIcon,
                  secondaryIcons: data.secondaryIcons,
                  semanticLabel: data.title,
                  isActive: isActive,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedOpacity(
            duration: _textFadeDuration,
            opacity: isActive ? 1 : 0,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            duration: _textFadeDuration,
            opacity: isActive ? 1 : 0,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA1A1AA),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
