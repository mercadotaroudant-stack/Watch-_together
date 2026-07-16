import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/localization/supported_locales.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';

/// The root widget of WatchTogether.
///
/// Wires together the three pieces of app-wide infrastructure this phase
/// is responsible for: theming ([AppTheme]), localization
/// ([SupportedLocales] + generated [AppLocalizations]), and navigation
/// ([appRouterProvider]).
class WatchTogetherApp extends ConsumerWidget {
  const WatchTogetherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final Locale? userSelectedLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,

      // Localization wiring. `locale` left null lets Flutter resolve the
      // best match via `localeResolutionCallback`; setting it explicitly
      // once the user picks a language in-app overrides that resolution.
      locale: userSelectedLocale,
      supportedLocales: SupportedLocales.locales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        return SupportedLocales.resolve(deviceLocale, supported);
      },

      // RTL is handled automatically by MaterialApp based on the resolved
      // locale (Arabic -> TextDirection.rtl); no manual Directionality
      // wrapping is needed here.
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
