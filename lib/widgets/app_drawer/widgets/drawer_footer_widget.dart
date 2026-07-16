import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_version_provider.dart';

/// The bottom-anchored "WatchTogether · Version x.y.z · Made with ❤️"
/// block shown under the menu list in [AppDrawer].
class DrawerFooterWidget extends ConsumerWidget {
  const DrawerFooterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<String> version = ref.watch(appVersionProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppConstants.appName,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.appVersionLabel(version.valueOrNull ?? AppConstants.fallbackAppVersion),
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDisabled),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.drawerMadeWithLove,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}
