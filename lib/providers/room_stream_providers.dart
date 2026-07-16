import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/join_request_model.dart';
import '../models/message_model.dart';
import '../models/participant_model.dart';
import '../models/room_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// Realtime room/participants/chat/join-request streams, keyed by
/// `roomId`.
///
/// `RoomService.streamRoom`/`streamParticipants` were built in Phase 2
/// but had no caller until the Video Player (Phase 3.8) — this file is
/// just the thin Riverpod wiring so a `ConsumerWidget` can
/// `ref.watch(roomStreamProvider(roomId))` instead of managing
/// subscriptions by hand.
///
/// All four are `autoDispose`: [VideoPlayerScreen] is the only current
/// watcher, so once it's popped these should drop their Firestore
/// listeners rather than staying subscribed forever the way a plain
/// (non-autoDispose) provider would.
final AutoDisposeStreamProviderFamily<RoomModel?, String> roomStreamProvider =
    StreamProvider.autoDispose.family<RoomModel?, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).streamRoom(roomId);
});

final AutoDisposeStreamProviderFamily<List<ParticipantModel>, String> participantsStreamProvider =
    StreamProvider.autoDispose.family<List<ParticipantModel>, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).streamParticipants(roomId);
});

/// Newest-first, per `MessageRepository.streamMessages`'s own contract
/// — the Video Player's chat panel reverses it for display; the system
/// message toast overlay reads it as-is (newest first is exactly what
/// it needs to notice a just-arrived join/leave message).
final AutoDisposeStreamProviderFamily<List<MessageModel>, String> messagesStreamProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, roomId) {
  return ref.watch(messageRepositoryProvider).streamMessages(roomId);
});

final AutoDisposeStreamProviderFamily<List<JoinRequestModel>, String>
    pendingJoinRequestsStreamProvider =
    StreamProvider.autoDispose.family<List<JoinRequestModel>, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).streamPendingJoinRequests(roomId);
});

/// The signed-in user's own rooms (as host) — Active/Ended tabs on the
/// My Rooms screen. `null`/empty while signed out. There is no
/// "Scheduled" state here because [RoomModel] has no scheduling field
/// yet — see `MyRoomsScreen`'s doc comment.
final StreamProvider<List<RoomModel>> myRoomsProvider = StreamProvider<List<RoomModel>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream<List<RoomModel>>.value(const []);
  return ref.watch(roomRepositoryProvider).streamRoomsHostedBy(uid);
});
