import 'package:flutter/material.dart';

import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/secondary_button.dart';
import 'onboarding_page_indicator.dart';

/// The indicator + button row pinned near the bottom of the onboarding
/// screen. Slides up (with a fade) once when the screen first mounts —
/// not replayed on every page swipe, since only the button *labels*
/// change between pages, and re-sliding the whole bar on every swipe
/// would fight the page's own text/illustration animations rather than
/// complement them.
class OnboardingBottomBar extends StatefulWidget {
  const OnboardingBottomBar({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
  });

  final int pageCount;
  final int currentPage;
  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onPrimaryPressed;

  @override
  State<OnboardingBottomBar> createState() => _OnboardingBottomBarState();
}

class _OnboardingBottomBarState extends State<OnboardingBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  static const Duration _duration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingPageIndicator(pageCount: widget.pageCount, currentPage: widget.currentPage),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryButton(label: widget.secondaryLabel, onPressed: widget.onSecondaryPressed),
                PrimaryButton(label: widget.primaryLabel, onPressed: widget.onPrimaryPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
