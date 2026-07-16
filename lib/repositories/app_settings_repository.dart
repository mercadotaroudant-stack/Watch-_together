import '../core/constants/firestore_collections.dart';
import '../models/app_settings_model.dart';
import '../services/firestore_service.dart';

/// The single global `app_settings/global` document — maintenance mode,
/// minimum supported app version, and similar values that need to be
/// observed reactively (see [AppSettingsModel] for how this differs from
/// Remote Config).
class AppSettingsRepository {
  AppSettingsRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  static const String _docId = 'global';

  Future<AppSettingsModel> getSettings() async {
    final data =
        await _firestoreService.getDocument(FirestoreCollections.appSettings, _docId);
    return data == null ? const AppSettingsModel() : AppSettingsModel.fromMap(data);
  }

  Stream<AppSettingsModel> streamSettings() {
    return _firestoreService
        .streamDocument(FirestoreCollections.appSettings, _docId)
        .map((data) => data == null ? const AppSettingsModel() : AppSettingsModel.fromMap(data));
  }
}
