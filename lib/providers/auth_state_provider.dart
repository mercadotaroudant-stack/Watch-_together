import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'repository_providers.dart';

/// The app-wide "who is signed in" listener.
///
/// Wraps `AuthRepository.authStateChanges()` in a `StreamProvider` so any
/// part of the app can do `ref.watch(authStateProvider)` and get an
/// `AsyncValue<UserModel?>` — loading while Firebase Auth resolves its
/// persisted session, then the signed-in [UserModel] or `null`. This is
/// the provider Phase 3's router/UI should key "am I logged in" off of.
final StreamProvider<UserModel?> authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Convenience sync read of the current user id, for call sites that
/// need it outside of a widget build (e.g. inside another provider) and
/// can tolerate `null` during the brief window before [authStateProvider]
/// has its first value.
final Provider<String?> currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});
