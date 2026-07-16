import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key/value storage for sensitive data: the auth session and
/// the cached premium status.
///
/// Kept separate from [LocalStorageService] (which uses plain
/// [SharedPreferences]) because auth/premium data warrants OS-level
/// encryption (Keystore on Android), while locale/theme are low-stakes
/// UI preferences that don't need it.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const String _keyAuthUid = 'auth_uid';
  static const String _keyAuthEmail = 'auth_email';
  static const String _keyPremiumCache = 'premium_status_cache';
  static const String _keyPremiumCacheAt = 'premium_status_cache_at';

  // --- Authentication session ---
  //
  // Firebase Auth already persists the real session (ID/refresh tokens)
  // internally on-device; this mirrors just enough (uid + email) for the
  // app to render an "already signed in" UI instantly on cold start,
  // before Firebase's own `authStateChanges()` stream has emitted —
  // see AuthRepository.tryAutoLogin().
  Future<void> saveAuthSession({required String uid, required String email}) async {
    await _storage.write(key: _keyAuthUid, value: uid);
    await _storage.write(key: _keyAuthEmail, value: email);
  }

  Future<({String uid, String email})?> readAuthSession() async {
    final String? uid = await _storage.read(key: _keyAuthUid);
    final String? email = await _storage.read(key: _keyAuthEmail);
    if (uid == null || email == null) return null;
    return (uid: uid, email: email);
  }

  Future<void> clearAuthSession() async {
    await _storage.delete(key: _keyAuthUid);
    await _storage.delete(key: _keyAuthEmail);
  }

  // --- Premium status cache ---
  //
  // A short-lived local cache so premium-gated UI doesn't flash
  // "not premium" while the real Firestore read is in flight. The
  // repository is always the source of truth; this is read-through only.
  Future<void> cachePremiumStatus(bool isPremium) async {
    await _storage.write(key: _keyPremiumCache, value: isPremium.toString());
    await _storage.write(
      key: _keyPremiumCacheAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<bool?> readCachedPremiumStatus() async {
    final String? value = await _storage.read(key: _keyPremiumCache);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> clearPremiumCache() async {
    await _storage.delete(key: _keyPremiumCache);
    await _storage.delete(key: _keyPremiumCacheAt);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
