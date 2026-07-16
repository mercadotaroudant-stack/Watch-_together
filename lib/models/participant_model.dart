import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `participants` collection.
///
/// Document id convention: `'{roomId}_{userId}'`, so a participant's
/// membership in a specific room can be looked up or written directly by
/// id (see `RoomRepository`) without a query.
class ParticipantModel extends Equatable {
  const ParticipantModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.role = ParticipantRole.member,
    required this.joinedAt,
    this.isMuted = false,
    this.isOnline = true,
    this.lastActiveAt,
  });

  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final ParticipantRole role;
  final DateTime joinedAt;
  final bool isMuted;
  final bool isOnline;
  final DateTime? lastActiveAt;

  static String buildId({required String roomId, required String userId}) =>
      '${roomId}_$userId';

  factory ParticipantModel.fromMap(String id, Map<String, dynamic> map) {
    return ParticipantModel(
      id: id,
      roomId: map['roomId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: ParticipantRoleX.fromValue(map['role'] as String?),
      joinedAt: FirestoreConverters.timestampToDate(map['joinedAt']) ?? DateTime.now(),
      isMuted: map['isMuted'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? true,
      lastActiveAt: FirestoreConverters.timestampToDate(map['lastActiveAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'joinedAt': FirestoreConverters.dateToTimestamp(joinedAt),
      'isMuted': isMuted,
      'isOnline': isOnline,
      'lastActiveAt': FirestoreConverters.dateToTimestamp(lastActiveAt),
    };
  }

  ParticipantModel copyWith({
    ParticipantRole? role,
    bool? isMuted,
    bool? isOnline,
    DateTime? lastActiveAt,
  }) {
    return ParticipantModel(
      id: id,
      roomId: roomId,
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role ?? this.role,
      joinedAt: joinedAt,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        displayName,
        photoUrl,
        role,
        joinedAt,
        isMuted,
        isOnline,
        lastActiveAt,
      ];
}
