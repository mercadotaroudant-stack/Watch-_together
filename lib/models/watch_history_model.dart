import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';

/// Mirrors a document in the `watch_history` collection.
///
/// One document per (user, room) pair — see [buildId] — rather than one
/// per playback session. Rewatching or resuming the same room's video
/// updates the existing document instead of creating a new one, so the
/// History screen never shows duplicate rows for a single room.
class WatchHistoryModel extends Equatable {
  const WatchHistoryModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.videoTitle,
    required this.videoUrl,
    this.backgroundImageUrl,
    this.lastPositionMs = 0,
    this.durationMs = 0,
    this.progress = 0,
    required this.watchedAt,
    this.updatedAt,
    this.isCompleted = false,
  });

  final String id;
  final String userId;
  final String roomId;
  final String videoTitle;
  final String videoUrl;

  /// Carried over from `RoomModel.coverImageUrl` at the moment this
  /// entry is last saved, so the History screen can show a poster
  /// without an extra `RoomRepository.getRoom` lookup for a room that
  /// may have since ended.
  final String? backgroundImageUrl;

  /// The user's last saved playback position, in milliseconds.
  final int lastPositionMs;

  /// The video's total duration, in milliseconds, as known at the
  /// moment of the last save — `0` if unknown. Never guessed by the
  /// History screen itself; only ever written by the player.
  final int durationMs;

  /// `lastPositionMs / durationMs`, clamped to `[0, 1]` — `0` when
  /// [durationMs] is `0` (duration unknown). Stored alongside the raw
  /// values so simple list/sort queries don't need to recompute it, but
  /// the UI still treats it as derived data, not a source of truth.
  final double progress;

  /// The most recent time this room's video was watched — updated on
  /// every save, so both date-grouping and "watched X ago" reflect the
  /// latest session rather than when the record was first created.
  final DateTime watchedAt;

  final DateTime? updatedAt;

  final bool isCompleted;

  static String buildId({required String userId, required String roomId}) => '${userId}_$roomId';

  factory WatchHistoryModel.fromMap(String id, Map<String, dynamic> map) {
    return WatchHistoryModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      roomId: map['roomId'] as String? ?? '',
      videoTitle: map['videoTitle'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      backgroundImageUrl: map['backgroundImageUrl'] as String?,
      lastPositionMs: map['lastPositionMs'] as int? ?? 0,
      durationMs: map['durationMs'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      watchedAt: FirestoreConverters.timestampToDate(map['watchedAt']) ?? DateTime.now(),
      updatedAt: FirestoreConverters.timestampToDate(map['updatedAt']),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'roomId': roomId,
      'videoTitle': videoTitle,
      'videoUrl': videoUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'lastPositionMs': lastPositionMs,
      'durationMs': durationMs,
      'progress': progress,
      'watchedAt': FirestoreConverters.dateToTimestamp(watchedAt),
      'updatedAt': FirestoreConverters.dateToTimestamp(updatedAt),
      'isCompleted': isCompleted,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        roomId,
        videoTitle,
        videoUrl,
        backgroundImageUrl,
        lastPositionMs,
        durationMs,
        progress,
        watchedAt,
        updatedAt,
        isCompleted,
      ];
}
