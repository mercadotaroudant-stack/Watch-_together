import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/profile_account_actions_section.dart';
import 'widgets/profile_account_section.dart';
import 'widgets/profile_app_preferences_section.dart';
import 'widgets/profile_language_section.dart';
import 'widgets/profile_notifications_section.dart';

/// The drawer's "👤 My Profile" destination — the account and app
/// preferences home. Per spec this absorbed what used to be three
/// separate drawer entries (Notifications preferences, Language,
/// Settings), each kept as its own section here rather than rebuilt:
/// [ProfileNotificationsSection], [ProfileLanguageSection], and
/// [ProfileAppPreferencesSection] all read/write the same real
/// providers those screens used.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.menuBackground,
      appBar: AppBar(
        backgroundColor: AppColors.menuBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.drawerMyProfile,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: const [
            ProfileAccountSection(),
            ProfileNotificationsSection(),
            ProfileLanguageSection(),
            ProfileAppPreferencesSection(),
            ProfileAccountActionsSection(),
          ],
        ),
      ),
    );
  }
}
