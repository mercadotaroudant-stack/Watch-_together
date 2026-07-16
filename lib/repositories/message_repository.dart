import '../core/constants/firestore_collections.dart';
import '../models/enums.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

/// Chat messages for a room (`messages` collection, each document
/// carrying its own `roomId` rather than living in a subcollection, so a
/// single collection-group-free query can page/stream a room's history).
class MessageRepository {
  MessageRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final String id = _firestoreService.newDocumentId(FirestoreCollections.messages);
    final message = MessageModel(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      type: type,
      createdAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.messages,
      id,
      message.toMap(),
      merge: false,
    );
    return message;
  }

  Future<void> deleteMessage(String messageId) {
    return _firestoreService.updateDocument(
      FirestoreCollections.messages,
      messageId,
      {'isDeleted': true},
    );
  }

  /// Most recent [limit] messages for a room, newest first — callers
  /// reverse for display if they want oldest-first chat order.
  Stream<List<MessageModel>> streamMessages(String roomId, {int limit = 50}) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('roomId', isEqualTo: roomId)
              .orderBy('createdAt', descending: true)
              .limit(limit),
          FirestoreCollections.messages,
        )
        .map((docs) => docs.map((d) => MessageModel.fromMap(d['id'] as String, d)).toList());
  }
}
