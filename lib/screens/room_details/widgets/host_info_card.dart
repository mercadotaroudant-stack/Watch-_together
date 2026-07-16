import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

/// The host card: avatar, display name, "Host" label, and a crown icon
/// marking room ownership.
///
/// No profile photos are fetched here — [host.photoUrl] is trusted if
/// present (it will be, once Phase 4 wires real uploads), otherwise a
/// simple initial-letter avatar stands in, matching this screen's
/// no-external-images rule.
class HostInfoCard extends StatelessWidget {
  const HostInfoCard({super.key, required this.host});

  final UserModel host;

  static const double _height = 90;
  static const double _radius = 20;
  static const double _avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String displayName = host.displayName?.trim().isNotEmpty == true
        ? host.displayName!
        : host.email;
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.roomCard,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.roomBorder),
      ),
      child: Row(
        children: [
          _Avatar(initial: initial),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.hostLabel,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          Semantics(
            label: l10n.roomHostSemanticLabel,
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.secondary, size: 26),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HostInfoCard._avatarSize,
      height: HostInfoCard._avatarSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
      ),
    );
  }
}
