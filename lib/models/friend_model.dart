import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in either the `friends` or `friend_requests`
/// collection — both share this shape; which collection a given instance
/// came from is a repository-level concern (see `FriendRepository`), not
/// something encoded on the model itself.
///
/// Document id convention: the two user ids sorted and joined, e.g.
/// `'{lowerUid}_{higherUid}'`, so a pair only ever has one relationship
/// document regardless of who initiated it.
class FriendModel extends Equatable {
  const FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    this.status = FriendStatus.pending,
    required this.requestedBy,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String friendId;
  final FriendStatus status;
  final String requestedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  static String buildId({required String userIdA, required String userIdB}) {
    final List<String> sorted = [userIdA, userIdB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  factory FriendModel.fromMap(String id, Map<String, dynamic> map) {
    return FriendModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      friendId: map['friendId'] as String? ?? '',
      status: FriendStatusX.fromValue(map['status'] as String?),
      requestedBy: map['requestedBy'] as String? ?? '',
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: FirestoreConverters.timestampToDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'status': status.name,
      'requestedBy': requestedBy,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
      'updatedAt': FirestoreConverters.dateToTimestamp(updatedAt),
    };
  }

  FriendModel copyWith({FriendStatus? status, DateTime? updatedAt}) {
    return FriendModel(
      id: id,
      userId: userId,
      friendId: friendId,
      status: status ?? this.status,
      requestedBy: requestedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, friendId, status, requestedBy, createdAt, updatedAt];
}
