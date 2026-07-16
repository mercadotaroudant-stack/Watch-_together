import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The 72dp-wide right-edge rail: mic, speaker, chat, participants.
/// Unlike the bottom transport bar, none of these are gated by
/// playback-control permission — muting your own mic or opening a
/// panel is always a per-viewer action.
class VideoPlayerRightRail extends StatelessWidget {
  const VideoPlayerRightRail({
    super.key,
    required this.isMicOn,
    required this.isSpeakerOn,
    required this.unreadChatCount,
    required this.onToggleMic,
    required this.onToggleSpeaker,
    required this.onOpenChat,
    required this.onOpenParticipants,
  });

  final bool isMicOn;
  final bool isSpeakerOn;
  final int unreadChatCount;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenParticipants;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RailIcon(
            icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: isMicOn ? l10n.micOnLabel : l10n.micOffLabel,
            active: isMicOn,
            onTap: onToggleMic,
          ),
          const SizedBox(height: 16),
          _RailIcon(
            icon: isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: isSpeakerOn ? l10n.speakerOnLabel : l10n.speakerOffLabel,
            active: isSpeakerOn,
            onTap: onToggleSpeaker,
          ),
          const SizedBox(height: 16),
          _RailIcon(
            icon: Icons.chat_bubble_outline_rounded,
            label: l10n.chatLabel,
            active: false,
            badgeCount: unreadChatCount,
            onTap: onOpenChat,
          ),
          const SizedBox(height: 16),
          _RailIcon(
            icon: Icons.people_alt_outlined,
            label: l10n.participantsLabel,
            active: false,
            onTap: onOpenParticipants,
          ),
        ],
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  const _RailIcon({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool active;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.videoPlayerCard.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.videoPlayerBorder),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: active ? AppColors.videoPlayerPrimary : AppColors.white,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 18),
                        decoration: const BoxDecoration(
                          color: AppColors.videoPlayerPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 9, color: AppColors.videoPlayerSecondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
