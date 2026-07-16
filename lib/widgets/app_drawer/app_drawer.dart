import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/helpers/app_logger.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/premium_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/premium_providers.dart';
import '../../providers/repository_providers.dart';
import 'widgets/drawer_footer_widget.dart';
import 'widgets/drawer_header_widget.dart';
import 'widgets/drawer_menu_tile.dart';
import 'widgets/logout_confirm_dialog.dart';

/// WatchTogether's app-wide navigation drawer ("☰ Menu").
///
/// Owns exactly one job: show the 13-item menu described by the design
/// spec (Profile, Premium, Friends, Watch History, Notifications,
/// Settings, Help & Support, Community Guidelines, Privacy Policy, Terms
/// of Service, Rate App, About, Logout) plus its header/footer, and route
/// to each destination. It intentionally does not itself decide *what*
/// each destination screen looks like — every route it pushes to is
/// registered in `app_router.dart`, so screens can be upgraded one at a
/// time (see `ComingSoonScreen`) without ever touching this file again.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(authStateProvider).valueOrNull;
    final PremiumModel? premium = ref.watch(premiumStatusProvider).valueOrNull;

    return Drawer(
      backgroundColor: AppColors.background,
      width: 300,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            DrawerHeaderWidget(user: user, premium: premium),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  DrawerMenuTile(
                    emoji: '👤',
                    label: l10n.drawerMyProfile,
                    onTap: () => _navigate(context, RouteNames.profile),
                  ),
                  DrawerMenuTile(
                    emoji: '👑',
                    label: l10n.drawerPremium,
                    onTap: () => _navigate(context, RouteNames.premium),
                  ),
                  DrawerMenuTile(
                    emoji: '👥',
                    label: l10n.drawerFriends,
                    onTap: () => _navigate(context, RouteNames.friends),
                  ),
                  DrawerMenuTile(
                    emoji: '🎬',
                    label: l10n.drawerMyRooms,
                    onTap: () => _navigate(context, RouteNames.myRooms),
                  ),
                  DrawerMenuTile(
                    emoji: '📜',
                    label: l10n.drawerWatchHistory,
                    onTap: () => _navigate(context, RouteNames.watchHistory),
                  ),
                  const Divider(height: 17, indent: 20, endIndent: 20),
                  DrawerMenuTile(
                    emoji: '❓',
                    label: l10n.drawerHelpSupport,
                    onTap: () => _navigate(context, RouteNames.helpSupport),
                  ),
                  DrawerMenuTile(
                    emoji: '📄',
                    label: l10n.drawerCommunityGuidelines,
                    onTap: () => _navigate(context, RouteNames.communityGuidelines),
                  ),
                  DrawerMenuTile(
                    emoji: '🔒',
                    label: l10n.drawerPrivacyPolicy,
                    onTap: () => _navigate(context, RouteNames.privacyPolicy),
                  ),
                  DrawerMenuTile(
                    emoji: '📃',
                    label: l10n.drawerTermsOfService,
                    onTap: () => _navigate(context, RouteNames.termsOfService),
                  ),
                  DrawerMenuTile(
                    emoji: '⭐',
                    label: l10n.drawerRateApp,
                    onTap: () => _rateApp(context),
                  ),
                  DrawerMenuTile(
                    emoji: 'ℹ️',
                    label: l10n.drawerAbout,
                    onTap: () => _navigate(context, RouteNames.about),
                  ),
                  const Divider(height: 17, indent: 20, endIndent: 20),
                  DrawerMenuTile(
                    emoji: '🚪',
                    label: l10n.logout,
                    isDestructive: true,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
            const DrawerFooterWidget(),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop(); // close the drawer first
    context.push(route);
  }

  /// Opens the app's Google Play Store listing.
  ///
  /// Tries the native `market://` intent first (opens directly in the
  /// Play Store app, per spec); falls back to the `https://play.google
  /// .com/store/...` web URL if no Play Store app is installed (e.g. an
  /// emulator without Play Services) so the action never silently fails.
  Future<void> _rateApp(BuildContext context) async {
    Navigator.of(context).pop();

    final Uri marketUri = Uri.parse('market://details?id=${AppConstants.packageName}');
    final Uri webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=${AppConstants.packageName}',
    );

    try {
      final bool launched = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.warning('Falling back to Play Store web URL', error: e);
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await LogoutConfirmDialog.show(context);
    if (!confirmed) return;

    if (context.mounted) Navigator.of(context).pop(); // close the drawer

    await ref.read(authRepositoryProvider).logout();

    if (context.mounted) context.go(RouteNames.authentication);
  }
}
