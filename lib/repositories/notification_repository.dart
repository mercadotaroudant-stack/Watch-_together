import '../core/constants/firestore_collections.dart';
import '../core/helpers/app_logger.dart';
import '../models/enums.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'user_repository.dart';

/// Combines the `notifications` Firestore collection with FCM token
/// registration ([NotificationService]) — the two are related (a push
/// notification's tap payload becomes a persisted in-app notification)
/// but the collection CRUD and the FCM plumbing are kept as separate
/// methods here rather than separate repositories, since Phase 3's
/// notification UI will want both from one place.
class NotificationRepository {
  NotificationRepository({
    required FirestoreService firestoreService,
    required NotificationService notificationService,
    required UserRepository userRepository,
  })  : _firestoreService = firestoreService,
        _notificationService = notificationService,
        _userRepository = userRepository;

  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final UserRepository _userRepository;

  /// Requests permission, gets the current FCM token, persists it on the
  /// user's document, and subscribes to future token rotations. Call
  /// once after sign-in.
  Future<void> registerForPushNotifications(String uid) async {
    final granted = await _notificationService.requestPermission();
    if (!granted) {
      AppLogger.info('Push notification permission not granted for $uid');
      return;
    }
    final String? token = await _notificationService.getToken();
    if (token != null) {
      await _userRepository.addFcmToken(uid: uid, token: token);
    }
    _notificationService.onTokenRefresh().listen((newToken) {
      _userRepository.addFcmToken(uid: uid, token: newToken);
    });
  }

  Future<NotificationModel> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    final String id = _firestoreService.newDocumentId(FirestoreCollections.notifications);
    final notification = NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      createdAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.notifications,
      id,
      notification.toMap(),
      merge: false,
    );
    return notification;
  }

  Future<void> markAsRead(String notificationId) {
    return _firestoreService.updateDocument(
      FirestoreCollections.notifications,
      notificationId,
      {'isRead': true},
    );
  }

  /// Marks every currently-unread notification belonging to [userId] as
  /// read in one batched write — the Notifications screen's "Mark all
  /// as read" app bar action. A no-op (no batch committed) when there's
  /// nothing unread.
  Future<void> markAllAsRead(String userId) async {
    final List<Map<String, dynamic>> docs = await _firestoreService.runQuery(
      (ref) => ref.where('userId', isEqualTo: userId).where('isRead', isEqualTo: false),
      FirestoreCollections.notifications,
    );
    if (docs.isEmpty) return;
    final batch = _firestoreService.batch();
    for (final doc in docs) {
      batch.update(
        _firestoreService.collection(FirestoreCollections.notifications).doc(doc['id'] as String),
        {'isRead': true},
      );
    }
    await _firestoreService.commitBatch(batch);
  }

  /// Deletes a single notification — used by the Notifications screen's
  /// swipe-to-dismiss. Only ever called on already-read/non-actionable
  /// notifications; see `NotificationsScreen`'s doc comment for why.
  Future<void> deleteNotification(String notificationId) =>
      _firestoreService.deleteDocument(FirestoreCollections.notifications, notificationId);

  /// Deletes every already-read notification belonging to [userId] in
  /// one batched write — the Notifications screen's "Clear read
  /// notifications" app bar action. Never touches unread notifications,
  /// so a pending room-invite/friend-request can't be lost this way.
  Future<void> deleteReadNotifications(String userId) async {
    final List<Map<String, dynamic>> docs = await _firestoreService.runQuery(
      (ref) => ref.where('userId', isEqualTo: userId).where('isRead', isEqualTo: true),
      FirestoreCollections.notifications,
    );
    if (docs.isEmpty) return;
    final batch = _firestoreService.batch();
    for (final doc in docs) {
      batch.delete(
        _firestoreService.collection(FirestoreCollections.notifications).doc(doc['id'] as String),
      );
    }
    await _firestoreService.commitBatch(batch);
  }

  Stream<List<NotificationModel>> streamNotifications(String userId, {int limit = 50}) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(limit),
          FirestoreCollections.notifications,
        )
        .map(
          (docs) => docs.map((d) => NotificationModel.fromMap(d['id'] as String, d)).toList(),
        );
  }
}
