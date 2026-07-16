import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/language_selector/language_selector.dart';
import 'onboarding_page_data.dart';
import 'widgets/onboarding_bottom_bar.dart';
import 'widgets/onboarding_page_content.dart';

/// The three-page onboarding flow shown after the splash screen.
///
/// Pure UI: no Firebase, no auth, no persistence of the
/// `onboarding_completed` flag (see `LocalStorageService.keyOnboardingCompleted`'s
/// doc comment for why that's deliberately deferred). Skip and Get
/// Started both navigate to [RouteNames.authentication] — the real
/// authentication flow built in Phase 3.3.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve _pageTransitionCurve = Curves.easeInOut;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingPageData> _buildPages(AppLocalizations l10n) => [
        OnboardingPageData(
          title: l10n.onboardingPage1Title,
          subtitle: l10n.onboardingPage1Subtitle,
          primaryIcon: Icons.groups_rounded,
          secondaryIcons: const [Icons.play_circle_fill_rounded],
        ),
        OnboardingPageData(
          title: l10n.onboardingPage2Title,
          subtitle: l10n.onboardingPage2Subtitle,
          primaryIcon: Icons.meeting_room_rounded,
          secondaryIcons: const [Icons.lock_rounded],
        ),
        OnboardingPageData(
          title: l10n.onboardingPage3Title,
          subtitle: l10n.onboardingPage3Subtitle,
          primaryIcon: Icons.smart_display_rounded,
          secondaryIcons: const [Icons.chat_bubble_rounded, Icons.mic_rounded],
        ),
      ];

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: _pageTransitionDuration,
      curve: _pageTransitionCurve,
    );
  }

  void _handleSecondaryPressed() {
    if (_currentPage == 0) {
      _navigateToAuthentication();
    } else {
      _goToPage(_currentPage - 1);
    }
  }

  void _handlePrimaryPressed(int pageCount) {
    if (_currentPage == pageCount - 1) {
      _navigateToAuthentication();
    } else {
      _goToPage(_currentPage + 1);
    }
  }

  void _navigateToAuthentication() => context.go(RouteNames.authentication);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<OnboardingPageData> pages = _buildPages(l10n);
    final bool isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXl),
                  child: Center(
                    child: OnboardingPageContent(
                      data: pages[index],
                      isActive: index == _currentPage,
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: LanguageSelector(),
            ),
            Positioned(
              left: AppConstants.spaceXl,
              right: AppConstants.spaceXl,
              bottom: AppConstants.spaceXl,
              child: OnboardingBottomBar(
                pageCount: pages.length,
                currentPage: _currentPage,
                secondaryLabel: _currentPage == 0 ? l10n.skip : l10n.back,
                primaryLabel: isLastPage ? l10n.getStarted : l10n.next,
                onSecondaryPressed: _handleSecondaryPressed,
                onPrimaryPressed: () => _handlePrimaryPressed(pages.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
