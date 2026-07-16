import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';

/// Mirrors the single document in the `app_settings` collection
/// (conventionally id `'global'`).
///
/// Not in the original model list, but added so the `app_settings`
/// collection — listed among the required Firestore collections — has
/// the same type-safe treatment as every other collection instead of
/// being read as a raw `Map<String, dynamic>`.
///
/// Distinct from [RemoteConfigService]: Remote Config is for
/// client-fetched, cacheable config (feature flags, copy) evaluated
/// without a round trip; this collection is for values that need to be
/// *read reactively* (e.g. a maintenance banner that must appear
/// instantly for all connected clients).
class AppSettingsModel extends Equatable {
  const AppSettingsModel({
    this.minSupportedVersion = '1.0.0',
    this.maintenanceMode = false,
    this.maintenanceMessage,
    this.updatedAt,
  });

  final String minSupportedVersion;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final DateTime? updatedAt;

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      minSupportedVersion: map['minSupportedVersion'] as String? ?? '1.0.0',
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: map['maintenanceMessage'] as String?,
      updatedAt: FirestoreConverters.timestampToDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minSupportedVersion': minSupportedVersion,
      'maintenanceMode': maintenanceMode,
      'maintenanceMessage': maintenanceMessage,
      'updatedAt': FirestoreConverters.dateToTimestamp(updatedAt),
    };
  }

  @override
  List<Object?> get props =>
      [minSupportedVersion, maintenanceMode, maintenanceMessage, updatedAt];
}
