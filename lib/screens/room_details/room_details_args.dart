import '../../models/participant_model.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';

/// The typed payload passed via go_router's `extra` when navigating to
/// [RouteNames.roomDetails].
///
/// Bundling the already-loaded [room], [host], and [participants]
/// together means a caller that already has this data (e.g. a future
/// room list screen backed by `RoomRepository`/`UserRepository` from
/// Phase 2) doesn't need to re-fetch it just to open this screen.
class RoomDetailsArgs {
  const RoomDetailsArgs({
    required this.room,
    required this.host,
    required this.participants,
  });

  final RoomModel room;
  final UserModel host;
  final List<ParticipantModel> participants;
}
