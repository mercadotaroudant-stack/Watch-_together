import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for simple key/value settings
/// (locale, onboarding flags, theme preference, ...).
///
/// This is intentionally *not* where domain data (rooms, users, watch
/// history) will live — that belongs behind a `Repository` backed by
/// Firebase once Phase 2 introduces it. This service exists purely for
/// small, synchronous-feeling app preferences.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyLocaleCode = 'locale_code';
  static const String _keyThemePreference = 'theme_preference';

  /// Key reserved for "has the user finished onboarding" (Phase 3.2).
  ///
  /// Deliberately just the key name — no getter/setter yet. Onboarding's
  /// Get Started button does not write it, and nothing reads it to skip
  /// onboarding on a future launch; that decision belongs to whichever
  /// screen ends up owning app-start routing (Splash, or an auth gate),
  /// once one exists. Exposed as `static const` (not private) so that
  /// future call site can reference the exact key without duplicating
  /// the string literal.
  static const String keyOnboardingCompleted = 'onboarding_completed';

  String? get localeCode => _prefs.getString(_keyLocaleCode);

  Future<bool> setLocaleCode(String code) => _prefs.setString(_keyLocaleCode, code);

  Future<bool> clearLocale() => _prefs.remove(_keyLocaleCode);

  // --- Theme preference ---
  //
  // WatchTogether currently ships a single dark theme (see
  // core/theme/app_theme.dart), so nothing reads this yet. It's prepared
  // now — stored as a plain string ('dark' | 'light' | 'system') — so a
  // future theme-switcher doesn't need a storage-layer change, only a
  // provider that reads/writes it.
  String? get themePreference => _prefs.getString(_keyThemePreference);

  Future<bool> setThemePreference(String value) =>
      _prefs.setString(_keyThemePreference, value);

  // --- Community safety notice acceptance (Phase 3.4.1) ---
  //
  // Unlike [keyOnboardingCompleted] above, this one *is* fully wired:
  // read at the "about to enter Home for the first time" gate (see
  // `core/utils/home_navigation.dart`) and written the moment the user
  // accepts `SafetyNoticeDialog`. Persists across app restarts by
  // design — only reinstalling the app or clearing app data resets it,
  // since `SharedPreferences` storage survives normal termination.
  static const String _keyHasAcceptedCommunityNotice = 'has_accepted_community_notice';

  bool get hasAcceptedCommunityNotice =>
      _prefs.getBool(_keyHasAcceptedCommunityNotice) ?? false;

  Future<bool> setHasAcceptedCommunityNotice(bool value) =>
      _prefs.setBool(_keyHasAcceptedCommunityNotice, value);

  // --- General settings (Phase 3.6 — Settings screen) ---
  //
  // Same "prepared, UI-only" spirit as [themePreference] above: these are
  // plain local flags the Settings screen reads/writes today. Vibration
  // and auto-play are pure client-side toggles a future player/haptics
  // call site can key off of; the two "permission" entries are *not*
  // wired to the OS permission APIs (no `permission_handler` dependency
  // yet) — they track the user's in-app preference so the toggle has a
  // persisted, correct-looking state now, and can be upgraded to a real
  // `openAppSettings()` / request flow later without a storage change.
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyAutoPlayEnabled = 'auto_play_enabled';
  static const String _keyDefaultVideoQuality = 'default_video_quality';
  static const String _keyMicrophonePermissionEnabled = 'microphone_permission_enabled';
  static const String _keyNotificationsPermissionEnabled = 'notifications_permission_enabled';

  bool get vibrationEnabled => _prefs.getBool(_keyVibrationEnabled) ?? true;

  Future<bool> setVibrationEnabled(bool value) =>
      _prefs.setBool(_keyVibrationEnabled, value);

  bool get autoPlayEnabled => _prefs.getBool(_keyAutoPlayEnabled) ?? true;

  Future<bool> setAutoPlayEnabled(bool value) =>
      _prefs.setBool(_keyAutoPlayEnabled, value);

  /// One of `'auto'`, `'1080p'`, `'720p'`, `'480p'`, `'360p'`.
  String get defaultVideoQuality => _prefs.getString(_keyDefaultVideoQuality) ?? 'auto';

  Future<bool> setDefaultVideoQuality(String value) =>
      _prefs.setString(_keyDefaultVideoQuality, value);

  bool get microphonePermissionEnabled =>
      _prefs.getBool(_keyMicrophonePermissionEnabled) ?? true;

  Future<bool> setMicrophonePermissionEnabled(bool value) =>
      _prefs.setBool(_keyMicrophonePermissionEnabled, value);

  bool get notificationsPermissionEnabled =>
      _prefs.getBool(_keyNotificationsPermissionEnabled) ?? true;

  Future<bool> setNotificationsPermissionEnabled(bool value) =>
      _prefs.setBool(_keyNotificationsPermissionEnabled, value);
}
