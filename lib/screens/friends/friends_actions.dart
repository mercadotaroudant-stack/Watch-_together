import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/repository_providers.dart';
import 'widgets/friends_confirm_dialog.dart';
import 'widgets/report_user_sheet.dart';

/// Bundles every friend-relationship mutation the Friends screen (and
/// its Search screen) can trigger, so both surfaces share one
/// implementation instead of duplicating the confirm-dialog + repo-call
/// + snackbar sequence for each action.
class FriendsActions {
  FriendsActions(this.ref);

  final WidgetRef ref;

  String? get _uid => ref.read(currentUserIdProvider);

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> acceptRequest(
    BuildContext context, {
    required String requesterId,
    required String requesterName,
  }) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(friendRepositoryProvider).acceptFriendRequest(userIdA: uid, userIdB: requesterId);
      _showSnack(context, l10n.friendsRequestAcceptedMessage(requesterName));
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> declineRequest(BuildContext context, {required String requesterId}) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(friendRepositoryProvider).declineFriendRequest(userIdA: uid, userIdB: requesterId);
      _showSnack(context, l10n.friendsRequestDeclinedMessage);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  /// Sends a real friend request (the Add Friend screen's "Add Friend"
  /// button) and, on success, creates the matching real
  /// [NotificationType.friendRequest] notification for the recipient —
  /// the single place both of those happen, so nothing else duplicates
  /// this sequence. `data: {'fromUserId': uid}` matches exactly the
  /// contract `FriendRequestCard` (Notifications screen) already reads.
  ///
  /// [FriendRepository.sendFriendRequest] itself already rejects
  /// self-requests, duplicate pending requests, and requests to an
  /// existing friend (throwing a domain error) — including the
  /// "crossed requests" case, since a pair only ever has one
  /// `friend_requests` document (see [FriendModel.buildId]) regardless
  /// of who initiated it, so a second `sendFriendRequest` call in the
  /// opposite direction hits that same duplicate check. Every one of
  /// those is a real, user-facing edge case the UI is expected to avoid
  /// reaching in the first place (by deriving each search result's
  /// button state from real relationship data), so failures here fall
  /// back to a generic localized message rather than surfacing that
  /// domain error's own English text.
  Future<bool> sendRequest(
    BuildContext context, {
    required String toUserId,
  }) async {
    final String? uid = _uid;
    if (uid == null) return false;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    try {
      await ref.read(friendRepositoryProvider).sendFriendRequest(fromUserId: uid, toUserId: toUserId);

      // Respect the recipient's own "friend requests" preference (My
      // Profile > Notifications) before creating their notification —
      // the request itself is still created either way.
      final UserModel? recipient = await ref.read(userRepositoryProvider).getUser(toUserId);
      if (recipient == null || recipient.notifyFriendRequests) {
        final UserModel? sender = ref.read(authStateProvider).valueOrNull;
        final String senderName = sender?.displayName ?? sender?.email ?? '';
        await ref.read(notificationRepositoryProvider).createNotification(
          userId: toUserId,
          type: NotificationType.friendRequest,
          title: l10n.friendRequestNotificationTitle(senderName),
          body: l10n.friendRequestNotificationBody,
          data: {'fromUserId': uid},
        );
      }

      if (context.mounted) _showSnack(context, l10n.friendsRequestSentMessage);
      return true;
    } catch (_) {
      if (context.mounted) _showSnack(context, l10n.somethingWentWrong);
      return false;
    }
  }

  /// Cancels a request the current user sent — the Friends screen's
  /// "Sent Requests" tab. Mechanically identical to [declineRequest]
  /// (same document, same delete), reused rather than duplicated; only
  /// the label/snackbar differ since this is the sender acting, not the
  /// recipient.
  Future<void> cancelRequest(BuildContext context, {required String recipientId}) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(friendRepositoryProvider).declineFriendRequest(userIdA: uid, userIdB: recipientId);
      _showSnack(context, l10n.friendsRequestCancelledMessage);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> removeFriend(
    BuildContext context, {
    required String friendId,
    required String friendName,
  }) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool confirmed = await showFriendsConfirmDialog(
      context,
      title: l10n.friendsMenuRemoveFriend,
      message: l10n.friendsRemoveConfirmMessage(friendName),
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(friendRepositoryProvider).removeFriend(userIdA: uid, userIdB: friendId);
      _showSnack(context, l10n.friendsRemovedMessage);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> blockUser(
    BuildContext context, {
    required String userId,
    required String userName,
  }) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool confirmed = await showFriendsConfirmDialog(
      context,
      title: l10n.friendsMenuBlockUser,
      message: l10n.friendsBlockConfirmMessage(userName),
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(friendRepositoryProvider).blockUser(userId: uid, blockedUserId: userId);
      _showSnack(context, l10n.friendsBlockedMessage);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> unblockUser(
    BuildContext context, {
    required String userId,
    required String userName,
  }) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool confirmed = await showFriendsConfirmDialog(
      context,
      title: l10n.friendsMenuUnblockUser,
      message: l10n.friendsUnblockConfirmMessage(userName),
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(friendRepositoryProvider).unblockUser(userId: uid, blockedUserId: userId);
      _showSnack(context, l10n.friendsUnblockedMessage);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> reportUser(
    BuildContext context, {
    required String userId,
    required String userName,
  }) async {
    final String? uid = _uid;
    if (uid == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final ReportReason? reason = await ReportUserSheet.show(context, userName: userName);
    if (reason == null || !context.mounted) return;

    try {
      await ref.read(reportRepositoryProvider).submitReport(
            reporterId: uid,
            reportedUserId: userId,
            reason: reason,
          );
      _showSnack(context, l10n.friendsReportSubmitted);
    } catch (_) {
      _showSnack(context, l10n.somethingWentWrong);
    }
  }

  void showComingSoon(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _showSnack(context, l10n.friendsComingSoonMessage);
  }

  void showInviteToRoomUnavailable(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _showSnack(context, l10n.friendsInviteToRoomUnavailableMessage);
  }
}
