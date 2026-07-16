import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The 140×140dp, 24dp-rounded app logo shown on the splash screen, with
/// a very soft purple glow behind it.
///
/// Renders [AssetPaths.appLogo] if present. If that file hasn't been
/// added yet (see `assets/logo/README.md`), falls back to a branded
/// placeholder of the exact same size/shape/shadow rather than letting
/// `Image.asset` throw — so the splash screen still looks intentional
/// during development, before the real artwork is dropped in.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, this.size = 140, this.borderRadius = 24});

  final double size;
  final double borderRadius;

  static const double _glowBlurRadius = 40;
  static const double _glowSpreadRadius = 2;
  static const double _glowOpacity = 0.35;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Semantics(
      image: true,
      label: l10n.splashLogoSemanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_glowOpacity),
              blurRadius: _glowBlurRadius,
              spreadRadius: _glowSpreadRadius,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            AssetPaths.appLogo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _LogoFallback(size: size),
          ),
        ),
      ),
    );
  }
}

/// Branded placeholder used only when `assets/logo/app_logo.png` is
/// missing — matches the real logo's footprint exactly so the layout
/// above/below it doesn't shift once the real file is added.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.white, size: 64),
    );
  }
}
