import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/watch_history_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// The current user's watch history, live — the single stream both this
/// screen and (whenever it exists) a Home "Continue Watching" section
/// are expected to read, per `WatchHistoryRepository`'s doc comment.
final StreamProvider<List<WatchHistoryModel>> liveWatchHistoryProvider =
    StreamProvider<List<WatchHistoryModel>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchHistoryRepositoryProvider).streamHistory(uid);
});

/// The most recent *unfinished* entry, if any — already ordered
/// newest-first by [liveWatchHistoryProvider], so this is just the
/// first non-completed item.
WatchHistoryModel? mostRecentUnfinished(List<WatchHistoryModel> history) {
  for (final entry in history) {
    if (!entry.isCompleted) return entry;
  }
  return null;
}
