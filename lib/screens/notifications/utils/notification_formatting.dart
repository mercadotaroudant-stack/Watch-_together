import '../../../core/localization/generated/app_localizations.dart';
import '../../../providers/notification_providers.dart';

enum NotificationSection { today, yesterday, earlier }

/// Which section [timestamp] belongs to, relative to [now]. Only three
/// buckets per spec — no "This Week" the way Watch History has.
NotificationSection notificationSectionFor(DateTime timestamp, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final int dayDiff = today.difference(day).inDays;

  if (dayDiff <= 0) return NotificationSection.today;
  if (dayDiff == 1) return NotificationSection.yesterday;
  return NotificationSection.earlier;
}

/// Reuses the exact same "Today"/"Yesterday"/"Earlier" strings Watch
/// History already has — the words themselves have no "watched"-style
/// prefix baked in, so they apply just as well here.
String notificationSectionLabel(AppLocalizations l10n, NotificationSection section) {
  switch (section) {
    case NotificationSection.today:
      return l10n.historySectionToday;
    case NotificationSection.yesterday:
      return l10n.historySectionYesterday;
    case NotificationSection.earlier:
      return l10n.historySectionEarlier;
  }
}

/// Groups [items] (already sorted newest-first) into an ordered map of
/// non-empty sections only.
Map<NotificationSection, List<NotificationInboxItem>> groupNotificationsByDate(
  List<NotificationInboxItem> items, {
  DateTime? now,
}) {
  final DateTime effectiveNow = now ?? DateTime.now();
  final Map<NotificationSection, List<NotificationInboxItem>> grouped = {};

  for (final item in items) {
    final NotificationSection section = notificationSectionFor(item.timestamp, effectiveNow);
    grouped.putIfAbsent(section, () => []).add(item);
  }

  final Map<NotificationSection, List<NotificationInboxItem>> ordered = {};
  for (final section in NotificationSection.values) {
    if (grouped.containsKey(section)) ordered[section] = grouped[section]!;
  }
  return ordered;
}

/// "Just now" / "5m ago" / "3h ago" / "Yesterday" / "4d ago" — the
/// per-card timestamp, computed fresh from the real timestamp in the
/// current locale, never a persisted/English-only string.
String relativeNotificationTimeLabel(AppLocalizations l10n, DateTime timestamp, {DateTime? now}) {
  final DateTime effectiveNow = now ?? DateTime.now();
  final Duration diff = effectiveNow.difference(timestamp);
  final bool sameDay =
      timestamp.year == effectiveNow.year && timestamp.month == effectiveNow.month && timestamp.day == effectiveNow.day;

  if (diff.inMinutes < 1) return l10n.notificationTimeJustNow;
  if (diff.inHours < 1) return l10n.notificationTimeMinutesAgo(diff.inMinutes);
  if (sameDay) return l10n.notificationTimeHoursAgo(diff.inHours);

  final DateTime today = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);
  final DateTime day = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final int dayDiff = today.difference(day).inDays;

  if (dayDiff == 1) return l10n.notificationTimeYesterday;
  if (dayDiff > 1) return l10n.notificationTimeDaysAgo(dayDiff);
  return l10n.notificationTimeHoursAgo(diff.inHours);
}
