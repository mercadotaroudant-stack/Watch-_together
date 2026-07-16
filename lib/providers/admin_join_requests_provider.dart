import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../models/enums.dart';
import '../models/join_request_model.dart';
import '../models/room_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// A single pending join request, paired with the (already-loaded) room
/// it's for — the Notifications screen's admin-facing "X wants to join
/// Y" card needs both together, and re-fetching the room per request
/// would be wasteful when [myPendingJoinRequestsProvider] already has
/// it from the same fan-out.
class AdminJoinRequestItem extends Equatable {
  const AdminJoinRequestItem({required this.request, required this.room});

  final JoinRequestModel request;
  final RoomModel room;

  @override
  List<Object?> get props => [request, room];
}

/// Every pending join request across every room the signed-in user
/// hosts, live — reuses `RoomRepository.streamRoomsHostedBy` (the same
/// stream `myRoomsProvider` is built on) and, per hosted room,
/// `RoomRepository.streamPendingJoinRequests` (the same stream the
/// Video Player's Participants panel already uses for a single room).
/// No new Firestore query shape is introduced; this only fans the
/// existing per-room stream out across a host's rooms and flattens the
/// result, the same `Rx.combineLatestList` idiom
/// `friends_screen_provider.dart`'s `liveFriendsProvider` already uses
/// for an analogous one-to-many join.
///
/// Ended rooms are excluded — a request against a room that's already
/// over has nothing left to accept into.
final StreamProvider<List<AdminJoinRequestItem>> myPendingJoinRequestsProvider =
    StreamProvider<List<AdminJoinRequestItem>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);

  final roomRepository = ref.watch(roomRepositoryProvider);

  return roomRepository.streamRoomsHostedBy(uid).switchMap((rooms) {
    final List<RoomModel> activeRooms =
        rooms.where((room) => room.status != RoomStatus.ended).toList();
    if (activeRooms.isEmpty) return Stream.value(const <AdminJoinRequestItem>[]);

    final List<Stream<List<AdminJoinRequestItem>>> perRoomStreams = activeRooms.map((room) {
      return roomRepository.streamPendingJoinRequests(room.id).map(
            (requests) => requests.map((r) => AdminJoinRequestItem(request: r, room: room)).toList(),
          );
    }).toList();

    return Rx.combineLatestList<List<AdminJoinRequestItem>>(perRoomStreams).map((lists) {
      final List<AdminJoinRequestItem> flattened = lists.expand((l) => l).toList()
        ..sort((a, b) => b.request.requestedAt.compareTo(a.request.requestedAt));
      return flattened;
    });
  });
});
