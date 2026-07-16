import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/notification_model.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/user_lookup_provider.dart';
import '../../friends/widgets/friend_avatar.dart';
import '../../room_details/room_details_args.dart';
import '../utils/notification_formatting.dart';
import 'notification_card_shell.dart';

/// A [NotificationType.roomInvite] card. Real sender name/photo comes
/// from the notification's own `data` (`inviterId`/`inviterName`, added
/// alongside `roomId` when the invite is sent — see
/// `CreateRoomScreen`/`showInviteFriendsSheet`) with a live
/// [userByIdProvider] photo lookup; notifications sent before that
/// `data` existed fall back to the room's host.
class RoomInviteCard extends ConsumerWidget {
  const RoomInviteCard({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? inviterId = notification.data['inviterId'] as String?;
    final String inviterNameFromData = notification.data['inviterName'] as String? ?? '';

    final AsyncValue<UserModel?> inviterAsync =
        inviterId != null ? ref.watch(userByIdProvider(inviterId)) : const AsyncValue.data(null);
    final UserModel? inviter = inviterAsync.valueOrNull;
    final String inviterName =
        inviter?.displayName ?? (inviterNameFromData.isNotEmpty ? inviterNameFromData : '');

    return NotificationCardShell(
      isRead: notification.isRead,
      avatar: FriendAvatar(name: inviterName, photoUrl: inviter?.photoUrl, size: 52),
      title: notification.title,
      body: notification.body,
      timeLabel: relativeNotificationTimeLabel(l10n, notification.createdAt),
      onTap: () => _handleTap(context, ref),
      actions: notification.isRead
          ? null
          : Row(
              children: [
                _JoinButton(label: l10n.notificationsJoinAction, onTap: () => _join(context, ref)),
                const SizedBox(width: 10),
                _DeclineButton(label: l10n.notificationsDeclineAction, onTap: () => _decline(ref)),
              ],
            ),
      dismissibleKey: ValueKey('notification-${notification.id}'),
      confirmDismiss: () async {
        if (!notification.isRead) {
          await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
          return false;
        }
        return true;
      },
      onDismissed: () => ref.read(notificationRepositoryProvider).deleteNotification(notification.id),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    if (!notification.isRead) {
      await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    }
  }

  Future<void> _decline(WidgetRef ref) {
    // No dedicated "declined" state exists on NotificationModel today —
    // marking as read is the existing, supported way to dismiss an
    // invite (its Join/Decline actions then disappear).
    return ref.read(notificationRepositoryProvider).markAsRead(notification.id);
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? roomId = notification.data['roomId'] as String?;
    final UserModel? currentUser = ref.read(authStateProvider).valueOrNull;

    await ref.read(notificationRepositoryProvider).markAsRead(notification.id);

    if (roomId == null || currentUser == null) return;

    final roomRepository = ref.read(roomRepositoryProvider);
    final RoomModel? room = await roomRepository.getRoom(roomId);
    if (!context.mounted) return;

    if (room == null) {
      _snack(context, l10n.notificationsRoomUnavailable);
      return;
    }
    if (room.status == RoomStatus.ended) {
      _snack(context, l10n.joinRoomEndedError);
      return;
    }

    final bool alreadyMember = room.participantIds.contains(currentUser.uid);
    if (alreadyMember) {
      _openRoom(context, ref, room, currentUser);
      return;
    }

    if (room.isFull) {
      _snack(context, l10n.joinRoomFullError);
      return;
    }

    // Being invited directly implies the inviter's consent, so a
    // private room is joined outright (same rule `JoinRoomScreen`
    // follows) — only a *public* room still goes through the real
    // review flow, matching the Home screen's Public Rooms cards and
    // this task's explicit "don't bypass Admin approval" requirement.
    if (room.isPrivate) {
      await roomRepository.joinRoom(
        roomId: room.id,
        userId: currentUser.uid,
        displayName: currentUser.displayName ?? currentUser.email,
        photoUrl: currentUser.photoUrl,
      );
      if (!context.mounted) return;
      _openRoom(context, ref, room, currentUser);
    } else {
      await roomRepository.requestToJoin(
        roomId: room.id,
        userId: currentUser.uid,
        displayName: currentUser.displayName ?? currentUser.email,
        photoUrl: currentUser.photoUrl,
      );
      if (!context.mounted) return;
      _snack(context, l10n.homeWaitingForApproval);
    }
  }

  Future<void> _openRoom(
    BuildContext context,
    WidgetRef ref,
    RoomModel room,
    UserModel currentUser,
  ) async {
    final UserModel? host = await ref.read(userRepositoryProvider).getUser(room.hostId);
    if (!context.mounted) return;
    context.push(
      RouteNames.roomDetailsPath(room.id),
      extra: RoomDetailsArgs(room: room, host: host ?? currentUser, participants: const []),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 38,
          constraints: const BoxConstraints(minWidth: 82),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [AppColors.homePrimary, AppColors.homeSecondary]),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class _DeclineButton extends StatelessWidget {
  const _DeclineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3F3F46)),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.homeSecondaryText),
          ),
        ),
      ),
    );
  }
}
