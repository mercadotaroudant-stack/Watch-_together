import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/supported_locales.dart';
import 'storage_service_provider.dart';

/// Holds the app's current locale.
///
/// `null` means "follow the device locale" (resolved by
/// [SupportedLocales.resolve] in `app.dart`); a non-null value means the
/// user explicitly picked a language, which is persisted so it survives
/// app restarts.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final String? savedCode = ref.read(localStorageServiceProvider).localeCode;
    if (savedCode == null) return null;
    return SupportedLocales.all
        .firstWhere(
          (lang) => lang.locale.languageCode == savedCode,
          orElse: () => SupportedLocales.english,
        )
        .locale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(localStorageServiceProvider).setLocaleCode(locale.languageCode);
  }

  Future<void> followDeviceLocale() async {
    state = null;
    await ref.read(localStorageServiceProvider).clearLocale();
  }
}

final NotifierProvider<LocaleNotifier, Locale?> localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
