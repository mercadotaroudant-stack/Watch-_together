import 'package:firebase_auth/firebase_auth.dart';

import '../core/errors/firebase_error_mapper.dart';

/// Thin wrapper around [FirebaseAuth].
///
/// Returns raw [User]?/[UserCredential] types — mapping to [UserModel]
/// and persisting the `users` Firestore document is `AuthRepository`'s
/// job, not this service's. Every method maps [FirebaseAuthException]
/// to [AuthException] via [FirebaseErrorMapper].
class AuthService {
  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  /// Emits whenever the signed-in user changes (sign in, sign out, token
  /// refresh that invalidates the user). This is what
  /// `AuthRepository.authStateChanges` and, later, a Riverpod
  /// `StreamProvider` build on for the "am I logged in" state.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Emits only on sign-in/sign-out (not token refreshes) — cheaper to
  /// listen to when a caller only cares about that transition.
  Stream<User?> userChanges() => _auth.userChanges();

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> reauthenticate(String password) async {
    final User? user = _auth.currentUser;
    final String? email = user?.email;
    if (user == null || email == null) {
      throw FirebaseErrorMapper.mapAuthError(
        FirebaseAuthException(code: 'requires-recent-login'),
      );
    }
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapAuthError(e);
    }
  }
}
