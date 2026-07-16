/// The four states a search result's Add Friend button can be in — the
/// source of truth is always real relationship data (see
/// [friendRelationshipStatusFor]), never local-only UI state, per spec.
enum FriendRelationshipStatus {
  /// No relationship — show "Add Friend".
  none,

  /// The current user already sent this person a request — show
  /// "Request Sent" (non-actionable here; cancel lives on the Sent
  /// Requests tab).
  requestSent,

  /// This person already sent the current user a request — show
  /// "Accept".
  requestReceived,

  /// Already friends — show "Friends" (non-actionable).
  friends,
}

/// Derives [FriendRelationshipStatus] for [uid] purely by checking
/// membership in the three already-live sets the Friends screen (and
/// this feature) keep around anyway — [liveFriendsProvider],
/// [liveFriendRequestsProvider], and [liveSentRequestsProvider]. No
/// extra Firestore read is needed per search result.
FriendRelationshipStatus friendRelationshipStatusFor({
  required String uid,
  required Set<String> friendIds,
  required Set<String> incomingRequesterIds,
  required Set<String> outgoingRecipientIds,
}) {
  if (friendIds.contains(uid)) return FriendRelationshipStatus.friends;
  if (incomingRequesterIds.contains(uid)) return FriendRelationshipStatus.requestReceived;
  if (outgoingRecipientIds.contains(uid)) return FriendRelationshipStatus.requestSent;
  return FriendRelationshipStatus.none;
}
