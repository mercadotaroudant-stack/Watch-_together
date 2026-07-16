import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/subscription_products.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../providers/premium_providers.dart';
import '../../providers/service_providers.dart';
import 'premium_plan_content.dart';
import 'widgets/billing_period_selector.dart';
import 'widgets/payment_security_section.dart';
import 'widgets/plan_carousel.dart';
import 'widgets/plan_page_indicator.dart';
import 'widgets/premium_app_bar.dart';
import 'widgets/premium_hero_section.dart';
import 'widgets/premium_legal_text.dart';

/// The "Go Premium" screen (Phase 3.11) — see RouteNames.premium.
///
/// Reads real premium status from [premiumStatusProvider] and real
/// Google Play prices from [premiumProductDetailsProvider]; purchases
/// go through [purchaseControllerProvider], which only ever activates
/// premium after Play itself confirms the purchase. See
/// `SubscriptionProductIds` for why prices may currently be blank —
/// the Basic/Plus/Max subscriptions haven't been created in Play
/// Console yet, so this screen honestly shows "not available yet"
/// rather than a fake price.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  PremiumPlan _billingPeriod = PremiumPlan.yearly;
  int _activePlanIndex = 1; // Plus, per spec's default.

  @override
  void initState() {
    super.initState();
    // Re-deliver any already-owned subscription (Android has no separate
    // "Restore Purchases" UI) so an existing subscriber never sees their
    // own plan as unpurchased. No-op if Play Billing/products aren't
    // available yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseServiceProvider).restorePurchases().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<PremiumPlanContent> plans = buildPremiumPlans(l10n);
    final AsyncValue<Map<String, ProductDetails>> productsAsync =
        ref.watch(premiumProductDetailsProvider);
    final currentPremium = ref.watch(premiumStatusProvider).valueOrNull;

    ref.listen<PurchaseState>(purchaseControllerProvider, (previous, next) {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      switch (next.status) {
        case PurchaseFlowStatus.success:
          messenger.showSnackBar(SnackBar(content: Text(l10n.premiumPurchaseSuccess)));
          break;
        case PurchaseFlowStatus.error:
          messenger.showSnackBar(SnackBar(content: Text(l10n.premiumPurchaseError)));
          break;
        case PurchaseFlowStatus.notConfigured:
          messenger.showSnackBar(SnackBar(content: Text(l10n.premiumPlansUnavailableMessage)));
          break;
        case PurchaseFlowStatus.idle:
        case PurchaseFlowStatus.pending:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.premiumBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PremiumAppBar(),
              const SizedBox(height: 12),
              const PremiumHeroSection(),
              const SizedBox(height: 20),
              BillingPeriodSelector(
                selected: _billingPeriod,
                onChanged: (plan) => setState(() => _billingPeriod = plan),
                yearlySavingsPercent: _computeSavingsPercent(
                  productsAsync.valueOrNull,
                  plans[_activePlanIndex].tier,
                ),
              ),
              const SizedBox(height: 20),
              PlanCarousel(
                plans: plans,
                billingPeriod: _billingPeriod,
                onPageChanged: (index) => setState(() => _activePlanIndex = index),
                currentPremium: currentPremium,
              ),
              PlanPageIndicator(pageCount: plans.length, activeIndex: _activePlanIndex),
              const SizedBox(height: 28),
              const PaymentSecuritySection(),
              const SizedBox(height: 24),
              const PremiumLegalText(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// The *real* percentage saved by paying yearly vs. 12x monthly for
  /// [tier], computed from actual Play prices — `null` (badge hidden)
  /// until both prices are actually loaded.
  int? _computeSavingsPercent(Map<String, ProductDetails>? products, PremiumTier tier) {
    if (products == null) return null;
    final ProductDetails? monthly =
        products[SubscriptionProductIds.forPlan(tier, PremiumPlan.monthly)];
    final ProductDetails? yearly =
        products[SubscriptionProductIds.forPlan(tier, PremiumPlan.yearly)];
    if (monthly == null || yearly == null) return null;
    if (monthly.rawPrice <= 0) return null;

    final double yearlyEquivalentOfMonthly = monthly.rawPrice * 12;
    if (yearlyEquivalentOfMonthly <= 0) return null;

    final double savings = 1 - (yearly.rawPrice / yearlyEquivalentOfMonthly);
    final int percent = (savings * 100).round();
    return percent > 0 ? percent : null;
  }
}
