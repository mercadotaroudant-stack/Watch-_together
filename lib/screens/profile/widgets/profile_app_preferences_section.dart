import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../providers/general_settings_provider.dart';
import '../../settings/widgets/video_quality_sheet.dart';
import 'profile_shared_rows.dart';

/// My Profile's App Preferences section — moved here from the
/// standalone Settings screen per spec. Reuses [generalSettingsProvider]
/// (the same real, persisted state Settings used) for every row; no
/// Theme/Light-Mode row, since WatchTogether has only the one dark
/// theme.
class ProfileAppPreferencesSection extends ConsumerWidget {
  const ProfileAppPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final GeneralSettingsState settings = ref.watch(generalSettingsProvider);
    final GeneralSettingsNotifier notifier = ref.read(generalSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.profileAppPreferencesSection),
        ProfileSectionCard(
          children: [
            ProfileSwitchRow(
              emoji: '📳',
              label: l10n.settingsVibration,
              value: settings.vibrationEnabled,
              onChanged: notifier.setVibrationEnabled,
            ),
            ProfileNavRow(
              emoji: '📹',
              label: l10n.settingsDefaultVideoQuality,
              value: _videoQualityLabel(l10n, settings.defaultVideoQuality),
              onTap: () => VideoQualitySheet.show(
                context,
                selected: settings.defaultVideoQuality,
                onSelected: notifier.setDefaultVideoQuality,
              ),
            ),
            ProfileSwitchRow(
              emoji: '▶️',
              label: l10n.settingsAutoPlayVideos,
              value: settings.autoPlayEnabled,
              onChanged: notifier.setAutoPlayEnabled,
            ),
            ProfileSwitchRow(
              emoji: '🎤',
              label: l10n.settingsMicrophonePermission,
              value: settings.microphonePermissionEnabled,
              onChanged: notifier.setMicrophonePermissionEnabled,
            ),
            ProfileSwitchRow(
              emoji: '🔔',
              label: l10n.settingsNotificationsPermission,
              value: settings.notificationsPermissionEnabled,
              onChanged: notifier.setNotificationsPermissionEnabled,
            ),
          ],
        ),
      ],
    );
  }

  String _videoQualityLabel(AppLocalizations l10n, VideoQuality quality) {
    return switch (quality) {
      VideoQuality.auto => l10n.videoQualityAuto,
      VideoQuality.p1080 => l10n.videoQuality1080,
      VideoQuality.p720 => l10n.videoQuality720,
      VideoQuality.p480 => l10n.videoQuality480,
      VideoQuality.p360 => l10n.videoQuality360,
    };
  }
}
