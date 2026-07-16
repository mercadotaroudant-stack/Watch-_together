import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_join_requests_provider.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repository_providers.dart';
import '../friends/widgets/friends_confirm_dialog.dart';
import 'utils/notification_filter.dart';
import 'utils/notification_formatting.dart';
import 'widgets/notification_card_dispatcher.dart';
import 'widgets/notification_filter_tabs.dart';
import 'widgets/notification_summary_card.dart';
import 'widgets/notifications_empty_state.dart';
import 'widgets/notifications_error_state.dart';
import 'widgets/notifications_menu_sheet.dart';
import 'widgets/notifications_top_bar.dart';

/// The real Notifications screen (Phase 4) — replaces the
/// `ComingSoonScreen` placeholder at [RouteNames.notifications].
///
/// Reads from [notificationInboxProvider] (real `NotificationModel`s
/// merged with real pending join requests — see that provider's doc
/// comment) and reuses the existing notification/friend/room
/// repositories for every action. Nothing here is mocked.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  Future<void> _openMenu() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final action = await NotificationsMenuSheet.show(context);
    if (action == null || !mounted) return;

    final String? uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    switch (action) {
      case NotificationsMenuAction.markAllAsRead:
        await ref.read(notificationRepositoryProvider).markAllAsRead(uid);
        break;
      case NotificationsMenuAction.clearRead:
        final bool confirmed = await showFriendsConfirmDialog(
          context,
          title: l10n.notificationsClearRead,
          message: l10n.notificationsClearReadConfirmMessage,
          isDestructive: true,
        );
        if (confirmed) {
          await ref.read(notificationRepositoryProvider).deleteReadNotifications(uid);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            NotificationsTopBar(onMenuTap: _openMenu),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: NotificationSummaryCard(),
                    ),
                    const SizedBox(height: 20),
                    NotificationFilterTabs(
                      selected: _filter,
                      onChanged: (filter) => setState(() => _filter = filter),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _NotificationsBody(filter: _filter, l10n: l10n),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsBody extends ConsumerWidget {
  const _NotificationsBody({required this.filter, required this.l10n});

  final NotificationFilter filter;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(notificationInboxProvider);

    return inboxAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(color: AppColors.homePrimary)),
      ),
      error: (error, stackTrace) => NotificationsErrorState(
        onRetry: () {
          ref.invalidate(liveNotificationsProvider);
          ref.invalidate(myPendingJoinRequestsProvider);
        },
      ),
      data: (allItems) {
        final filtered = allItems.where((item) => notificationMatchesFilter(item, filter)).toList();
        if (filtered.isEmpty) return const NotificationsEmptyState();

        final grouped = groupNotificationsByDate(filtered);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  notificationSectionLabel(l10n, entry.key),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeMutedText,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              for (final item in entry.value) NotificationInboxCard(item: item),
            ],
          ],
        );
      },
    );
  }
}
