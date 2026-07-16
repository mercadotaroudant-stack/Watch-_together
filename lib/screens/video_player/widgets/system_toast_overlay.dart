import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// One transient "Ahmed joined the room." / "Ahmed left the room."
/// toast — the name in purple, the verb in green (joined) or red
/// (left), everything else white, matching the spec exactly. Callers
/// own the 3-second auto-dismiss timer; this widget just renders one
/// entry and fades itself in.
class SystemToast extends StatelessWidget {
  const SystemToast({super.key, required this.displayName, required this.joined});

  final String displayName;
  final bool joined;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * -6), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            children: [
              TextSpan(
                text: displayName,
                style: const TextStyle(color: AppColors.videoPlayerPrimary),
              ),
              const TextSpan(text: ' ', style: TextStyle(color: AppColors.white)),
              TextSpan(
                text: joined ? l10n.systemJoinedVerb : l10n.systemLeftVerb,
                style: TextStyle(color: joined ? AppColors.success : AppColors.error),
              ),
              TextSpan(text: ' ${l10n.systemRoomSuffix}', style: const TextStyle(color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stacks up to a few [SystemToast]s at the top of the video area.
class SystemToastOverlay extends StatelessWidget {
  const SystemToastOverlay({super.key, required this.toasts});

  final List<({String id, String displayName, bool joined})> toasts;

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final toast in toasts)
              SystemToast(key: ValueKey(toast.id), displayName: toast.displayName, joined: toast.joined),
          ],
        ),
      ),
    );
  }
}
