import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/notification_providers.dart';

/// The Home screen's top bar — real logo + app name on the leading
/// side, then Search / Notifications (with a real unread badge) / Menu
/// icon buttons, per spec. Not a [Scaffold.appBar] since it needs the
/// welcome card and the rest of the page to scroll underneath it as
/// one continuous [SingleChildScrollView].
class HomeTopHeader extends ConsumerWidget {
  const HomeTopHeader({super.key, required this.onSearchTap, required this.onMenuTap});

  final VoidCallback onSearchTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unreadCount = ref.watch(unreadNotificationsCountProvider);

    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _HeaderLogo(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      AppConstants.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.search_rounded,
              semanticLabel: AppLocalizations.of(context)!.homeSearchSemanticLabel,
              onTap: onSearchTap,
            ),
            const SizedBox(width: 10),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              semanticLabel: AppLocalizations.of(context)!.drawerNotifications,
              showBadge: unreadCount > 0,
              onTap: () => context.push(RouteNames.notifications),
            ),
            const SizedBox(width: 10),
            _HeaderIconButton(
              icon: Icons.menu_rounded,
              semanticLabel: AppLocalizations.of(context)!.homeMenuSemanticLabel,
              onTap: onMenuTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  static const double _size = 42;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        AssetPaths.appLogo,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.white, size: 24),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.homeHeaderButtonBackground,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.homeHeaderButtonBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: AppColors.white, size: 22),
                if (showBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.homeNotificationBadge,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
