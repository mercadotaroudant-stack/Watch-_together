import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Thin wrapper around [FirebaseRemoteConfig].
///
/// Defaults are declared once in [_defaults] and set on [initialize], so
/// the app always has a sane value even before the first fetch succeeds
/// (e.g. first-ever launch with no network).
class RemoteConfigService {
  RemoteConfigService([FirebaseRemoteConfig? remoteConfig])
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  static const Map<String, dynamic> _defaults = {
    RemoteConfigKeys.minSupportedAppVersion: '1.0.0',
    RemoteConfigKeys.maxRoomParticipants: 10,
    RemoteConfigKeys.isPremiumFeatureEnabled: true,
    RemoteConfigKeys.maintenanceMode: false,
  };

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults(_defaults);
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Non-fatal: fall back to defaults/last-fetched values if the
      // network is unavailable at startup.
    }
  }

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
}

/// Remote Config key registry — see [RemoteConfigService._defaults] for
/// each key's fallback value.
abstract final class RemoteConfigKeys {
  static const String minSupportedAppVersion = 'min_supported_app_version';
  static const String maxRoomParticipants = 'max_room_participants';
  static const String isPremiumFeatureEnabled = 'is_premium_feature_enabled';
  static const String maintenanceMode = 'maintenance_mode';
}
