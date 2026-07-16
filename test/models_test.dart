import 'package:flutter_test/flutter_test.dart';
import 'package:watchtogether/models/enums.dart';
import 'package:watchtogether/models/room_model.dart';
import 'package:watchtogether/models/user_model.dart';

void main() {
  // Timestamp construction doesn't require a live Firestore instance, so
  // these round-trip tests run as plain Dart/Flutter unit tests.

  group('UserModel', () {
    test('fromMap/toMap round-trips all fields', () {
      final original = UserModel(
        uid: 'uid_1',
        email: 'person@example.com',
        displayName: 'Person',
        photoUrl: 'https://example.com/p.png',
        bio: 'Hello there',
        createdAt: DateTime(2026, 1, 1),
        lastSeenAt: DateTime(2026, 1, 2),
        isOnline: true,
        isPremium: true,
        language: 'ar',
        fcmTokens: const ['token_a', 'token_b'],
        friendsCount: 3,
        roomsCreatedCount: 1,
      );

      final roundTripped = UserModel.fromMap(original.uid, original.toMap());

      expect(roundTripped, original);
    });

    test('fromMap fills sensible defaults for missing fields', () {
      final user = UserModel.fromMap('uid_2', {'email': 'a@b.com'});

      expect(user.uid, 'uid_2');
      expect(user.email, 'a@b.com');
      expect(user.isOnline, isFalse);
      expect(user.isPremium, isFalse);
      expect(user.language, 'en');
      expect(user.fcmTokens, isEmpty);
    });

    test('copyWith only changes the specified fields', () {
      final user = UserModel(
        uid: 'uid_3',
        email: 'a@b.com',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(displayName: 'New Name', isOnline: true);

      expect(updated.displayName, 'New Name');
      expect(updated.isOnline, isTrue);
      expect(updated.email, user.email);
      expect(updated.uid, user.uid);
    });
  });

  group('RoomModel', () {
    test('fromMap/toMap round-trips all fields, including enums', () {
      final original = RoomModel(
        id: 'room_1',
        hostId: 'uid_1',
        title: 'Movie night',
        description: 'Bring snacks',
        videoUrl: 'https://example.com/video.mp4',
        videoSource: VideoSource.direct,
        isPrivate: true,
        passcode: '1234',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        status: RoomStatus.playing,
        participantIds: const ['uid_1', 'uid_2'],
        maxParticipants: 5,
        currentPositionMs: 42000,
        isPlaying: true,
        lastSyncedAt: DateTime(2026, 1, 2, 12),
      );

      final roundTripped = RoomModel.fromMap(original.id, original.toMap());

      expect(roundTripped, original);
    });

    test('isFull reflects participant count vs. maxParticipants', () {
      final room = RoomModel(
        id: 'room_2',
        hostId: 'uid_1',
        title: 'Full room',
        videoUrl: 'https://example.com/video.mp4',
        createdAt: DateTime(2026, 1, 1),
        participantIds: const ['a', 'b'],
        maxParticipants: 2,
      );

      expect(room.isFull, isTrue);
    });

    test('unrecognized enum strings fall back to a safe default', () {
      final room = RoomModel.fromMap('room_3', {
        'hostId': 'uid_1',
        'title': 'Legacy room',
        'videoUrl': 'https://example.com/video.mp4',
        'status': 'some_future_status_this_app_does_not_know_about',
      });

      expect(room.status, RoomStatus.waiting);
    });
  });
}
