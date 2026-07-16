import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'room_control_button.dart';

/// The three main room controls, evenly spaced: Voice Chat (toggle),
/// Chat (opens realtime chat — a placeholder today, see
/// [onChatPressed]'s call site), and Leave Room (subtle red).
class RoomControlsBar extends StatelessWidget {
  const RoomControlsBar({
    super.key,
    required this.isVoiceEnabled,
    required this.onVoiceTogglePressed,
    required this.onChatPressed,
    required this.onLeavePressed,
  });

  final bool isVoiceEnabled;
  final VoidCallback onVoiceTogglePressed;
  final VoidCallback onChatPressed;
  final VoidCallback onLeavePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RoomControlButton(
          icon: isVoiceEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
          label: l10n.voiceChat,
          isActive: isVoiceEnabled,
          iconColor: isVoiceEnabled ? AppColors.primary : AppColors.white,
          onPressed: onVoiceTogglePressed,
        ),
        RoomControlButton(
          icon: Icons.chat_bubble_rounded,
          label: l10n.chatAction,
          onPressed: onChatPressed,
        ),
        RoomControlButton(
          icon: Icons.logout_rounded,
          label: l10n.leaveRoom,
          backgroundColor: AppColors.error.withOpacity(0.12),
          iconColor: AppColors.error,
          onPressed: onLeavePressed,
        ),
      ],
    );
  }
}
