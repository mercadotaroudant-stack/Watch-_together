import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/localization/supported_locales.dart';
import '../../../core/theme/app_colors.dart';

/// A tap-to-open field for picking the profile's preferred language.
///
/// Visually matches [CountryPickerField], but is a distinct widget: this
/// sets a *profile* attribute (saved with the rest of the form), not the
/// app's currently-displayed UI language — that's `LanguageSelector`
/// (`widgets/language_selector/`), a different, already-reusable
/// component with different behavior (changes the UI immediately). The
/// two happen to share the same 8-language list ([SupportedLocales])
/// but shouldn't be merged into one widget, since their side effects
/// are fundamentally different.
class LanguagePickerField extends StatelessWidget {
  const LanguagePickerField({super.key, required this.selected, required this.onChanged});

  final AppLanguage? selected;
  final ValueChanged<AppLanguage> onChanged;

  static const double _radius = 14;

  Future<void> _openPicker(BuildContext context) async {
    final AppLanguage? picked = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: AppColors.authCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _LanguagePickerSheet(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: selected?.nativeName ?? l10n.profileLanguageFieldLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: () => _openPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (selected != null) ...[
                Text(selected!.flagEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  selected?.nativeName ?? l10n.profileLanguageFieldLabel,
                  style: GoogleFonts.poppins(
                    fontSize: selected == null ? 14 : 16,
                    color: selected == null ? AppColors.secondaryText : AppColors.white,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.selectLanguageSheetTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...SupportedLocales.all.map(
              (language) => Semantics(
                button: true,
                label: language.nativeName,
                child: ListTile(
                  onTap: () => Navigator.of(context).pop(language),
                  leading: Text(language.flagEmoji, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    language.nativeName,
                    style: GoogleFonts.poppins(fontSize: 15, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
