import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import 'admin_join_requests_provider.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// The signed-in user's notifications, live — the single stream the
/// Home header's badge and the real Notifications screen both read
/// from. Empty while signed out.
final StreamProvider<List<NotificationModel>> liveNotificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).streamNotifications(uid);
});

/// One entry in the Notifications screen's unified inbox — either a
/// real, persisted [NotificationModel] ([InboxNotification]) or a real,
/// live pending join request against a room the user hosts
/// ([InboxJoinRequest], from [myPendingJoinRequestsProvider]). Join
/// requests aren't [NotificationModel] documents (nothing writes one
/// for them today), but the spec still wants the Admin/Host to see
/// "X wants to join Y" alongside their other notifications, so this
/// sealed type is what lets the screen render/sort/group both kinds
/// through one list without either side pretending to be the other.
sealed class NotificationInboxItem extends Equatable {
  const NotificationInboxItem();

  DateTime get timestamp;
}

class InboxNotification extends NotificationInboxItem {
  const InboxNotification(this.notification);

  final NotificationModel notification;

  @override
  DateTime get timestamp => notification.createdAt;

  @override
  List<Object?> get props => [notification];
}

class InboxJoinRequest extends NotificationInboxItem {
  const InboxJoinRequest(this.item);

  final AdminJoinRequestItem item;

  @override
  DateTime get timestamp => item.request.requestedAt;

  @override
  List<Object?> get props => [item];
}

/// The Notifications screen's single source of truth: real notifications
/// merged with real pending join requests, newest-first. Loading/error
/// propagate from whichever underlying stream is loading/erroring so the
/// screen can show one consistent state rather than a partial list.
final Provider<AsyncValue<List<NotificationInboxItem>>> notificationInboxProvider =
    Provider<AsyncValue<List<NotificationInboxItem>>>((ref) {
  final AsyncValue<List<NotificationModel>> notificationsAsync = ref.watch(liveNotificationsProvider);
  final AsyncValue<List<AdminJoinRequestItem>> joinRequestsAsync =
      ref.watch(myPendingJoinRequestsProvider);

  if (notificationsAsync.hasError) {
    return AsyncValue.error(notificationsAsync.error!, notificationsAsync.stackTrace!);
  }
  if (joinRequestsAsync.hasError) {
    return AsyncValue.error(joinRequestsAsync.error!, joinRequestsAsync.stackTrace!);
  }
  if (!notificationsAsync.hasValue || !joinRequestsAsync.hasValue) {
    return const AsyncValue.loading();
  }

  final List<NotificationInboxItem> items = [
    ...notificationsAsync.value!.map(InboxNotification.new),
    ...joinRequestsAsync.value!.map(InboxJoinRequest.new),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return AsyncValue.data(items);
});

/// Real unread/actionable count: unread [NotificationModel]s plus every
/// pending join request the user (as host) hasn't yet resolved. Drives
/// both the Home header's badge and the Notifications screen's summary
/// card — one provider, so the two can never drift out of sync (spec
/// §15's "real-time badge connection").
final Provider<int> unreadNotificationsCountProvider = Provider<int>((ref) {
  final List<NotificationModel> notifications =
      ref.watch(liveNotificationsProvider).valueOrNull ?? const [];
  final int unreadNotifications = notifications.where((n) => !n.isRead).length;
  final int pendingJoinRequests = ref.watch(myPendingJoinRequestsProvider).valueOrNull?.length ?? 0;
  return unreadNotifications + pendingJoinRequests;
});
