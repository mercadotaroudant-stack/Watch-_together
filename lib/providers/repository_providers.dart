import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/app_settings_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/message_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/premium_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/room_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/watch_history_repository.dart';
import 'service_providers.dart';

/// Dependency injection for every repository — the layer UI/state
/// (Phase 3+) is expected to actually depend on, never a `Service`
/// directly. Each provider composes the services it needs via
/// `ref.watch(...)`, so a service swapped in a test override
/// automatically flows through to the repository built on it.

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

final Provider<UserRepository> userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreServiceProvider)),
);

final Provider<RoomRepository> roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository(
    roomService: ref.watch(roomServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final Provider<MessageRepository> messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(firestoreServiceProvider)),
);

final Provider<FriendRepository> friendRepositoryProvider = Provider<FriendRepository>(
  (ref) => FriendRepository(ref.watch(friendServiceProvider)),
);

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final Provider<WatchHistoryRepository> watchHistoryRepositoryProvider =
    Provider<WatchHistoryRepository>(
  (ref) => WatchHistoryRepository(ref.watch(firestoreServiceProvider)),
);

final Provider<PremiumRepository> premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

final Provider<ReportRepository> reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(firestoreServiceProvider)),
);

final Provider<AppSettingsRepository> appSettingsRepositoryProvider =
    Provider<AppSettingsRepository>(
  (ref) => AppSettingsRepository(ref.watch(firestoreServiceProvider)),
);
