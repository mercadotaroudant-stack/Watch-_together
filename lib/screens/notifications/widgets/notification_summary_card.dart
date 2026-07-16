import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/notification_providers.dart';

/// "You have {count} unread notifications" / "You're all caught up" —
/// [count] always comes from [unreadNotificationsCountProvider], the
/// same real, live count driving the Home header's badge.
class NotificationSummaryCard extends ConsumerWidget {
  const NotificationSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homeWelcomeCardEnd, AppColors.notificationsSurface],
        ),
        border: Border.all(color: AppColors.homePrimary.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.homePrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_rounded, size: 26, color: AppColors.homePrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              unreadCount > 0
                  ? l10n.notificationsUnreadSummary(unreadCount)
                  : l10n.notificationsAllCaughtUp,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
