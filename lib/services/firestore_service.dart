import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errors/firebase_error_mapper.dart';

/// Generic, collection-agnostic Firestore access.
///
/// This is the only place in the app that touches [FirebaseFirestore]
/// directly for simple CRUD; feature-specific services (`RoomService`,
/// `FriendService`, ...) and repositories build on top of this instead of
/// each holding their own [FirebaseFirestore] reference. Every method
/// catches [FirebaseException] and rethrows a mapped
/// [FirestoreException] via [FirebaseErrorMapper].
class FirestoreService {
  FirestoreService([FirebaseFirestore? firestore])
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  Future<Map<String, dynamic>?> getDocument(String collectionPath, String docId) async {
    try {
      final snap = await _db.collection(collectionPath).doc(docId).get();
      return snap.data();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  Stream<Map<String, dynamic>?> streamDocument(String collectionPath, String docId) {
    return _db
        .collection(collectionPath)
        .doc(docId)
        .snapshots()
        .map((snap) => snap.data())
        .handleError((Object e) => throw FirebaseErrorMapper.mapFirestoreError(e));
  }

  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _db.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  /// Returns a fresh document id for [collectionPath] without writing
  /// anything — useful when the caller needs the id before the first
  /// write (e.g. to fan out a batched write across sub-documents).
  String newDocumentId(String collectionPath) => _db.collection(collectionPath).doc().id;

  Future<List<Map<String, dynamic>>> runQuery(
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref) build,
    String collectionPath,
  ) async {
    try {
      final query = build(_db.collection(collectionPath));
      final snap = await query.get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamQuery(
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref) build,
    String collectionPath,
  ) {
    final query = build(_db.collection(collectionPath));
    return query
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList())
        .handleError((Object e) => throw FirebaseErrorMapper.mapFirestoreError(e));
  }

  /// Runs [action] inside a Firestore transaction, mapping any thrown
  /// [FirebaseException] the same way every other method here does.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    try {
      return await _db.runTransaction(action);
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  WriteBatch batch() => _db.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }
}
