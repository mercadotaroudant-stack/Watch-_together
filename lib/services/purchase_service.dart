import 'package:in_app_purchase/in_app_purchase.dart';

/// Thin wrapper around [InAppPurchase] (Google Play Billing on Android).
///
/// Mirrors this project's other `Service` classes — a stateless-ish
/// adapter over a platform SDK, with no business logic (that lives in
/// `PurchaseController`/`PremiumRepository`) and no knowledge of which
/// product ids are configured (that's `SubscriptionProductIds`). Kept
/// this thin so it can be swapped in tests via `ProviderScope`
/// overrides, same as `AuthService`/`FirestoreService`.
class PurchaseService {
  PurchaseService([InAppPurchase? inAppPurchase]) : _iap = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  /// Fires for every purchase state change (pending, purchased,
  /// restored, error, canceled) for the lifetime of the app — this is
  /// the one source of truth for "did a purchase actually go through",
  /// per Play Billing's async purchase model.
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> productIds) {
    return _iap.queryProductDetails(productIds);
  }

  /// Starts a real Play Billing purchase flow for [product]. Returns
  /// `true` once the flow has *started* (the OS purchase sheet was
  /// shown) — the actual result arrives asynchronously via
  /// [purchaseStream], not this Future's return value.
  Future<bool> buySubscription(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Must be called after every purchase update (success *or* error) or
  /// Play will keep redelivering it on every app start.
  Future<void> completePurchase(PurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      return _iap.completePurchase(purchase);
    }
    return Future.value();
  }

  /// Re-delivers any previously-purchased, still-active subscriptions
  /// through [purchaseStream] (as [PurchaseStatus.restored]) — needed
  /// since Android has no separate "restore" UI; call this on app/
  /// Premium-screen start so a user who already owns a plan on this
  /// Google account doesn't see it as unpurchased.
  Future<void> restorePurchases() => _iap.restorePurchases();
}
