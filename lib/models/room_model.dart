import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `rooms` collection.
///
/// Individual participants live in the separate `participants`
/// collection (see [ParticipantModel]) rather than as an embedded array,
/// so presence/role updates don't require rewriting the whole room
/// document and so Firestore security rules can scope writes per
/// participant.
class RoomModel extends Equatable {
  const RoomModel({
    required this.id,
    required this.hostId,
    required this.title,
    this.description,
    required this.videoUrl,
    this.videoSource = VideoSource.direct,
    this.isPrivate = false,
    this.passcode,
    required this.createdAt,
    this.updatedAt,
    this.status = RoomStatus.waiting,
    this.participantIds = const [],
    this.maxParticipants = 10,
    this.currentPositionMs = 0,
    this.isPlaying = false,
    this.lastSyncedAt,
    this.coverImageUrl,
    this.allowVoiceChat = true,
    this.allowChat = true,
    this.allowScreenControl = true,
    this.startWithMutedAudio = false,
  });

  final String id;
  final String hostId;
  final String title;
  final String? description;
  final String videoUrl;
  final VideoSource videoSource;
  final bool isPrivate;
  final String? passcode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RoomStatus status;
  final List<String> participantIds;
  final int maxParticipants;
  final int currentPositionMs;
  final bool isPlaying;
  final DateTime? lastSyncedAt;

  /// Optional movie poster / background chosen at creation (Create Room,
  /// Phase 3.7). Null falls back to a default gradient cover wherever
  /// this room is displayed (Public Rooms list, Room Details).
  final String? coverImageUrl;

  /// The four "More Settings" toggles from Create Room. Voice/text chat
  /// and letting non-host participants control playback (pause/play/
  /// seek) default to allowed; joining pre-muted defaults to off.
  final bool allowVoiceChat;
  final bool allowChat;
  final bool allowScreenControl;
  final bool startWithMutedAudio;

  bool get isFull => participantIds.length >= maxParticipants;

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      hostId: map['hostId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      videoUrl: map['videoUrl'] as String? ?? '',
      videoSource: VideoSourceX.fromValue(map['videoSource'] as String?),
      isPrivate: map['isPrivate'] as bool? ?? false,
      passcode: map['passcode'] as String?,
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: FirestoreConverters.timestampToDate(map['updatedAt']),
      status: RoomStatusX.fromValue(map['status'] as String?),
      participantIds: (map['participantIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      maxParticipants: map['maxParticipants'] as int? ?? 10,
      currentPositionMs: map['currentPositionMs'] as int? ?? 0,
      isPlaying: map['isPlaying'] as bool? ?? false,
      lastSyncedAt: FirestoreConverters.timestampToDate(map['lastSyncedAt']),
      coverImageUrl: map['coverImageUrl'] as String?,
      allowVoiceChat: map['allowVoiceChat'] as bool? ?? true,
      allowChat: map['allowChat'] as bool? ?? true,
      allowScreenControl: map['allowScreenControl'] as bool? ?? true,
      startWithMutedAudio: map['startWithMutedAudio'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'videoSource': videoSource.name,
      'isPrivate': isPrivate,
      'passcode': passcode,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
      'updatedAt': FirestoreConverters.dateToTimestamp(updatedAt),
      'status': status.name,
      'participantIds': participantIds,
      'maxParticipants': maxParticipants,
      'currentPositionMs': currentPositionMs,
      'isPlaying': isPlaying,
      'lastSyncedAt': FirestoreConverters.dateToTimestamp(lastSyncedAt),
      'coverImageUrl': coverImageUrl,
      'allowVoiceChat': allowVoiceChat,
      'allowChat': allowChat,
      'allowScreenControl': allowScreenControl,
      'startWithMutedAudio': startWithMutedAudio,
    };
  }

  RoomModel copyWith({
    String? title,
    String? description,
    String? videoUrl,
    VideoSource? videoSource,
    bool? isPrivate,
    String? passcode,
    DateTime? updatedAt,
    RoomStatus? status,
    List<String>? participantIds,
    int? maxParticipants,
    int? currentPositionMs,
    bool? isPlaying,
    DateTime? lastSyncedAt,
    String? coverImageUrl,
    bool? allowVoiceChat,
    bool? allowChat,
    bool? allowScreenControl,
    bool? startWithMutedAudio,
  }) {
    return RoomModel(
      id: id,
      hostId: hostId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      videoSource: videoSource ?? this.videoSource,
      isPrivate: isPrivate ?? this.isPrivate,
      passcode: passcode ?? this.passcode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentPositionMs: currentPositionMs ?? this.currentPositionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      allowVoiceChat: allowVoiceChat ?? this.allowVoiceChat,
      allowChat: allowChat ?? this.allowChat,
      allowScreenControl: allowScreenControl ?? this.allowScreenControl,
      startWithMutedAudio: startWithMutedAudio ?? this.startWithMutedAudio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hostId,
        title,
        description,
        videoUrl,
        videoSource,
        isPrivate,
        passcode,
        createdAt,
        updatedAt,
        status,
        participantIds,
        maxParticipants,
        currentPositionMs,
        isPlaying,
        lastSyncedAt,
        coverImageUrl,
        allowVoiceChat,
        allowChat,
        allowScreenControl,
        startWithMutedAudio,
      ];
}
