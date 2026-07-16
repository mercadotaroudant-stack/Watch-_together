import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Section 5 — the four room-behavior toggles (voice chat, text chat,
/// letting non-host participants control playback, and joining
/// pre-muted).
class MoreSettingsSection extends StatelessWidget {
  const MoreSettingsSection({
    super.key,
    required this.allowVoiceChat,
    required this.allowChat,
    required this.allowScreenControl,
    required this.startWithMutedAudio,
    required this.onVoiceChatChanged,
    required this.onChatChanged,
    required this.onScreenControlChanged,
    required this.onStartMutedChanged,
  });

  final bool allowVoiceChat;
  final bool allowChat;
  final bool allowScreenControl;
  final bool startWithMutedAudio;
  final ValueChanged<bool> onVoiceChatChanged;
  final ValueChanged<bool> onChatChanged;
  final ValueChanged<bool> onScreenControlChanged;
  final ValueChanged<bool> onStartMutedChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _SwitchRow(
          icon: Icons.mic_none_rounded,
          label: l10n.allowVoiceChatLabel,
          subtitle: l10n.allowVoiceChatSubtitle,
          value: allowVoiceChat,
          onChanged: onVoiceChatChanged,
        ),
        const Divider(color: AppColors.createRoomBorder, height: 20),
        _SwitchRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: l10n.allowChatLabel,
          subtitle: l10n.allowChatSubtitle,
          value: allowChat,
          onChanged: onChatChanged,
        ),
        const Divider(color: AppColors.createRoomBorder, height: 20),
        _SwitchRow(
          icon: Icons.play_circle_outline_rounded,
          label: l10n.allowScreenControlLabel,
          subtitle: l10n.allowScreenControlSubtitle,
          value: allowScreenControl,
          onChanged: onScreenControlChanged,
        ),
        const Divider(color: AppColors.createRoomBorder, height: 20),
        _SwitchRow(
          icon: Icons.mic_off_rounded,
          label: l10n.startMutedLabel,
          subtitle: l10n.startMutedSubtitle,
          value: startWithMutedAudio,
          onChanged: onStartMutedChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.createRoomPrimary,
        ),
      ],
    );
  }
}
