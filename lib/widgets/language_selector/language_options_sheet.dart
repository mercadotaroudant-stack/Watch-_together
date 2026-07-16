import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/supported_locales.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';

/// The list of languages shown inside [LanguageSelector]'s bottom sheet.
///
/// Selecting a language updates [localeProvider] immediately (no
/// restart/reload — `WatchTogetherApp` already rebuilds on locale change,
/// see `app.dart`) and dismisses the sheet; it does not navigate.
class LanguageOptionsSheet extends ConsumerWidget {
  const LanguageOptionsSheet({super.key});

  static const Color _selectedBackground = Color(0x207C3AED);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? selectedLocale = ref.watch(localeProvider);
    final String? selectedCode = selectedLocale?.languageCode;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — purely visual, standard Material 3 sheet affordance.
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...SupportedLocales.all.map((language) {
              final bool isSelected = language.locale.languageCode == selectedCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LanguageTile(
                  language: language,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(language.locale);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _height = 56;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: language.nativeName,
      child: Material(
        color: isSelected ? LanguageOptionsSheet._selectedBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: Container(
            height: _height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(language.flagEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language.nativeName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_rounded, color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
