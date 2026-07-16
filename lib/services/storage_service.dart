import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Thin wrapper over [FirebaseStorage], mirroring [FirestoreService]'s
/// "only place that touches the raw SDK" role for file storage.
class StorageService {
  StorageService([FirebaseStorage? storage]) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads [file] as the given user's profile photo (overwriting any
  /// previous one, since the path is keyed only by [uid]) and returns
  /// its public download URL.
  Future<String> uploadProfileImage({required String uid, required File file}) async {
    final Reference ref = _storage.ref('profile_images/$uid.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
