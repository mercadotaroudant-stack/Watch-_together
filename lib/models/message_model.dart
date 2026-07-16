import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `messages` collection (room chat).
class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isDeleted = false,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isDeleted;

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      roomId: map['roomId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderPhotoUrl: map['senderPhotoUrl'] as String?,
      content: map['content'] as String? ?? '',
      type: MessageTypeX.fromValue(map['type'] as String?),
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'content': content,
      'type': type.name,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
      'isDeleted': isDeleted,
    };
  }

  MessageModel copyWith({String? content, bool? isDeleted}) {
    return MessageModel(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content ?? this.content,
      type: type,
      createdAt: createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderPhotoUrl,
        content,
        type,
        createdAt,
        isDeleted,
      ];
}
