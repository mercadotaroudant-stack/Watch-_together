import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import 'language_options_sheet.dart';

/// The top-right "change language" pill button.
///
/// Fully self-contained: drop it into any screen and it reads the
/// current locale from [localeProvider] and opens its own
/// [LanguageOptionsSheet] on tap — no wiring required from the parent
/// screen. First used on onboarding (Phase 3.2); the same widget is
/// meant to be reused as-is on Sign In, Sign Up, and Settings rather
/// than reimplemented there.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const double _height = 42;
  static const double _minWidth = 120;
  static const double _radius = 22;
  static const Color _background = AppColors.surface;
  static const Color _border = AppColors.border;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale? selectedLocale = ref.watch(localeProvider);
    final AppLanguage currentLanguage = SupportedLocales.byLocale(selectedLocale);

    return Semantics(
      button: true,
      label: l10n.changeLanguageSemanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => _openLanguageSheet(context),
          child: Container(
            height: _height,
            constraints: const BoxConstraints(minWidth: _minWidth),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: _border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.public, size: 20, color: AppColors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    currentLanguage.nativeName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LanguageOptionsSheet(),
    );
  }
}
