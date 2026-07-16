import '../../../models/enums.dart';
import '../../../providers/notification_providers.dart';

enum NotificationFilter { all, rooms, friends, app }

/// Whether [item] belongs under [filter]. Filtering happens client-side
/// over the already-loaded [notificationInboxProvider] list (per spec —
/// no per-tab Firestore query), since a signed-in user's own inbox is
/// always small enough for this to be instant.
bool notificationMatchesFilter(NotificationInboxItem item, NotificationFilter filter) {
  if (filter == NotificationFilter.all) return true;

  return switch (item) {
    InboxJoinRequest() => filter == NotificationFilter.rooms,
    InboxNotification(:final notification) => switch (notification.type) {
        NotificationType.roomInvite || NotificationType.message => filter == NotificationFilter.rooms,
        NotificationType.friendRequest => filter == NotificationFilter.friends,
        NotificationType.system || NotificationType.premium => filter == NotificationFilter.app,
      },
  };
}
