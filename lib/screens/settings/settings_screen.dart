import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/localization/supported_locales.dart';
import '../../providers/general_settings_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/language_selector/language_options_sheet.dart';
import 'widgets/settings_nav_tile.dart';
import 'widgets/settings_section_label.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/video_quality_sheet.dart';

/// The drawer's "⚙️ Settings" destination.
///
/// Per explicit design direction, this screen is a **white-background,
/// black-text** screen — the one deliberate departure from
/// WatchTogether's app-wide dark theme (see [AppColors] / [AppTheme]).
/// Every color here is therefore hardcoded rather than pulled from
/// `Theme.of(context)`, so it can't silently start looking dark again if
/// the app's theme changes later.
///
/// All eight rows live in a single "General" section, in the exact
/// order requested: App Language, Theme, Default Video Quality, Auto
/// Play Videos, Vibration, Microphone Permission, Notifications
/// Permission, Clear Cache — rather than being split across
/// General/Permissions/Storage groups, since one flat, well-ordered list
/// reads as simpler on a single settings page.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final GeneralSettingsState settings = ref.watch(generalSettingsProvider);
    final GeneralSettingsNotifier notifier = ref.read(generalSettingsProvider.notifier);
    final Locale? selectedLocale = ref.watch(localeProvider);
    final AppLanguage currentLanguage = SupportedLocales.byLocale(selectedLocale);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.settingsTitle, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          SettingsSectionLabel(l10n.settingsGeneralSection),
          SettingsNavTile(
            emoji: '🌐',
            label: l10n.settingsAppLanguage,
            value: currentLanguage.nativeName,
            onTap: () => _openLanguageSheet(context),
          ),
          SettingsSwitchTile(
            emoji: '🎨',
            label: l10n.settingsTheme,
            subtitle: l10n.settingsThemeSubtitle,
            value: true,
            // Dark mode is the app's only theme today (see AppTheme),
            // so this toggle is shown "on" and disabled rather than
            // hidden — it signals the setting exists without pretending
            // a light mode is actually one tap away.
            onChanged: null,
          ),
          SettingsNavTile(
            emoji: '📹',
            label: l10n.settingsDefaultVideoQuality,
            value: _videoQualityLabel(l10n, settings.defaultVideoQuality),
            onTap: () => VideoQualitySheet.show(
              context,
              selected: settings.defaultVideoQuality,
              onSelected: notifier.setDefaultVideoQuality,
            ),
          ),
          SettingsSwitchTile(
            emoji: '▶️',
            label: l10n.settingsAutoPlayVideos,
            value: settings.autoPlayEnabled,
            onChanged: notifier.setAutoPlayEnabled,
          ),
          SettingsSwitchTile(
            emoji: '📳',
            label: l10n.settingsVibration,
            value: settings.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
          ),
          SettingsSwitchTile(
            emoji: '🎤',
            label: l10n.settingsMicrophonePermission,
            value: settings.microphonePermissionEnabled,
            onChanged: notifier.setMicrophonePermissionEnabled,
          ),
          SettingsSwitchTile(
            emoji: '🔔',
            label: l10n.settingsNotificationsPermission,
            value: settings.notificationsPermissionEnabled,
            onChanged: notifier.setNotificationsPermissionEnabled,
          ),
          SettingsNavTile(
            emoji: '🗑️',
            label: l10n.settingsClearCache,
            value: '',
            onTap: () => _confirmClearCache(context, l10n),
          ),
          const SizedBox(height: 24),
        ],
      ),
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

  void _openLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF161622), // AppColors.surface — kept dark on purpose;
      // this sheet is shared with onboarding and isn't part of the
      // white/black Settings-screen restyle.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LanguageOptionsSheet(),
    );
  }

  Future<void> _confirmClearCache(BuildContext context, AppLocalizations l10n) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.settingsClearCacheConfirmTitle, style: const TextStyle(color: Colors.black)),
        content: Text(
          l10n.settingsClearCacheConfirmMessage,
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsClearCache),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsClearCacheSuccess)),
    );
  }
}
