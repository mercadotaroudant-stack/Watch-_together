import '../core/constants/firestore_collections.dart';
import '../models/enums.dart';
import '../models/premium_model.dart';
import '../services/firestore_service.dart';
import '../services/secure_storage_service.dart';

/// Premium subscription status (`premium` collection, one document per
/// user keyed by uid) plus the local cache used for instant UI reads.
class PremiumRepository {
  PremiumRepository({
    required FirestoreService firestoreService,
    required SecureStorageService secureStorageService,
  })  : _firestoreService = firestoreService,
        _secureStorageService = secureStorageService;

  final FirestoreService _firestoreService;
  final SecureStorageService _secureStorageService;

  Future<PremiumModel?> getPremiumStatus(String uid) async {
    final data = await _firestoreService.getDocument(FirestoreCollections.premium, uid);
    final model = data == null ? null : PremiumModel.fromMap(uid, data);
    await _secureStorageService.cachePremiumStatus(model?.isActive ?? false);
    return model;
  }

  /// Instant, non-authoritative read for optimistic UI — always confirm
  /// with [getPremiumStatus] or [streamPremiumStatus] before gating a
  /// purchase-only action.
  Future<bool> getCachedIsPremium() async =>
      await _secureStorageService.readCachedPremiumStatus() ?? false;

  Stream<PremiumModel?> streamPremiumStatus(String uid) {
    return _firestoreService
        .streamDocument(FirestoreCollections.premium, uid)
        .map((data) => data == null ? null : PremiumModel.fromMap(uid, data));
  }

  Future<void> activatePremium({
    required String uid,
    required PremiumTier tier,
    required PremiumPlan plan,
    required PremiumProvider provider,
    DateTime? expiresAt,
    bool autoRenew = false,
    String? transactionId,
  }) async {
    final model = PremiumModel(
      id: uid,
      isActive: true,
      tier: tier,
      plan: plan,
      startedAt: DateTime.now(),
      expiresAt: expiresAt,
      autoRenew: autoRenew,
      provider: provider,
      transactionId: transactionId,
    );
    await _firestoreService.setDocument(FirestoreCollections.premium, uid, model.toMap());
    await _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'isPremium': true,
    });
    await _secureStorageService.cachePremiumStatus(true);
  }

  Future<void> deactivatePremium(String uid) async {
    await _firestoreService.updateDocument(FirestoreCollections.premium, uid, {
      'isActive': false,
      'autoRenew': false,
    });
    await _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'isPremium': false,
    });
    await _secureStorageService.cachePremiumStatus(false);
  }
}
