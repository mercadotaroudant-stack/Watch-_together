import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `notifications` collection.
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.userId,
    this.type = NotificationType.system,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;

  /// Arbitrary payload (e.g. `{'roomId': '...'}`) used to deep-link when
  /// the notification is tapped. Kept as a raw map since its shape
  /// depends on [type].
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: NotificationTypeX.fromValue(map['type'] as String?),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: (map['data'] as Map<String, dynamic>?) ?? const {},
      isRead: map['isRead'] as bool? ?? false,
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, type, title, body, data, isRead, createdAt];
}
