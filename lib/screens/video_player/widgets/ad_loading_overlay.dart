import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The forced pre-roll overlay shown before a room's video ever starts
/// playing — per spec there's no skip button and no real ad SDK wired
/// up (same "space reserved, nothing real" precedent as
/// `BannerAdPlaceholder` in Room Details); [VideoPlayerScreen] just
/// keeps this mounted for a fixed delay before dismissing it and
/// starting local playback.
class AdLoadingOverlay extends StatelessWidget {
  const AdLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      color: AppColors.videoPlayerBackground,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.videoPlayerPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.videoPlayerAdLoadingLabel,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.videoPlayerAdWaitMessage,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.videoPlayerSecondaryText),
          ),
        ],
      ),
    );
  }
}
