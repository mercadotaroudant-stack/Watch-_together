import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A page's illustration: a large rounded gradient panel with a
/// composed icon (a primary icon plus small floating badge icons).
///
/// WatchTogether doesn't have bespoke onboarding artwork yet — this
/// sandbox has no network access to source it (same constraint noted in
/// `assets/logo/README.md` for the app logo). Rather than block Phase
/// 3.2 on that, each page gets a deliberately-designed vector
/// composition in the app's own brand colors, reserved under
/// `assets/illustrations/onboarding_{n}.png` for whenever real artwork
/// is ready — swap it in the same way `SplashLogo` already does for the
/// app logo (`Image.asset` + `errorBuilder` falling back to this).
///
/// Animates in with a fade + scale (0.9 → 1.0) whenever [isActive]
/// becomes true — i.e. whenever this page becomes the current onboarding
/// page — matching the 500ms spec for the illustration entrance.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.primaryIcon,
    required this.semanticLabel,
    this.secondaryIcons = const [],
    this.isActive = true,
  });

  final IconData primaryIcon;
  final List<IconData> secondaryIcons;
  final String semanticLabel;
  final bool isActive;

  static const Duration _duration = Duration(milliseconds: 500);
  static const double _borderRadius = 32;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: AnimatedOpacity(
        duration: _duration,
        curve: Curves.easeOutCubic,
        opacity: isActive ? 1 : 0,
        child: AnimatedScale(
          duration: _duration,
          curve: Curves.easeOutCubic,
          scale: isActive ? 1 : 0.9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double shortestSide =
                  constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.28),
                      AppColors.surface,
                    ],
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      primaryIcon,
                      size: shortestSide * 0.34,
                      color: AppColors.primary,
                    ),
                    for (int i = 0; i < secondaryIcons.length; i++)
                      _SecondaryBadge(
                        icon: secondaryIcons[i],
                        alignment: _badgeAlignment(i, secondaryIcons.length),
                        size: shortestSide * 0.16,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Spreads badge icons around the primary icon rather than stacking
  /// them on top of it.
  static Alignment _badgeAlignment(int index, int total) {
    const positions = [
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ];
    return positions[index % positions.length];
  }
}

class _SecondaryBadge extends StatelessWidget {
  const _SecondaryBadge({required this.icon, required this.alignment, required this.size});

  final IconData icon;
  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: size * 0.55, color: AppColors.white),
        ),
      ),
    );
  }
}
