import '../core/constants/firestore_collections.dart';
import '../models/watch_history_model.dart';
import '../services/firestore_service.dart';

/// Per-user watch history (`watch_history` collection) — the single
/// source of truth for both the History screen and (whenever it's
/// built) a Home "Continue Watching" section. Both are expected to read
/// through [streamHistory] rather than keeping separate
/// playback-progress state, so a save from the video player shows up
/// identically in either place.
class WatchHistoryRepository {
  WatchHistoryRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  /// A history entry is considered "completed" once playback reaches
  /// this fraction of the video's duration — not exactly 100%, so
  /// end-credits/outros don't leave a watched video stuck at 97% forever.
  static const double completedThreshold = 0.95;

  /// Creates or updates the single history document for this
  /// (user, room) pair — see `WatchHistoryModel.buildId`. Called on a
  /// throttled interval and at key lifecycle points from the video
  /// player (pause, leave, backgrounded, disposed), never on every
  /// frame/tick and never before real playback has actually started.
  Future<void> upsertProgress({
    required String userId,
    required String roomId,
    required String videoTitle,
    required String videoUrl,
    String? backgroundImageUrl,
    required int lastPositionMs,
    required int durationMs,
  }) async {
    final String id = WatchHistoryModel.buildId(userId: userId, roomId: roomId);
    final double progress = durationMs > 0 ? (lastPositionMs / durationMs).clamp(0, 1) : 0.0;
    final DateTime now = DateTime.now();

    final entry = WatchHistoryModel(
      id: id,
      userId: userId,
      roomId: roomId,
      videoTitle: videoTitle,
      videoUrl: videoUrl,
      backgroundImageUrl: backgroundImageUrl,
      lastPositionMs: lastPositionMs,
      durationMs: durationMs,
      progress: progress,
      watchedAt: now,
      updatedAt: now,
      isCompleted: progress >= completedThreshold,
    );

    await _firestoreService.setDocument(
      FirestoreCollections.watchHistory,
      id,
      entry.toMap(),
      merge: true,
    );
  }

  /// Removes a single history record. [userId] is required (rather than
  /// trusting [historyId] alone) so a caller can never accidentally
  /// delete another user's entry by id alone.
  Future<void> removeEntry({required String userId, required String historyId}) async {
    if (!historyId.startsWith('${userId}_')) return;
    await _firestoreService.deleteDocument(FirestoreCollections.watchHistory, historyId);
  }

  /// Deletes every history record belonging to [userId].
  Future<void> clearHistory(String userId) async {
    final entries = await _firestoreService.runQuery(
      (ref) => ref.where('userId', isEqualTo: userId),
      FirestoreCollections.watchHistory,
    );
    if (entries.isEmpty) return;

    final batch = _firestoreService.batch();
    for (final entry in entries) {
      batch.delete(
        _firestoreService.collection(FirestoreCollections.watchHistory).doc(entry['id'] as String),
      );
    }
    await _firestoreService.commitBatch(batch);
  }

  Stream<List<WatchHistoryModel>> streamHistory(String userId, {int limit = 100}) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('userId', isEqualTo: userId)
              .orderBy('watchedAt', descending: true)
              .limit(limit),
          FirestoreCollections.watchHistory,
        )
        .map((docs) => docs.map((d) => WatchHistoryModel.fromMap(d['id'] as String, d)).toList());
  }
}
