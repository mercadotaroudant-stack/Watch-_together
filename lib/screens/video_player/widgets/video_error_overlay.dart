import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// What kind of real playback failure [VideoErrorOverlay] is showing —
/// drives which message is shown, not the visual style (same dark
/// overlay either way, matching [AdLoadingOverlay]'s precedent).
enum VideoErrorKind {
  /// `RoomModel.videoUrl` is empty or not a parseable http(s) URL —
  /// caught before a [VideoPlayerController] is ever created.
  invalidUrl,

  /// The real engine (`VideoPlayerController.initialize()`, or a
  /// `hasError` value afterwards) rejected the source — could be an
  /// unsupported container/codec or the source being unreachable;
  /// there's no reliable cross-platform way to tell those apart from
  /// the Dart side, so both surface here with one honest message
  /// rather than a guessed-at distinction.
  playbackError,
}

/// Shown in place of the video surface when real playback can't start
/// or has failed — always paired with a real retry action, never a
/// dead end.
class VideoErrorOverlay extends StatelessWidget {
  const VideoErrorOverlay({super.key, required this.kind, required this.onRetry});

  final VideoErrorKind kind;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String title = kind == VideoErrorKind.invalidUrl
        ? l10n.videoPlayerInvalidUrlTitle
        : l10n.videoPlayerPlaybackErrorTitle;
    final String message = kind == VideoErrorKind.invalidUrl
        ? l10n.videoPlayerInvalidUrlMessage
        : l10n.videoPlayerPlaybackErrorMessage;

    return Container(
      color: AppColors.videoPlayerBackground,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.videoPlayerSecondaryText),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.retry,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.videoPlayerPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
