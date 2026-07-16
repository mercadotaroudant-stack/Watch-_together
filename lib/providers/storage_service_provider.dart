import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';

/// Exposes [LocalStorageService] to the widget tree.
///
/// `SharedPreferences.getInstance()` is async, but Riverpod providers are
/// constructed synchronously, so this is intentionally left unimplemented
/// here and overridden with the real instance in `main.dart` *before*
/// `runApp` — see `main.dart` for the `ProviderScope(overrides: [...])`
/// wiring. Reading this provider without that override throws immediately,
/// which surfaces a missed-wiring bug at startup instead of a confusing
/// null-pref value deep in the app.
final Provider<LocalStorageService> localStorageServiceProvider =
    Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageServiceProvider must be overridden in main.dart after '
    'SharedPreferences.getInstance() resolves.',
  );
});
