import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// A single reusable "not built yet" screen for every drawer destination
/// that doesn't have a dedicated screen of its own so far (Profile,
/// Premium, Friends, Watch History, Notifications, Help & Support,
/// Community Guidelines, Privacy Policy, Terms of Service).
///
/// This keeps [AppDrawer] fully navigable today — every tap goes
/// somewhere real, with the right title and a back button — without
/// blocking the drawer's build on nine separate screens being designed.
/// Each of these routes in `app_router.dart` can be swapped for a real
/// screen independently, one at a time.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.emoji});

  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: AppConstants.spaceLg),
              Text(
                l10n.featureComingSoonMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
