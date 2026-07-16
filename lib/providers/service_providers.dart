import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/crashlytics_service.dart';
import '../services/firestore_service.dart';
import '../services/friend_service.dart';
import '../services/notification_service.dart';
import '../services/remote_config_service.dart';
import '../services/purchase_service.dart';
import '../services/room_service.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';

/// Dependency injection for every service.
///
/// Riverpod is this app's DI container (see README.md — no separate
/// `get_it`/`injectable` setup, to avoid two competing DI systems).
/// Every service is exposed as a `Provider`, constructed lazily the
/// first time something reads it, and cached for the lifetime of the
/// `ProviderScope`. Repositories (see `providers/repository_providers.dart`)
/// depend on these via `ref.watch(...)` instead of constructing services
/// themselves, which is what makes every service swappable in tests via
/// `ProviderScope(overrides: [...])`.
///
/// Firebase-backed services read `FirebaseAuth.instance` /
/// `FirebaseFirestore.instance` / etc. internally (see each service's
/// default constructor argument) rather than taking the singleton as a
/// provider dependency, since those singletons are only valid *after*
/// `Firebase.initializeApp()` — already awaited in `main.dart` before
/// `runApp` — and don't otherwise vary per-environment the way our own
/// services do.

final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final Provider<AuthService> authServiceProvider =
    Provider<AuthService>((ref) => AuthService());

final Provider<RoomService> roomServiceProvider = Provider<RoomService>(
  (ref) => RoomService(ref.watch(firestoreServiceProvider)),
);

final Provider<FriendService> friendServiceProvider = Provider<FriendService>(
  (ref) => FriendService(ref.watch(firestoreServiceProvider)),
);

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final Provider<AnalyticsService> analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

final Provider<RemoteConfigService> remoteConfigServiceProvider =
    Provider<RemoteConfigService>((ref) => RemoteConfigService());

final Provider<CrashlyticsService> crashlyticsServiceProvider =
    Provider<CrashlyticsService>((ref) => CrashlyticsService());

final Provider<SecureStorageService> secureStorageServiceProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

final Provider<PurchaseService> purchaseServiceProvider =
    Provider<PurchaseService>((ref) => PurchaseService());

final Provider<StorageService> storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());
