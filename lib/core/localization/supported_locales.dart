import 'package:flutter/material.dart';

/// Metadata for a single supported language.
///
/// Kept separate from [Locale] so the UI (the language selector, first
/// used in Phase 3.2's onboarding and reused wherever a language picker
/// appears later) can render the native name and flag without any
/// localization lookups.
class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.englishName,
    required this.nativeName,
    required this.flagEmoji,
  });

  final Locale locale;
  final String englishName;
  final String nativeName;

  /// Unicode regional-indicator flag emoji. Used instead of bundled flag
  /// image assets — it renders via the system font on every platform
  /// this app targets, so no extra asset files are needed.
  final String flagEmoji;

  bool get isRtl => locale.languageCode == 'ar';
}

/// Central source of truth for every language WatchTogether supports.
///
/// Phase 1 wired up the infrastructure (MaterialApp locale resolution,
/// RTL handling, ARB scaffolding). Phase 3.2 is the first screen to
/// actually let the user change language, via the reusable language
/// selector built on top of this list.
class SupportedLocales {
  const SupportedLocales._();

  static const AppLanguage english = AppLanguage(
    locale: Locale('en'),
    englishName: 'English',
    nativeName: 'English',
    flagEmoji: '🇬🇧',
  );
  static const AppLanguage arabic = AppLanguage(
    locale: Locale('ar'),
    englishName: 'Arabic',
    nativeName: 'العربية',
    flagEmoji: '🇸🇦',
  );
  static const AppLanguage french = AppLanguage(
    locale: Locale('fr'),
    englishName: 'French',
    nativeName: 'Français',
    flagEmoji: '🇫🇷',
  );
  static const AppLanguage spanish = AppLanguage(
    locale: Locale('es'),
    englishName: 'Spanish',
    nativeName: 'Español',
    flagEmoji: '🇪🇸',
  );
  static const AppLanguage turkish = AppLanguage(
    locale: Locale('tr'),
    englishName: 'Turkish',
    nativeName: 'Türkçe',
    flagEmoji: '🇹🇷',
  );
  static const AppLanguage hindi = AppLanguage(
    locale: Locale('hi'),
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    flagEmoji: '🇮🇳',
  );
  static const AppLanguage japanese = AppLanguage(
    locale: Locale('ja'),
    englishName: 'Japanese',
    nativeName: '日本語',
    flagEmoji: '🇯🇵',
  );
  static const AppLanguage portuguese = AppLanguage(
    locale: Locale('pt'),
    englishName: 'Portuguese',
    nativeName: 'Português',
    flagEmoji: '🇵🇹',
  );

  static const List<AppLanguage> all = [
    english,
    arabic,
    french,
    spanish,
    turkish,
    hindi,
    japanese,
    portuguese,
  ];

  static const List<String> rtlLanguageCodes = ['ar'];

  static List<Locale> get locales => all.map((l) => l.locale).toList(growable: false);

  static bool isRtl(Locale locale) => rtlLanguageCodes.contains(locale.languageCode);

  /// Falls back to English if the device locale isn't one WatchTogether ships.
  static Locale resolve(Locale? deviceLocale, Iterable<Locale> supported) {
    if (deviceLocale == null) return english.locale;
    for (final supportedLocale in supported) {
      if (supportedLocale.languageCode == deviceLocale.languageCode) {
        return supportedLocale;
      }
    }
    return english.locale;
  }

  /// The [AppLanguage] matching [locale]'s language code, or [english] if
  /// none match — used by the language selector to resolve "what's
  /// currently selected" for display.
  static AppLanguage byLocale(Locale? locale) {
    if (locale == null) return english;
    return all.firstWhere(
      (lang) => lang.locale.languageCode == locale.languageCode,
      orElse: () => english,
    );
  }
}
