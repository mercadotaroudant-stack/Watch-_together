import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_exception.dart';

/// Translates raw Firebase SDK exceptions into this app's [AppException]
/// hierarchy, with user-safe messages.
///
/// Every service method should funnel its `catch` clause through one of
/// these `map*` functions rather than rethrowing the raw
/// [FirebaseException] — that keeps Firebase-specific error codes out of
/// everything above the service layer.
abstract final class FirebaseErrorMapper {
  static AuthException mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      final String message = switch (error.code) {
        'invalid-email' => 'That email address looks invalid.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' => 'No account found with that email.',
        'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password.',
        'email-already-in-use' => 'An account already exists with that email.',
        'operation-not-allowed' => 'This sign-in method is currently disabled.',
        'weak-password' => 'Please choose a stronger password.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' =>
          'Network error. Check your connection and try again.',
        'requires-recent-login' =>
          'Please sign in again to complete this action.',
        _ => 'Authentication failed. Please try again.',
      };
      return AuthException(message, code: error.code, cause: error);
    }
    return AuthException(
      'Authentication failed. Please try again.',
      cause: error,
    );
  }

  static FirestoreException mapFirestoreError(Object error) {
    if (error is FirebaseException) {
      final String message = switch (error.code) {
        'permission-denied' =>
          'You don\'t have permission to do that.',
        'not-found' => 'The requested data could not be found.',
        'already-exists' => 'This already exists.',
        'unavailable' =>
          'The service is temporarily unavailable. Please try again.',
        'deadline-exceeded' => 'The request timed out. Please try again.',
        'resource-exhausted' => 'Too many requests. Please slow down.',
        'cancelled' => 'The operation was cancelled.',
        _ => 'Something went wrong while reaching the server.',
      };
      return FirestoreException(message, code: error.code, cause: error);
    }
    return FirestoreException(
      'Something went wrong while reaching the server.',
      cause: error,
    );
  }

  static StorageException mapStorageError(Object error) {
    if (error is FirebaseException) {
      final String message = switch (error.code) {
        'object-not-found' => 'The requested file could not be found.',
        'unauthorized' => 'You don\'t have permission to access this file.',
        'canceled' => 'The upload was cancelled.',
        'quota-exceeded' => 'Storage quota exceeded.',
        _ => 'File operation failed. Please try again.',
      };
      return StorageException(message, code: error.code, cause: error);
    }
    return StorageException('File operation failed. Please try again.', cause: error);
  }

  static MessagingException mapMessagingError(Object error) {
    if (error is FirebaseException) {
      return MessagingException(
        'Notification setup failed.',
        code: error.code,
        cause: error,
      );
    }
    return MessagingException('Notification setup failed.', cause: error);
  }
}
