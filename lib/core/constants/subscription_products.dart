import '../../models/enums.dart';

/// Google Play subscription product IDs for the Premium screen (Phase
/// 3.11).
///
/// **These are intentionally blank.** The Basic/Plus/Max subscriptions
/// have not been created in Google Play Console yet. Every id below
/// must be filled in with the real subscription product id (and, if
/// you use Play's base-plan/offer model rather than one product per
/// period, adjust [forPlan] to select the right base plan id instead)
/// once it exists there — see the Play Console docs on creating a
/// subscription: https://support.google.com/googleplay/android-developer/answer/140504
///
/// Until an id is filled in, [PurchaseService]/the Premium screen treat
/// it as "not configured": that plan is queried from Play, shown with
/// no price, and its purchase button stays disabled. Nothing here is
/// ever a placeholder price or a fake product id — nothing purchasable
/// exists until you put a real id in place.
abstract final class SubscriptionProductIds {
  // --- Basic ---
  /// TODO(play-console): real "basic_monthly" subscription product id.
  static const String basicMonthly = '';

  /// TODO(play-console): real "basic_yearly" subscription product id.
  static const String basicYearly = '';

  // --- Plus ---
  /// TODO(play-console): real "plus_monthly" subscription product id.
  static const String plusMonthly = '';

  /// TODO(play-console): real "plus_yearly" subscription product id.
  static const String plusYearly = '';

  // --- Max ---
  /// TODO(play-console): real "max_monthly" subscription product id.
  static const String maxMonthly = '';

  /// TODO(play-console): real "max_yearly" subscription product id.
  static const String maxYearly = '';

  /// The configured Play product id for a given tier + billing period,
  /// or `''` if that combination hasn't been configured yet.
  static String forPlan(PremiumTier tier, PremiumPlan plan) {
    switch (tier) {
      case PremiumTier.basic:
        return plan == PremiumPlan.yearly ? basicYearly : basicMonthly;
      case PremiumTier.plus:
        return plan == PremiumPlan.yearly ? plusYearly : plusMonthly;
      case PremiumTier.max:
        return plan == PremiumPlan.yearly ? maxYearly : maxMonthly;
    }
  }

  /// Reverse lookup: which (tier, plan) a Play product id belongs to,
  /// or `null` if it doesn't match any configured id (e.g. a stale
  /// purchase from a since-renamed product).
  static (PremiumTier, PremiumPlan)? parse(String productId) {
    for (final tier in PremiumTier.values) {
      for (final plan in [PremiumPlan.monthly, PremiumPlan.yearly]) {
        final id = forPlan(tier, plan);
        if (id.isNotEmpty && id == productId) return (tier, plan);
      }
    }
    return null;
  }

  /// Every configured (non-blank) product id, ready to hand to
  /// `InAppPurchase.queryProductDetails`. Empty until at least one plan
  /// above has a real id.
  static Set<String> get all => {
        basicMonthly,
        basicYearly,
        plusMonthly,
        plusYearly,
        maxMonthly,
        maxYearly,
      }.where((id) => id.isNotEmpty).toSet();
}
