import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../providers/repository_providers.dart';
import '../utils/notification_formatting.dart';
import 'notification_card_shell.dart';

/// A [NotificationType.system]/[NotificationType.premium]/
/// [NotificationType.message] card — no Accept/Reject actions per spec.
/// Tapping only navigates when `data['route']` matches one of a small,
/// explicit whitelist of internal destinations; anything else (missing,
/// unrecognized, or an external URL) just marks the notification read,
/// per spec's "never execute arbitrary URLs / never invent external
/// links".
class SystemNotificationCard extends ConsumerWidget {
  const SystemNotificationCard({super.key, required this.notification});

  final NotificationModel notification;

  static const Map<String, String> _routeWhitelist = {
    'premium': RouteNames.premium,
    'watchHistory': RouteNames.watchHistory,
    'friends': RouteNames.friends,
    'myRooms': RouteNames.myRooms,
    'profile': RouteNames.profile,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return NotificationCardShell(
      isRead: notification.isRead,
      avatar: _AppIconAvatar(),
      title: notification.title,
      body: notification.body,
      timeLabel: relativeNotificationTimeLabel(l10n, notification.createdAt),
      onTap: () => _handleTap(context, ref),
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
    final String? routeKey = notification.data['route'] as String?;
    final String? route = routeKey == null ? null : _routeWhitelist[routeKey];
    if (route != null && context.mounted) {
      context.push(route);
    }
  }
}

class _AppIconAvatar extends StatelessWidget {
  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        AssetPaths.appLogo,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.homePrimary, AppColors.homeSecondary]),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.white, size: 26),
        ),
      ),
    );
  }
}
