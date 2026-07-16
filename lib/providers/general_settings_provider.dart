import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_service_provider.dart';

/// Every default-video-quality option offered on the Settings screen.
enum VideoQuality { auto, p1080, p720, p480, p360 }

extension VideoQualityStorage on VideoQuality {
  /// The string persisted via [LocalStorageService.defaultVideoQuality].
  String get storageValue => switch (this) {
        VideoQuality.auto => 'auto',
        VideoQuality.p1080 => '1080p',
        VideoQuality.p720 => '720p',
        VideoQuality.p480 => '480p',
        VideoQuality.p360 => '360p',
      };

  static VideoQuality fromStorage(String value) {
    return VideoQuality.values.firstWhere(
      (quality) => quality.storageValue == value,
      orElse: () => VideoQuality.auto,
    );
  }
}

/// Immutable snapshot of every toggle/selection on the Settings screen's
/// General section.
///
/// Kept as one bundled state (rather than several independent providers)
/// since the Settings screen reads and writes all of these together and
/// they share the same persistence layer ([LocalStorageService]).
class GeneralSettingsState extends Equatable {
  const GeneralSettingsState({
    required this.vibrationEnabled,
    required this.autoPlayEnabled,
    required this.defaultVideoQuality,
    required this.microphonePermissionEnabled,
    required this.notificationsPermissionEnabled,
  });

  final bool vibrationEnabled;
  final bool autoPlayEnabled;
  final VideoQuality defaultVideoQuality;
  final bool microphonePermissionEnabled;
  final bool notificationsPermissionEnabled;

  GeneralSettingsState copyWith({
    bool? vibrationEnabled,
    bool? autoPlayEnabled,
    VideoQuality? defaultVideoQuality,
    bool? microphonePermissionEnabled,
    bool? notificationsPermissionEnabled,
  }) {
    return GeneralSettingsState(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
      defaultVideoQuality: defaultVideoQuality ?? this.defaultVideoQuality,
      microphonePermissionEnabled:
          microphonePermissionEnabled ?? this.microphonePermissionEnabled,
      notificationsPermissionEnabled:
          notificationsPermissionEnabled ?? this.notificationsPermissionEnabled,
    );
  }

  @override
  List<Object?> get props => [
        vibrationEnabled,
        autoPlayEnabled,
        defaultVideoQuality,
        microphonePermissionEnabled,
        notificationsPermissionEnabled,
      ];
}

class GeneralSettingsNotifier extends Notifier<GeneralSettingsState> {
  @override
  GeneralSettingsState build() {
    final service = ref.read(localStorageServiceProvider);
    return GeneralSettingsState(
      vibrationEnabled: service.vibrationEnabled,
      autoPlayEnabled: service.autoPlayEnabled,
      defaultVideoQuality: VideoQualityStorage.fromStorage(service.defaultVideoQuality),
      microphonePermissionEnabled: service.microphonePermissionEnabled,
      notificationsPermissionEnabled: service.notificationsPermissionEnabled,
    );
  }

  Future<void> setVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await ref.read(localStorageServiceProvider).setVibrationEnabled(value);
  }

  Future<void> setAutoPlayEnabled(bool value) async {
    state = state.copyWith(autoPlayEnabled: value);
    await ref.read(localStorageServiceProvider).setAutoPlayEnabled(value);
  }

  Future<void> setDefaultVideoQuality(VideoQuality value) async {
    state = state.copyWith(defaultVideoQuality: value);
    await ref.read(localStorageServiceProvider).setDefaultVideoQuality(value.storageValue);
  }

  Future<void> setMicrophonePermissionEnabled(bool value) async {
    state = state.copyWith(microphonePermissionEnabled: value);
    await ref.read(localStorageServiceProvider).setMicrophonePermissionEnabled(value);
  }

  Future<void> setNotificationsPermissionEnabled(bool value) async {
    state = state.copyWith(notificationsPermissionEnabled: value);
    await ref.read(localStorageServiceProvider).setNotificationsPermissionEnabled(value);
  }
}

final NotifierProvider<GeneralSettingsNotifier, GeneralSettingsState>
    generalSettingsProvider =
    NotifierProvider<GeneralSettingsNotifier, GeneralSettingsState>(
  GeneralSettingsNotifier.new,
);
