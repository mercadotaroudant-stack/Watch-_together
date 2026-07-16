import 'package:cloud_firestore/cloud_firestore.dart';

/// Small conversion helpers shared by every model's `fromMap`/`toMap`.
///
/// Centralizing these means a model never has to null-check/cast a raw
/// Firestore [Timestamp] by hand, and writes always go through
/// [FieldValue.serverTimestamp] semantics consistently.
abstract final class FirestoreConverters {
  /// Reads a Firestore [Timestamp] (or already-a-[DateTime], for tests
  /// that construct maps by hand) into a [DateTime]. Returns `null` for
  /// missing/null fields — most models fall back to [DateTime.now] at the
  /// call site only where a non-null value is actually required.
  static DateTime? timestampToDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Converts a [DateTime] to a Firestore [Timestamp] for writes. Pass
  /// `null` through so optional date fields can be omitted/cleared.
  static Timestamp? dateToTimestamp(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}
