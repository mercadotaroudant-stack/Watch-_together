import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/repository_providers.dart';
import 'profile_shared_rows.dart';

/// Per-category push-notification preferences (Room Invitations/Friend
/// Requests/App Updates) — distinct from the Notifications *inbox*
/// reached via the bell icon elsewhere in the app. Real state, read
/// from and written straight to the user's Firestore profile via
/// [UserRepository.updateNotificationPreferences].
class ProfileNotificationsSection extends ConsumerWidget {
  const ProfileNotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(authStateProvider).valueOrNull;

    Future<void> update({bool? roomInvitations, bool? friendRequests, bool? appUpdates}) {
      if (user == null) return Future.value();
      return ref.read(userRepositoryProvider).updateNotificationPreferences(
            uid: user.uid,
            roomInvitations: roomInvitations,
            friendRequests: friendRequests,
            appUpdates: appUpdates,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.profileNotificationsSection),
        ProfileSectionCard(
          children: [
            ProfileSwitchRow(
              emoji: '🎬',
              label: l10n.profileNotifyRoomInvitations,
              value: user?.notifyRoomInvitations ?? true,
              onChanged: user == null ? null : (v) => update(roomInvitations: v),
            ),
            ProfileSwitchRow(
              emoji: '👥',
              label: l10n.profileNotifyFriendRequests,
              value: user?.notifyFriendRequests ?? true,
              onChanged: user == null ? null : (v) => update(friendRequests: v),
            ),
            ProfileSwitchRow(
              emoji: '📢',
              label: l10n.profileNotifyAppUpdates,
              value: user?.notifyAppUpdates ?? true,
              onChanged: user == null ? null : (v) => update(appUpdates: v),
            ),
          ],
        ),
      ],
    );
  }
}
