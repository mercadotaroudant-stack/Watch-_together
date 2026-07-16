/// Base type for every exception this app throws deliberately.
///
/// Repositories and services never let a raw [FirebaseException],
/// [PlatformException], or similar leak past their boundary — everything
/// is caught and re-thrown as one of these, so UI code (Phase 3+) can
/// catch a single, app-defined exception type with a user-safe [message]
/// instead of parsing Firebase error codes.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  /// User-safe, already-friendly message. Safe to show directly in a
  /// SnackBar/dialog once UI exists.
  final String message;

  /// Machine-readable code (e.g. `'user-not-found'`), preserved from the
  /// underlying platform exception where available, for logging/analytics
  /// — not for display.
  final String? code;

  /// The original exception, kept for logging/Crashlytics, never shown
  /// to the user.
  final Object? cause;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.cause});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.cause});
}

class MessagingException extends AppException {
  const MessagingException(super.message, {super.code, super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

/// Thrown by repositories for domain-rule violations that aren't Firebase
/// errors at all (e.g. "room is full", "already friends") — kept distinct
/// from the Firebase-mapped exceptions above so callers can tell "the
/// backend rejected this on principle" apart from "the backend failed".
class DomainException extends AppException {
  const DomainException(super.message, {super.code, super.cause});
}

/// Catch-all for anything unexpected that still needs a safe message to
/// surface. Prefer a more specific [AppException] subtype wherever the
/// source is known.
class UnknownAppException extends AppException {
  const UnknownAppException([
    String message = 'Something went wrong. Please try again.',
  ]) : super(message);
}
