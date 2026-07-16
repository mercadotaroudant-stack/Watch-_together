import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/premium_tier_label.dart';
import '../../../models/premium_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/premium_providers.dart';

/// The Home screen's welcome card — real signed-in user photo/name and
/// (only when actually active) a real Premium tier badge, per spec.
class UserWelcomeCard extends ConsumerWidget {
  const UserWelcomeCard({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final PremiumModel? premium = ref.watch(premiumStatusProvider).valueOrNull;
    final bool isPremium = premium?.isActive ?? false;

    final String displayName =
        user?.displayName?.trim().isNotEmpty == true ? user!.displayName!.trim() : l10n.drawerGuestName;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(minHeight: 138),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homeWelcomeCardStart, AppColors.homeWelcomeCardEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.homePrimary.withOpacity(0.18),
            blurRadius: 32,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(photoUrl: user?.photoUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        l10n.homeWelcomeBack(displayName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.homePrimaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isPremium) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.homeBadgePurple.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      premiumTierLabel(l10n, premium!.tier),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.homeBadgePurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else
                  const SizedBox(height: 8),
                Text(
                  l10n.homeWelcomeSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.homeSecondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});

  final String? photoUrl;
  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.homePrimary.withOpacity(0.6), width: 2),
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
      color: AppColors.homePrimary.withOpacity(0.2),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 38, color: AppColors.white),
    );
  }
}
