import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/user_lookup_provider.dart';
import '../../friends/friends_actions.dart';
import '../../friends/widgets/friend_avatar.dart';
import '../utils/notification_formatting.dart';
import 'notification_card_shell.dart';

/// A [NotificationType.friendRequest] card. Expects
/// `notification.data['fromUserId']` — the contract for whichever future
/// "send friend request" UI starts creating these (nothing does yet;
/// `FriendRepository.sendFriendRequest`/`FriendsActions` already fully
/// support it, they just have no caller in this build). Accept/Reject
/// both go through the exact same [FriendsActions] the Friends screen's
/// own incoming-request list already uses, so a friend accepted here
/// shows up everywhere else immediately.
class FriendRequestCard extends ConsumerWidget {
  const FriendRequestCard({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? fromUserId = notification.data['fromUserId'] as String?;

    final AsyncValue<UserModel?> senderAsync =
        fromUserId != null ? ref.watch(userByIdProvider(fromUserId)) : const AsyncValue.data(null);
    final UserModel? sender = senderAsync.valueOrNull;
    final String senderName = sender?.displayName ?? '';

    return NotificationCardShell(
      isRead: notification.isRead,
      avatar: FriendAvatar(name: senderName, photoUrl: sender?.photoUrl, size: 52),
      title: notification.title,
      body: notification.body,
      timeLabel: relativeNotificationTimeLabel(l10n, notification.createdAt),
      onTap: () async {
        if (!notification.isRead) {
          await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
      },
      actions: (!notification.isRead && fromUserId != null)
          ? Row(
              children: [
                _AcceptButton(
                  label: l10n.notificationsAcceptAction,
                  onTap: () => _accept(context, ref, fromUserId, senderName),
                ),
                const SizedBox(width: 10),
                _RejectButton(
                  label: l10n.notificationsRejectAction,
                  onTap: () => _reject(context, ref, fromUserId),
                ),
              ],
            )
          : null,
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

  Future<void> _accept(BuildContext context, WidgetRef ref, String fromUserId, String senderName) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    if (!context.mounted) return;
    await FriendsActions(ref).acceptRequest(context, requesterId: fromUserId, requesterName: senderName);
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, String fromUserId) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    if (!context.mounted) return;
    await FriendsActions(ref).declineRequest(context, requesterId: fromUserId);
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.label, required this.onTap});

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
            color: AppColors.success,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  const _RejectButton({required this.label, required this.onTap});

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
            color: AppColors.error.withOpacity(0.12),
            border: Border.all(color: AppColors.error.withOpacity(0.40)),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
