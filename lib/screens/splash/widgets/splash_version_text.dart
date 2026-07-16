import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../providers/app_version_provider.dart';

/// "Version x.y.z" text shown at the bottom of the splash screen.
///
/// Reads the real installed version via [appVersionProvider]; shows the
/// [AppConstants.fallbackAppVersion] immediately while that resolves so
/// there's never a layout jump or empty space, then updates in place
/// once the platform call returns (near-instant in practice).
class SplashVersionText extends ConsumerWidget {
  const SplashVersionText({super.key});

  static const Color _color = Color(0xFF777777);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String version = ref.watch(appVersionProvider).valueOrNull ??
        AppConstants.fallbackAppVersion;

    return Text(
      l10n.appVersionLabel(version),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: _color,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
