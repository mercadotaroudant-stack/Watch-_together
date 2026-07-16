import '../../models/user_model.dart';

/// The three presence states the Friends screen (and its spec) draws as
/// a colored dot: 🟢 online, 🟠 away, ⚪ offline.
///
/// [UserModel] only persists a single `isOnline` boolean (see
/// `UserRepository.setOnlineStatus`) — there's no separate "away" flag
/// in Firestore. Rather than widen that schema for one screen, "away" is
/// derived client-side: a user who *isn't* actively marked online but was
/// seen very recently reads as away for a short grace window (e.g. their
/// app went to background a minute ago), and only falls to offline once
/// that window has passed.
enum PresenceStatus { online, away, offline }

/// The grace window after which a not-actively-online user is shown as
/// offline rather than away.
const Duration kAwayGracePeriod = Duration(minutes: 10);

PresenceStatus presenceOf(UserModel user) {
  if (user.isOnline) return PresenceStatus.online;
  final DateTime? lastSeen = user.lastSeenAt;
  if (lastSeen != null && DateTime.now().difference(lastSeen) < kAwayGracePeriod) {
    return PresenceStatus.away;
  }
  return PresenceStatus.offline;
}
