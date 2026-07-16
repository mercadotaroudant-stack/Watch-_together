import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';

/// Mirrors a document in the `users` collection.
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    this.lastSeenAt,
    this.isOnline = false,
    this.isPremium = false,
    this.language = 'en',
    this.fcmTokens = const [],
    this.friendsCount = 0,
    this.roomsCreatedCount = 0,
    this.notifyRoomInvitations = true,
    this.notifyFriendRequests = true,
    this.notifyAppUpdates = true,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final bool isOnline;
  final bool isPremium;
  final String language;
  final List<String> fcmTokens;
  final int friendsCount;
  final int roomsCreatedCount;

  /// Per-category push-notification preferences, edited from My
  /// Profile's Notifications section (not the notification *inbox*).
  /// All default to `true` so existing users keep receiving
  /// notifications until they opt out.
  final bool notifyRoomInvitations;
  final bool notifyFriendRequests;
  final bool notifyAppUpdates;

  /// Lowercased [displayName], persisted as its own field (see
  /// [toMap]) purely so [UserRepository.searchByDisplayNameLowercasePrefix]
  /// can do a case-insensitive prefix query — Firestore's `startAt`/
  /// `endAt` range queries are byte-order (so case-sensitive) on the
  /// indexed field itself, and there's no server-side `LOWER()`.
  /// Computed, not stored on the constructor, so it can never drift
  /// from [displayName].
  String get displayNameLowercase => (displayName ?? '').toLowerCase();

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      createdAt: FirestoreConverters.timestampToDate(map['createdAt']) ?? DateTime.now(),
      lastSeenAt: FirestoreConverters.timestampToDate(map['lastSeenAt']),
      isOnline: map['isOnline'] as bool? ?? false,
      isPremium: map['isPremium'] as bool? ?? false,
      language: map['language'] as String? ?? 'en',
      fcmTokens: (map['fcmTokens'] as List<dynamic>?)?.cast<String>() ?? const [],
      friendsCount: map['friendsCount'] as int? ?? 0,
      roomsCreatedCount: map['roomsCreatedCount'] as int? ?? 0,
      notifyRoomInvitations: map['notifyRoomInvitations'] as bool? ?? true,
      notifyFriendRequests: map['notifyFriendRequests'] as bool? ?? true,
      notifyAppUpdates: map['notifyAppUpdates'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'displayNameLowercase': displayNameLowercase,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': FirestoreConverters.dateToTimestamp(createdAt),
      'lastSeenAt': FirestoreConverters.dateToTimestamp(lastSeenAt),
      'isOnline': isOnline,
      'isPremium': isPremium,
      'language': language,
      'fcmTokens': fcmTokens,
      'friendsCount': friendsCount,
      'roomsCreatedCount': roomsCreatedCount,
      'notifyRoomInvitations': notifyRoomInvitations,
      'notifyFriendRequests': notifyFriendRequests,
      'notifyAppUpdates': notifyAppUpdates,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? lastSeenAt,
    bool? isOnline,
    bool? isPremium,
    String? language,
    List<String>? fcmTokens,
    int? friendsCount,
    int? roomsCreatedCount,
    bool? notifyRoomInvitations,
    bool? notifyFriendRequests,
    bool? notifyAppUpdates,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isOnline: isOnline ?? this.isOnline,
      isPremium: isPremium ?? this.isPremium,
      language: language ?? this.language,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      friendsCount: friendsCount ?? this.friendsCount,
      roomsCreatedCount: roomsCreatedCount ?? this.roomsCreatedCount,
      notifyRoomInvitations: notifyRoomInvitations ?? this.notifyRoomInvitations,
      notifyFriendRequests: notifyFriendRequests ?? this.notifyFriendRequests,
      notifyAppUpdates: notifyAppUpdates ?? this.notifyAppUpdates,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        bio,
        createdAt,
        lastSeenAt,
        isOnline,
        isPremium,
        language,
        fcmTokens,
        friendsCount,
        roomsCreatedCount,
        notifyRoomInvitations,
        notifyFriendRequests,
        notifyAppUpdates,
      ];
}
