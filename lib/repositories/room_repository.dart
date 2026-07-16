import '../core/constants/firestore_collections.dart';
import '../models/enums.dart';
import '../models/join_request_model.dart';
import '../models/participant_model.dart';
import '../models/room_model.dart';
import '../services/firestore_service.dart';
import '../services/room_service.dart';

/// Typed entry point for everything room-related, backed by
/// [RoomService] (composite room+participant writes) and
/// [FirestoreService] (simple room reads/queries).
class RoomRepository {
  RoomRepository({
    required RoomService roomService,
    required FirestoreService firestoreService,
  })  : _roomService = roomService,
        _firestoreService = firestoreService;

  final RoomService _roomService;
  final FirestoreService _firestoreService;

  Future<RoomModel> createRoom({
    required String hostId,
    required String hostDisplayName,
    String? hostPhotoUrl,
    required String title,
    String? description,
    required String videoUrl,
    VideoSource videoSource = VideoSource.direct,
    bool isPrivate = false,
    String? passcode,
    int maxParticipants = 10,
    String? coverImageUrl,
    bool allowVoiceChat = true,
    bool allowChat = true,
    bool allowScreenControl = true,
    bool startWithMutedAudio = false,
  }) async {
    final String roomId = _firestoreService.newDocumentId(FirestoreCollections.rooms);
    final now = DateTime.now();

    final room = RoomModel(
      id: roomId,
      hostId: hostId,
      title: title,
      description: description,
      videoUrl: videoUrl,
      videoSource: videoSource,
      isPrivate: isPrivate,
      passcode: passcode,
      createdAt: now,
      participantIds: [hostId],
      maxParticipants: maxParticipants,
      coverImageUrl: coverImageUrl,
      allowVoiceChat: allowVoiceChat,
      allowChat: allowChat,
      allowScreenControl: allowScreenControl,
      startWithMutedAudio: startWithMutedAudio,
    );

    final host = ParticipantModel(
      id: ParticipantModel.buildId(roomId: roomId, userId: hostId),
      roomId: roomId,
      userId: hostId,
      displayName: hostDisplayName,
      photoUrl: hostPhotoUrl,
      role: ParticipantRole.host,
      joinedAt: now,
    );

    return _roomService.createRoom(room, host);
  }

  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String displayName,
    String? photoUrl,
  }) {
    final participant = ParticipantModel(
      id: ParticipantModel.buildId(roomId: roomId, userId: userId),
      roomId: roomId,
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      joinedAt: DateTime.now(),
    );
    return _roomService.joinRoom(roomId: roomId, participant: participant);
  }

  Future<void> leaveRoom({required String roomId, required String userId}) =>
      _roomService.leaveRoom(roomId: roomId, userId: userId);

  Future<void> updatePlaybackState({
    required String roomId,
    required int currentPositionMs,
    required bool isPlaying,
  }) =>
      _roomService.updatePlaybackState(
        roomId: roomId,
        currentPositionMs: currentPositionMs,
        isPlaying: isPlaying,
      );

  Future<void> endRoom(String roomId) => _roomService.endRoom(roomId);

  Future<RoomModel?> getRoom(String roomId) async {
    final data = await _firestoreService.getDocument(FirestoreCollections.rooms, roomId);
    return data == null ? null : RoomModel.fromMap(roomId, data);
  }

  Stream<RoomModel?> streamRoom(String roomId) => _roomService.streamRoom(roomId);

  Stream<List<ParticipantModel>> streamParticipants(String roomId) =>
      _roomService.streamParticipants(roomId);

  /// Public, joinable rooms — used for a future "browse rooms" screen.
  Future<List<RoomModel>> getPublicRooms({int limit = 20}) async {
    final results = await _firestoreService.runQuery(
      (ref) => ref
          .where('isPrivate', isEqualTo: false)
          .where('status', whereIn: [RoomStatus.waiting.name, RoomStatus.playing.name])
          .orderBy('createdAt', descending: true)
          .limit(limit),
      FirestoreCollections.rooms,
    );
    return results.map((d) => RoomModel.fromMap(d['id'] as String, d)).toList();
  }

  /// Live version of [getPublicRooms] — the Home screen's "Public
  /// Rooms" section watches this instead of a one-shot fetch so newly
  /// created/ended public rooms appear without a manual refresh.
  /// [limit] bounds how many documents Firestore streams at once, per
  /// the Home spec's "don't load every room at once" requirement.
  Stream<List<RoomModel>> streamPublicRooms({int limit = 20}) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('isPrivate', isEqualTo: false)
              .where('status', whereIn: [RoomStatus.waiting.name, RoomStatus.playing.name])
              .orderBy('createdAt', descending: true)
              .limit(limit),
          FirestoreCollections.rooms,
        )
        .map((docs) => docs.map((d) => RoomModel.fromMap(d['id'] as String, d)).toList());
  }

  Stream<List<RoomModel>> streamRoomsHostedBy(String hostId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref.where('hostId', isEqualTo: hostId).orderBy('createdAt', descending: true),
          FirestoreCollections.rooms,
        )
        .map((docs) => docs.map((d) => RoomModel.fromMap(d['id'] as String, d)).toList());
  }

  // --- Video Player (Phase 3.8) -------------------------------------

  /// Flips a single participant's mic state — the Video Player's own
  /// mic toggle, kept separate from the broader [ParticipantModel]
  /// object so a client only ever writes the one field it actually
  /// changed.
  Future<void> updateParticipantMuted({
    required String participantId,
    required bool isMuted,
  }) {
    return _firestoreService.updateDocument(
      FirestoreCollections.participants,
      participantId,
      {'isMuted': isMuted},
    );
  }

  /// Removes [leavingUserId] from [room] (via [leaveRoom]) and, if they
  /// were the host and other participants remain, promotes whichever of
  /// [participants] joined earliest to host — both the room's own
  /// `hostId` and that participant's `role` — so a room never ends up
  /// hostless just because its creator left first. A no-op transfer
  /// (leaving participant wasn't the host, or was the last one left) is
  /// just the plain [leaveRoom] call.
  Future<void> leaveRoomAndTransferHostIfNeeded({
    required RoomModel room,
    required List<ParticipantModel> participants,
    required String leavingUserId,
  }) async {
    final bool wasHost = room.hostId == leavingUserId;
    final List<ParticipantModel> remaining =
        participants.where((p) => p.userId != leavingUserId).toList()
          ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    await leaveRoom(roomId: room.id, userId: leavingUserId);

    if (wasHost && remaining.isNotEmpty) {
      final ParticipantModel newHost = remaining.first;
      final batch = _firestoreService.batch();
      batch.update(
        _firestoreService.collection(FirestoreCollections.rooms).doc(room.id),
        {'hostId': newHost.userId},
      );
      batch.update(
        _firestoreService.collection(FirestoreCollections.participants).doc(newHost.id),
        {'role': ParticipantRole.host.name},
      );
      await _firestoreService.commitBatch(batch);
    }
  }

  /// Records that [userId] wants to join [roomId] without joining them
  /// outright — the room owner reviews it (see [streamPendingJoinRequests]
  /// / [acceptJoinRequest] / [rejectJoinRequest]) via the Video Player's
  /// Participants panel. Nothing in the app calls this yet — it's ready
  /// for whenever a "browse public rooms" screen exists to call it from;
  /// see the README.
  Future<JoinRequestModel> requestToJoin({
    required String roomId,
    required String userId,
    required String displayName,
    String? photoUrl,
  }) async {
    final String id = _firestoreService.newDocumentId(FirestoreCollections.joinRequests);
    final request = JoinRequestModel(
      id: id,
      roomId: roomId,
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      requestedAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.joinRequests,
      id,
      request.toMap(),
      merge: false,
    );
    return request;
  }

  Stream<List<JoinRequestModel>> streamPendingJoinRequests(String roomId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('roomId', isEqualTo: roomId)
              .where('status', isEqualTo: JoinRequestStatus.pending.name),
          FirestoreCollections.joinRequests,
        )
        .map((docs) => docs.map((d) => JoinRequestModel.fromMap(d['id'] as String, d)).toList());
  }

  /// Admits [request]'s requester as a real participant, then removes
  /// the request. Not atomic with [joinRoom] (two separate writes) —
  /// an acceptable gap for a request a human just approved by hand,
  /// versus the concurrency [joinRoom] itself guards against with a
  /// transaction.
  Future<void> acceptJoinRequest(JoinRequestModel request) async {
    await joinRoom(
      roomId: request.roomId,
      userId: request.userId,
      displayName: request.displayName,
      photoUrl: request.photoUrl,
    );
    await _firestoreService.deleteDocument(FirestoreCollections.joinRequests, request.id);
  }

  Future<void> rejectJoinRequest(JoinRequestModel request) =>
      _firestoreService.deleteDocument(FirestoreCollections.joinRequests, request.id);

  /// The signed-in user's own pending request to join [roomId], if any
  /// — real-time so the Home screen's Public Rooms "Waiting for admin
  /// approval" state reflects the actual `join_requests` document
  /// rather than only local UI state. Emits `null` once the host
  /// accepts/rejects (both delete the document, per this class's own
  /// [acceptJoinRequest]/[rejectJoinRequest]) — callers distinguish the
  /// two by checking whether the user is now in [RoomModel.participantIds].
  ///
  /// Requires a Firestore composite index on `join_requests`
  /// (`roomId` ASC, `userId` ASC) — see README/backend notes.
  Stream<JoinRequestModel?> streamMyJoinRequestForRoom({
    required String roomId,
    required String userId,
  }) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('roomId', isEqualTo: roomId)
              .where('userId', isEqualTo: userId)
              .limit(1),
          FirestoreCollections.joinRequests,
        )
        .map(
          (docs) =>
              docs.isEmpty ? null : JoinRequestModel.fromMap(docs.first['id'] as String, docs.first),
        );
  }

  /// Host-only kick — see [RoomService.removeParticipant].
  Future<void> removeParticipant({required String roomId, required String userId}) =>
      _roomService.removeParticipant(roomId: roomId, userId: userId);

  /// Promotes [participantId] to [ParticipantRole.moderator] — the
  /// Participants bottom sheet's "Make Moderator" action.
  Future<void> promoteToModerator(String participantId) => _roomService.updateParticipantRole(
        participantId: participantId,
        role: ParticipantRole.moderator.name,
      );
}
