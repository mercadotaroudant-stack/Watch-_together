import 'package:firebase_auth/firebase_auth.dart' show User;

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/secure_storage_service.dart';

/// The single entry point the rest of the app uses for authentication.
///
/// Composes [AuthService] (Firebase Auth mechanics), [FirestoreService]
/// (the `users` profile document), and [SecureStorageService] (a local
/// session mirror for instant cold-start UI) so callers work only with
/// [UserModel] and never touch `firebase_auth`/`cloud_firestore` types
/// directly.
class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
    required SecureStorageService secureStorageService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _secureStorageService = secureStorageService;

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final SecureStorageService _secureStorageService;

  /// Emits the current user's full [UserModel] (or `null` when signed
  /// out) every time Firebase Auth's sign-in state changes. This is the
  /// stream a `StreamProvider` should expose to the rest of the app as
  /// "the" auth state — see README for the Phase 3 wiring note.
  Stream<UserModel?> authStateChanges() {
    return _authService.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchOrBootstrapUserDocument(user);
    });
  }

  /// Synchronous, best-effort check for "is someone signed in" — used to
  /// decide the initial route before [authStateChanges] has necessarily
  /// emitted. Prefer [authStateChanges] wherever a stream is workable.
  bool get isSignedIn => _authService.isSignedIn;

  Future<UserModel?> fetchCurrentUser() async {
    final User? user = _authService.currentUser;
    if (user == null) return null;
    return _fetchOrBootstrapUserDocument(user);
  }

  /// Reads the locally cached session (written on the last successful
  /// sign-in) without hitting Firebase at all. Useful for rendering an
  /// optimistic "signed in as ..." UI the instant the app launches,
  /// before Firebase Auth has finished restoring its own session.
  Future<({String uid, String email})?> readCachedSession() =>
      _secureStorageService.readAuthSession();

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _authService.signUpWithEmail(email: email, password: password);
    final User? user = credential.user;
    if (user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }
    if (displayName != null && displayName.isNotEmpty) {
      await _authService.updateDisplayName(displayName);
    }

    final now = DateTime.now();
    final newUser = UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: displayName ?? user.displayName,
      photoUrl: user.photoURL,
      createdAt: now,
      lastSeenAt: now,
      isOnline: true,
    );
    await _firestoreService.setDocument(
      FirestoreCollections.users,
      user.uid,
      newUser.toMap(),
    );
    await _secureStorageService.saveAuthSession(uid: user.uid, email: newUser.email);
    return newUser;
  }

  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    final credential = await _authService.signInWithEmail(email: email, password: password);
    final User? user = credential.user;
    if (user == null) {
      throw const AuthException('Sign in failed. Please try again.');
    }
    final userModel = await _fetchOrBootstrapUserDocument(user);
    await _firestoreService.updateDocument(FirestoreCollections.users, user.uid, {
      'isOnline': true,
      'lastSeenAt': DateTime.now(),
    });
    await _secureStorageService.saveAuthSession(uid: user.uid, email: userModel.email);
    return userModel;
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  /// Updates the display name in both Firebase Auth and the user's
  /// Firestore profile document, so every screen reading either stays
  /// in sync. Used by My Profile's Account Information section.
  Future<void> updateDisplayName({required String uid, required String displayName}) async {
    await _authService.updateDisplayName(displayName);
    await _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'displayName': displayName,
    });
  }

  /// Same idea as [updateDisplayName], for the profile photo — called
  /// after a real upload (see `StorageService.uploadProfileImage`) with
  /// the resulting download URL.
  Future<void> updatePhotoUrl({required String uid, required String photoUrl}) async {
    await _authService.updatePhotoUrl(photoUrl);
    await _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'photoUrl': photoUrl,
    });
  }

  /// Permanently deletes the signed-in user's account: their Firestore
  /// profile document, the locally cached session, then the Firebase
  /// Auth account itself (last, since it's what determines whether the
  /// rest could still fail and be retried).
  ///
  /// Note: this does not clean up the user's rooms/friendships/watch
  /// history/premium record — that fan-out is best done server-side
  /// (e.g. a Cloud Function triggered on auth user deletion) rather
  /// than as a growing list of client-side deletes here.
  Future<void> deleteAccount(String uid) async {
    await _firestoreService.deleteDocument(FirestoreCollections.users, uid);
    await _secureStorageService.clearAuthSession();
    await _authService.deleteAccount();
  }

  Future<void> logout() async {
    final String? uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.updateDocument(FirestoreCollections.users, uid, {
        'isOnline': false,
        'lastSeenAt': DateTime.now(),
      });
    }
    await _authService.signOut();
    await _secureStorageService.clearAuthSession();
    await _secureStorageService.clearPremiumCache();
  }

  /// Fetches the `users/{uid}` document for an already-authenticated
  /// [User], creating it from the Firebase Auth profile if it's missing
  /// (covers accounts created before this document existed, or created
  /// via a method other than [signUpWithEmail]).
  Future<UserModel> _fetchOrBootstrapUserDocument(User user) async {
    final data = await _firestoreService.getDocument(FirestoreCollections.users, user.uid);
    if (data != null) return UserModel.fromMap(user.uid, data);

    final now = DateTime.now();
    final bootstrapped = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: now,
      lastSeenAt: now,
      isOnline: true,
    );
    await _firestoreService.setDocument(
      FirestoreCollections.users,
      user.uid,
      bootstrapped.toMap(),
    );
    return bootstrapped;
  }
}
