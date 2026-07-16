import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `join_requests` collection.
///
/// Created when someone asks to join a room whose owner reviews joins
/// before they happen (the Video Player Participants panel's "Ahmed
/// wants to join" card, Phase 3.8) rather than joining outright the way
/// `RoomRepository.joinRoom` does today. Resolved requests aren't kept
/// around as history — `RoomRepository.acceptJoinRequest`/
/// `rejectJoinRequest` delete the document once handled — so [status]
/// only meaningfully takes the value `pending` in practice; it's still
/// modeled as an enum (rather than assuming every document is pending)
/// for the same "don't trust stale/partial data" reason every other
/// model here parses defensively.
class JoinRequestModel extends Equatable {
  const JoinRequestModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.requestedAt,
    this.status = JoinRequestStatus.pending,
  });

  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final DateTime requestedAt;
  final JoinRequestStatus status;

  factory JoinRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return JoinRequestModel(
      id: id,
      roomId: map['roomId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      requestedAt: FirestoreConverters.timestampToDate(map['requestedAt']) ?? DateTime.now(),
      status: JoinRequestStatusX.fromValue(map['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'requestedAt': FirestoreConverters.dateToTimestamp(requestedAt),
      'status': status.name,
    };
  }

  @override
  List<Object?> get props => [id, roomId, userId, displayName, photoUrl, requestedAt, status];
}
