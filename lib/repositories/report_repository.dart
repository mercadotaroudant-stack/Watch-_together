import '../core/constants/firestore_collections.dart';
import '../models/enums.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

/// User/content reports (`reports` collection). Write-mostly from the
/// app's side — review/actioning is expected to happen from an admin
/// tool, not this client, so there's deliberately no "list all reports"
/// method here.
class ReportRepository {
  ReportRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<ReportModel> submitReport({
    required String reporterId,
    String? reportedUserId,
    String? roomId,
    String? messageId,
    required ReportReason reason,
    String? description,
  }) async {
    final String id = _firestoreService.newDocumentId(FirestoreCollections.reports);
    final report = ReportModel(
      id: id,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      roomId: roomId,
      messageId: messageId,
      reason: reason,
      description: description,
      createdAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.reports,
      id,
      report.toMap(),
      merge: false,
    );
    return report;
  }

  Stream<List<ReportModel>> streamReportsSubmittedBy(String reporterId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('reporterId', isEqualTo: reporterId)
              .orderBy('createdAt', descending: true),
          FirestoreCollections.reports,
        )
        .map((docs) => docs.map((d) => ReportModel.fromMap(d['id'] as String, d)).toList());
  }
}
