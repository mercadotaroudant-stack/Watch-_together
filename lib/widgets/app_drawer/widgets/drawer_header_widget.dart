import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/utils/premium_tier_label.dart';
import '../../../models/premium_model.dart';
import '../../../models/user_model.dart';

/// The top section of [AppDrawer] — a fixed-height, purple-gradient
/// panel showing the signed-in user's avatar, name, email, and (when
/// applicable) a real Premium plan badge.
///
/// Kept as its own widget (rather than inlined in `AppDrawer`) since it
/// has no dependency on the menu items below it — it only needs the
/// current [UserModel] and [PremiumModel], which the drawer already has
/// from `authStateProvider`/`premiumStatusProvider`.
class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key, required this.user, required this.premium});

  final UserModel? user;

  /// The user's real subscription record — `null`/inactive means Free,
  /// in which case no Premium badge is shown at all (never a fake one).
  final PremiumModel? premium;

  static const double _height = 180;
  static const double _avatarSize = 72;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : l10n.drawerGuestName;
    final String email = user?.email ?? '';
    final bool isPremium = premium?.isActive ?? false;
    final String? planBadgeLabel = isPremium ? premiumTierLabel(l10n, premium!.tier) : null;

    return Container(
      height: _height,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(photoUrl: user?.photoUrl, size: _avatarSize),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      const Text('👑', style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                if (isPremium && planBadgeLabel != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      planBadgeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.size});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      alignment: Alignment.center,
      child: Icon(Icons.person_rounded, size: size * 0.55, color: Colors.white),
    );
  }
}
