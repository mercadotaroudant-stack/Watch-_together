import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../providers/notification_providers.dart';
import 'admin_join_request_card.dart';
import 'friend_request_card.dart';
import 'room_invite_card.dart';
import 'system_notification_card.dart';

/// Routes one [NotificationInboxItem] to its type-specific card. Never
/// crashes on an unrecognized [NotificationType] — falls back to
/// [SystemNotificationCard] (title/body/timestamp only, mark-as-read on
/// tap), matching spec §10's "unknown notification type: only mark as
/// read, never crash".
class NotificationInboxCard extends StatelessWidget {
  const NotificationInboxCard({super.key, required this.item});

  final NotificationInboxItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      InboxJoinRequest(item: final adminItem) => AdminJoinRequestCard(item: adminItem),
      InboxNotification(:final notification) => switch (notification.type) {
          NotificationType.roomInvite => RoomInviteCard(notification: notification),
          NotificationType.friendRequest => FriendRequestCard(notification: notification),
          NotificationType.system ||
          NotificationType.premium ||
          NotificationType.message =>
            SystemNotificationCard(notification: notification),
        },
    };
  }
}
