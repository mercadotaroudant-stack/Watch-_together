import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/enums.dart';
import '../../../models/premium_model.dart';
import '../premium_plan_content.dart';
import 'premium_plan_card.dart';

/// Horizontal, single-card-at-a-time carousel for the three plans.
///
/// Uses `PageView.builder` (never a `Row` of three cards, per spec) with
/// `viewportFraction: 0.88` so the neighboring cards peek in at the
/// edges, and animates each card's scale (1.0 active / 0.94 inactive)
/// off the live page-scroll offset rather than only on settle, so the
/// scaling tracks the finger during the swipe itself.
class PlanCarousel extends StatefulWidget {
  const PlanCarousel({
    required this.plans,
    required this.billingPeriod,
    required this.onPageChanged,
    required this.currentPremium,
    super.key,
  });

  final List<PremiumPlanContent> plans;
  final PremiumPlan billingPeriod;
  final ValueChanged<int> onPageChanged;
  final PremiumModel? currentPremium;

  @override
  State<PlanCarousel> createState() => _PlanCarouselState();
}

class _PlanCarouselState extends State<PlanCarousel> {
  late final PageController _controller;
  int _lastReportedPage = 1;

  @override
  void initState() {
    super.initState();
    // Plus (index 1) is the recommended, default-visible plan.
    _controller = PageController(viewportFraction: 0.88, initialPage: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 630,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.plans.length,
        onPageChanged: (index) {
          if (index != _lastReportedPage) {
            _lastReportedPage = index;
            HapticFeedback.lightImpact();
            widget.onPageChanged(index);
          }
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double page = index.toDouble();
              if (_controller.position.haveDimensions) {
                page = _controller.page ?? _controller.initialPage.toDouble();
              }
              final double distance = (page - index).abs().clamp(0.0, 1.0);
              final double scale = 1.0 - (distance * 0.06); // 1.0 -> 0.94
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: PremiumPlanCard(
              content: widget.plans[index],
              billingPeriod: widget.billingPeriod,
              currentPremium: widget.currentPremium,
            ),
          );
        },
      ),
    );
  }
}
