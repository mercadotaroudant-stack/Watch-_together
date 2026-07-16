import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'widgets/splash_logo.dart';
import 'widgets/splash_version_text.dart';

/// The app's entry-point screen (Phase 3.1): a staged fade/scale intro,
/// then — after exactly [AppConstants.splashNavigationDelay] — a
/// one-time navigation to [RouteNames.onboarding].
///
/// Deliberately does nothing else: no Firebase reads, no auth checks, no
/// backend calls. Once onboarding/auth exist, *this* is the file that
/// gains a real decision about where to navigate — the delay and
/// destination are both isolated in [_SplashTiming] and [RouteNames]
/// respectively so that change touches as little as possible.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// Animation timing, kept local to this screen since none of these
/// exact durations are reused elsewhere (unlike `AppConstants`'s
/// general-purpose `animationFast/Medium/Slow`).
abstract final class _SplashTiming {
  static const Duration background = Duration(milliseconds: 400);
  static const Duration logo = Duration(milliseconds: 700);
  static const Duration appName = Duration(milliseconds: 400);
  static const Duration tagline = Duration(milliseconds: 400);
  static const Duration loadingIndicator = Duration(milliseconds: 300);

  static final Duration total = logo + appName + tagline + loadingIndicator;
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backgroundFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _appNameFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loadingFade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _SplashTiming.total);

    _backgroundFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0, _fractionOf(_SplashTiming.background), curve: Curves.easeOut),
    );

    final double logoEnd = _fractionOf(_SplashTiming.logo);
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0, logoEnd, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, logoEnd, curve: Curves.easeOutCubic),
      ),
    );

    final double appNameEnd = _fractionOf(_SplashTiming.logo + _SplashTiming.appName);
    _appNameFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(logoEnd, appNameEnd, curve: Curves.easeOut),
    );

    final double taglineEnd =
        _fractionOf(_SplashTiming.logo + _SplashTiming.appName + _SplashTiming.tagline);
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(appNameEnd, taglineEnd, curve: Curves.easeOut),
    );

    _loadingFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(taglineEnd, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    // Deliberately a wall-clock timer, independent of the animation
    // controller above: the spec calls for navigation at exactly 2.5s
    // regardless of how the (currently ~1.8s) intro animation is tuned.
    _navigationTimer = Timer(AppConstants.splashNavigationDelay, _navigateToOnboarding);
  }

  double _fractionOf(Duration elapsed) =>
      elapsed.inMilliseconds / _SplashTiming.total.inMilliseconds;

  void _navigateToOnboarding() {
    if (!mounted) return;
    context.go(RouteNames.onboarding);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _backgroundFade,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.maxContentWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: const SplashLogo(),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceLg),
                          FadeTransition(
                            opacity: _appNameFade,
                            child: Text(
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceSm + 4),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              l10n.splashTagline,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA1A1AA),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXxl),
                          FadeTransition(
                            opacity: _loadingFade,
                            child: Semantics(
                              label: l10n.splashLoadingSemanticLabel,
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: AppConstants.spaceXl,
                child: Center(child: SplashVersionText()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
