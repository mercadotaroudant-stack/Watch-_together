import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/premium_tier_limits.dart';
import '../core/constants/subscription_products.dart';
import '../models/enums.dart';
import '../models/premium_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';
import 'service_providers.dart';

/// Real-time premium status for the signed-in user, straight from
/// Firestore (`PremiumRepository.streamPremiumStatus`) — never a local
/// boolean. `null` while signed out or before a `premium` document
/// exists (i.e. the user has never subscribed).
final StreamProvider<PremiumModel?> premiumStatusProvider = StreamProvider<PremiumModel?>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream<PremiumModel?>.value(null);
  return ref.watch(premiumRepositoryProvider).streamPremiumStatus(uid);
});

/// The real max-participants cap for the signed-in user's room, derived
/// from their actual premium status/tier — 4 for Free, otherwise the
/// real per-tier limit from [PremiumTierLimits]. Never hardcoded per
/// screen; every "how many people can join a room I create" check
/// should read this instead of re-deriving it from `UserModel.isPremium`.
final Provider<int> maxRoomParticipantsProvider = Provider<int>((ref) {
  final PremiumModel? premium = ref.watch(premiumStatusProvider).valueOrNull;
  return PremiumTierLimits.maxParticipantsFor(
    isActive: premium?.isActive ?? false,
    tier: premium?.tier,
  );
});

/// Real Google Play product details (price, currency, title) for every
/// *configured* [SubscriptionProductIds] entry, keyed by product id.
///
/// Returns an empty map — never fake/placeholder prices — when Play
/// Billing is unavailable or no product ids have been configured yet
/// (see `SubscriptionProductIds`'s doc comment). The Premium screen
/// reads this to decide, per card, whether to show a real Play price or
/// a "not available yet" state.
final FutureProvider<Map<String, ProductDetails>> premiumProductDetailsProvider =
    FutureProvider<Map<String, ProductDetails>>((ref) async {
  final Set<String> configuredIds = SubscriptionProductIds.all;
  if (configuredIds.isEmpty) return <String, ProductDetails>{};

  final purchaseService = ref.watch(purchaseServiceProvider);
  if (!await purchaseService.isAvailable()) return <String, ProductDetails>{};

  final ProductDetailsResponse response =
      await purchaseService.queryProductDetails(configuredIds);
  return {for (final ProductDetails product in response.productDetails) product.id: product};
});

enum PurchaseFlowStatus { idle, pending, success, error, notConfigured }

class PurchaseState {
  const PurchaseState({
    this.status = PurchaseFlowStatus.idle,
    this.tier,
    this.plan,
    this.errorMessage,
  });

  final PurchaseFlowStatus status;
  final PremiumTier? tier;
  final PremiumPlan? plan;
  final String? errorMessage;

  bool isPending(PremiumTier forTier) =>
      status == PurchaseFlowStatus.pending && tier == forTier;

  PurchaseState copyWith({
    PurchaseFlowStatus? status,
    PremiumTier? tier,
    PremiumPlan? plan,
    String? errorMessage,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      tier: tier ?? this.tier,
      plan: plan ?? this.plan,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the real purchase flow for the Premium screen's "Choose Plan"
/// buttons: start a Play Billing purchase, wait for
/// `PurchaseService.purchaseStream` to confirm it, then — only once
/// Play has actually reported the purchase as `purchased`/`restored` —
/// write the real activation via `PremiumRepository.activatePremium`.
///
/// No step here ever marks the user premium optimistically. Note this
/// still stops short of *server-side* receipt verification (that needs
/// a backend call to the Play Developer API with the purchase token,
/// which this codebase doesn't have yet) — see the TODO in [_activate].
class PurchaseController extends StateNotifier<PurchaseState> {
  PurchaseController(this._ref) : super(const PurchaseState()) {
    _subscription = _ref.read(purchaseServiceProvider).purchaseStream.listen(
          _onPurchaseUpdates,
          onError: (Object error) {
            state = PurchaseState(
              status: PurchaseFlowStatus.error,
              errorMessage: error.toString(),
            );
          },
        );
  }

  final Ref _ref;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> buy(PremiumTier tier, PremiumPlan plan) async {
    // Prevent double-tapping a plan while one purchase is already in flight.
    if (state.status == PurchaseFlowStatus.pending) return;

    final String productId = SubscriptionProductIds.forPlan(tier, plan);
    if (productId.isEmpty) {
      state = const PurchaseState(status: PurchaseFlowStatus.notConfigured);
      return;
    }

    final Map<String, ProductDetails> products =
        _ref.read(premiumProductDetailsProvider).valueOrNull ?? const {};
    final ProductDetails? product = products[productId];
    if (product == null) {
      state = const PurchaseState(status: PurchaseFlowStatus.notConfigured);
      return;
    }

    state = PurchaseState(status: PurchaseFlowStatus.pending, tier: tier, plan: plan);

    final bool started = await _ref.read(purchaseServiceProvider).buySubscription(product);
    if (!started) {
      state = PurchaseState(
        status: PurchaseFlowStatus.error,
        tier: tier,
        plan: plan,
        errorMessage: 'start_failed',
      );
    }
    // If it did start, the real outcome arrives via _onPurchaseUpdates.
  }

  void dismissError() {
    if (state.status == PurchaseFlowStatus.error ||
        state.status == PurchaseFlowStatus.notConfigured) {
      state = const PurchaseState();
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    final purchaseService = _ref.read(purchaseServiceProvider);
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(status: PurchaseFlowStatus.pending);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _activate(purchase);
          await purchaseService.completePurchase(purchase);
          break;
        case PurchaseStatus.error:
          state = PurchaseState(
            status: PurchaseFlowStatus.error,
            tier: state.tier,
            plan: state.plan,
            errorMessage: purchase.error?.message,
          );
          await purchaseService.completePurchase(purchase);
          break;
        case PurchaseStatus.canceled:
          state = const PurchaseState();
          await purchaseService.completePurchase(purchase);
          break;
      }
    }
  }

  Future<void> _activate(PurchaseDetails purchase) async {
    final String? uid = _ref.read(currentUserIdProvider);
    final (PremiumTier, PremiumPlan)? match = SubscriptionProductIds.parse(purchase.productID);
    if (uid == null || match == null) return;

    final (PremiumTier tier, PremiumPlan plan) = match;

    // TODO(backend): verify purchase.verificationData.serverVerificationData
    // against the Play Developer API from a trusted backend (e.g. a Cloud
    // Function) before/alongside this write, and let that backend set the
    // real `expiresAt`/`autoRenew` from Play's subscription record. This
    // client-only write is enough to unlock features immediately, but a
    // server should be the source of truth once one exists.
    await _ref.read(premiumRepositoryProvider).activatePremium(
          uid: uid,
          tier: tier,
          plan: plan,
          provider: PremiumProvider.googlePlay,
          autoRenew: true,
          transactionId: purchase.purchaseID,
        );

    state = PurchaseState(status: PurchaseFlowStatus.success, tier: tier, plan: plan);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<PurchaseController, PurchaseState> purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, PurchaseState>((ref) => PurchaseController(ref));
