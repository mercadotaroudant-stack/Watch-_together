import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/firebase_error_mapper.dart';
import '../models/participant_model.dart';
import '../models/room_model.dart';
import 'firestore_service.dart';

/// Room-specific Firestore operations that span both the `rooms` and
/// `participants` collections.
///
/// Kept distinct from the generic [FirestoreService] (which this builds
/// on) because "create a room" and "join a room" are each really two
/// writes — a room document and a participant document — that need to
/// stay consistent with each other; that composite logic belongs here,
/// not duplicated across every call site.
class RoomService {
  RoomService(this._firestoreService, [FirebaseFirestore? firestore])
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirestoreService _firestoreService;
  final FirebaseFirestore _db;

  /// Creates the room document and the host's own participant document
  /// in a single atomic write.
  Future<RoomModel> createRoom(RoomModel room, ParticipantModel host) async {
    try {
      final batch = _db.batch();
      final roomRef = _db.collection(FirestoreCollections.rooms).doc(room.id);
      final participantRef =
          _db.collection(FirestoreCollections.participants).doc(host.id);

      batch.set(roomRef, room.toMap());
      batch.set(participantRef, host.toMap());

      await batch.commit();
      return room;
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  /// Adds [participant] to [roomId] and appends their id to the room's
  /// `participantIds` array, refusing if the room is already full or
  /// doesn't exist.
  Future<void> joinRoom({
    required String roomId,
    required ParticipantModel participant,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final roomRef = _db.collection(FirestoreCollections.rooms).doc(roomId);
        final roomSnap = await transaction.get(roomRef);

        if (!roomSnap.exists) {
          throw const DomainException('This room no longer exists.');
        }
        final room = RoomModel.fromMap(roomSnap.id, roomSnap.data()!);
        if (room.isFull && !room.participantIds.contains(participant.userId)) {
          throw const DomainException('This room is full.');
        }

        final participantRef =
            _db.collection(FirestoreCollections.participants).doc(participant.id);
        transaction.set(participantRef, participant.toMap());
        transaction.update(roomRef, {
          'participantIds': FieldValue.arrayUnion([participant.userId]),
          'updatedAt': Timestamp.now(),
        });
      });
    } on DomainException {
      rethrow;
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  /// Removes a participant from a room, deleting their participant
  /// document and pulling their id out of `participantIds`.
  Future<void> leaveRoom({required String roomId, required String userId}) async {
    try {
      final batch = _db.batch();
      final roomRef = _db.collection(FirestoreCollections.rooms).doc(roomId);
      final participantRef = _db
          .collection(FirestoreCollections.participants)
          .doc(ParticipantModel.buildId(roomId: roomId, userId: userId));

      batch.delete(participantRef);
      batch.update(roomRef, {
        'participantIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  /// Updates playback state (position/play-pause) — called frequently
  /// during a watch party, so it intentionally only touches the small
  /// set of fields that change rather than rewriting the whole room.
  Future<void> updatePlaybackState({
    required String roomId,
    required int currentPositionMs,
    required bool isPlaying,
  }) async {
    await _firestoreService.updateDocument(FirestoreCollections.rooms, roomId, {
      'currentPositionMs': currentPositionMs,
      'isPlaying': isPlaying,
      'lastSyncedAt': Timestamp.now(),
    });
  }

  Future<void> endRoom(String roomId) async {
    await _firestoreService.updateDocument(FirestoreCollections.rooms, roomId, {
      'status': 'ended',
      'isPlaying': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<RoomModel?> streamRoom(String roomId) {
    return _firestoreService
        .streamDocument(FirestoreCollections.rooms, roomId)
        .map((data) => data == null ? null : RoomModel.fromMap(roomId, data));
  }

  Stream<List<ParticipantModel>> streamParticipants(String roomId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref.where('roomId', isEqualTo: roomId),
          FirestoreCollections.participants,
        )
        .map(
          (docs) => docs
              .map((d) => ParticipantModel.fromMap(d['id'] as String, d))
              .toList(),
        );
  }

  /// Host-only removal (kick) of another participant — the Participants
  /// bottom sheet's "Remove from Room" action. Same shape as [leaveRoom]
  /// (delete the participant doc, pull the id out of the room's
  /// `participantIds`) since it's the same underlying state change,
  /// just host-initiated against someone else rather than self-initiated.
  Future<void> removeParticipant({
    required String roomId,
    required String userId,
  }) async {
    try {
      final batch = _db.batch();
      final roomRef = _db.collection(FirestoreCollections.rooms).doc(roomId);
      final participantRef = _db
          .collection(FirestoreCollections.participants)
          .doc(ParticipantModel.buildId(roomId: roomId, userId: userId));

      batch.delete(participantRef);
      batch.update(roomRef, {
        'participantIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  /// Flips a participant's role — currently only used to promote a
  /// member to moderator from the Participants bottom sheet's (...)
  /// menu. Doesn't touch `hostId`/host role; see
  /// [RoomRepository.leaveRoomAndTransferHostIfNeeded] for how host
  /// transfer is handled separately.
  Future<void> updateParticipantRole({
    required String participantId,
    required String role,
  }) async {
    await _firestoreService.updateDocument(
      FirestoreCollections.participants,
      participantId,
      {'role': role},
    );
  }
}
