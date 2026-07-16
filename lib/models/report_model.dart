import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `reports` collection.
///
/// A report always has a [reporterId]; exactly which of [reportedUserId],
/// [roomId], [messageId] is set depends on what's being reported (a user,
/// a room, or a specific message) — callers set the one(s) relevant to
/// the context they reported from.
class ReportModel extends Equatable {
  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.roomId,
    this.messageId,
    this.reason = ReportReason.other,
    this.description,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.reviewedAt,
  });

  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? roomId;
  final String? messageId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] as String? ?? '',
      reportedUserId: map['reportedUserId'] as String?,
      roomId: map['roomId'] as String?,
      messageId: map['messageId'] as String?,
      reason: ReportReasonX.fromValue(map['reason'] as String?),
      description: map['description'] as String?,
      status: ReportStatusX.fromValue(map['status'] as String?),
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
      reviewedAt: FirestoreConverters.timestampToDate(map['reviewedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'roomId': roomId,
      'messageId': messageId,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
      'reviewedAt': FirestoreConverters.dateToTimestamp(reviewedAt),
    };
  }

  ReportModel copyWith({ReportStatus? status, DateTime? reviewedAt}) {
    return ReportModel(
      id: id,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      roomId: roomId,
      messageId: messageId,
      reason: reason,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reportedUserId,
        roomId,
        messageId,
        reason,
        description,
        status,
        createdAt,
        reviewedAt,
      ];
}
