import '../../../core/localization/generated/app_localizations.dart';
import '../../../models/watch_history_model.dart';

enum HistorySection { today, yesterday, thisWeek, earlier }

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Which section a [watchedAt] timestamp belongs to, relative to [now].
HistorySection historySectionFor(DateTime watchedAt, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(watchedAt.year, watchedAt.month, watchedAt.day);
  final int dayDiff = today.difference(day).inDays;

  if (dayDiff <= 0) return HistorySection.today;
  if (dayDiff == 1) return HistorySection.yesterday;
  if (dayDiff <= 6) return HistorySection.thisWeek;
  return HistorySection.earlier;
}

String historySectionLabel(AppLocalizations l10n, HistorySection section) {
  switch (section) {
    case HistorySection.today:
      return l10n.historySectionToday;
    case HistorySection.yesterday:
      return l10n.historySectionYesterday;
    case HistorySection.thisWeek:
      return l10n.historySectionThisWeek;
    case HistorySection.earlier:
      return l10n.historySectionEarlier;
  }
}

/// Groups [items] (already sorted newest-first) into an ordered map of
/// non-empty sections only — per spec, a section with no items simply
/// isn't rendered at all rather than shown empty.
Map<HistorySection, List<WatchHistoryModel>> groupHistoryByDate(
  List<WatchHistoryModel> items, {
  DateTime? now,
}) {
  final DateTime effectiveNow = now ?? DateTime.now();
  final Map<HistorySection, List<WatchHistoryModel>> grouped = {};

  for (final item in items) {
    final HistorySection section = historySectionFor(item.watchedAt, effectiveNow);
    grouped.putIfAbsent(section, () => []).add(item);
  }

  final Map<HistorySection, List<WatchHistoryModel>> ordered = {};
  for (final section in HistorySection.values) {
    if (grouped.containsKey(section)) ordered[section] = grouped[section]!;
  }
  return ordered;
}

/// "Watched just now" / "Watched 48m ago" / "Watched 3h ago" /
/// "Watched yesterday" / "Watched 2 days ago" — computed fresh from the
/// real `watchedAt` timestamp, never a string persisted in Firestore.
String relativeWatchedLabel(AppLocalizations l10n, DateTime watchedAt, {DateTime? now}) {
  final DateTime effectiveNow = now ?? DateTime.now();
  final Duration diff = effectiveNow.difference(watchedAt);

  if (diff.inMinutes < 1) return l10n.historyWatchedJustNow;
  if (diff.inHours < 1) return l10n.historyWatchedMinutesAgo(diff.inMinutes);
  if (_isSameDay(watchedAt, effectiveNow)) return l10n.historyWatchedHoursAgo(diff.inHours);

  final DateTime today = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);
  final DateTime day = DateTime(watchedAt.year, watchedAt.month, watchedAt.day);
  final int dayDiff = today.difference(day).inDays;

  if (dayDiff == 1) return l10n.historyWatchedYesterday;
  if (dayDiff > 1) return l10n.historyWatchedDaysAgo(dayDiff);
  return l10n.historyWatchedHoursAgo(diff.inHours);
}
