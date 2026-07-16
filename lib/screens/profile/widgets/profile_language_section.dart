import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/localization/supported_locales.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/locale_provider.dart';
import '../../../widgets/language_selector/language_options_sheet.dart';
import 'profile_shared_rows.dart';

/// My Profile's Language section — moved here from the drawer per
/// spec. Reuses the exact same [LanguageOptionsSheet]/[localeProvider]
/// the old Settings screen used, so language changes/persistence/RTL
/// behavior are unchanged, just reached from a new place.
class ProfileLanguageSection extends ConsumerWidget {
  const ProfileLanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale? selectedLocale = ref.watch(localeProvider);
    final AppLanguage currentLanguage = SupportedLocales.byLocale(selectedLocale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.profileLanguageSection),
        ProfileSectionCard(
          children: [
            ProfileNavRow(
              emoji: '🌐',
              label: l10n.settingsAppLanguage,
              value: currentLanguage.nativeName,
              onTap: () => _openLanguageSheet(context),
            ),
          ],
        ),
      ],
    );
  }

  void _openLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.menuSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LanguageOptionsSheet(),
    );
  }
}
