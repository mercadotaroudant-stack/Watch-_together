import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

String formatPlaybackDuration(int milliseconds) {
  final Duration d = Duration(milliseconds: milliseconds.clamp(0, 1 << 31));
  final int hours = d.inHours;
  final int minutes = d.inMinutes.remainder(60);
  final int seconds = d.inSeconds.remainder(60);
  final String mm = minutes.toString().padLeft(2, '0');
  final String ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$mm:$ss';
  return '$mm:$ss';
}

/// The bottom transport bar: lock, replay-10 / previous / play-pause /
/// next / forward-10, fullscreen, and the seek bar underneath.
///
/// Play/pause, seek, and the ±10s buttons are gated by [canControl] —
/// a member without playback permission gets [onUnauthorizedTap]
/// instead of the real handler, per spec's "Only the room owner can
/// control playback" rule. Previous/Next aren't part of that synced
/// set (the spec only lists Play/Pause/Seek/Forward/Backward) and
/// there's no playlist for them to act on yet either way, so both
/// always call straight through to their handlers.
class VideoControlsOverlay extends StatelessWidget {
  const VideoControlsOverlay({
    super.key,
    required this.isPlaying,
    required this.isLocked,
    required this.isFullscreen,
    required this.positionMs,
    required this.durationMs,
    required this.canControl,
    required this.onPlayPause,
    required this.onReplay10,
    required this.onForward10,
    required this.onPrevious,
    required this.onNext,
    required this.onSeek,
    required this.onToggleLock,
    required this.onToggleFullscreen,
    required this.onUnauthorizedTap,
  });

  final bool isPlaying;
  final bool isLocked;
  final bool isFullscreen;
  final int positionMs;
  final int durationMs;
  final bool canControl;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay10;
  final VoidCallback onForward10;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onSeek;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onUnauthorizedTap;

  void _guarded(VoidCallback action) => canControl ? action() : onUnauthorizedTap();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (isLocked) {
      return Positioned(
        left: 16,
        bottom: 16,
        child: _RailButton(
          icon: Icons.lock_rounded,
          semanticLabel: l10n.unlockControlsSemanticLabel,
          onTap: onToggleLock,
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RailButton(
                  icon: Icons.lock_open_rounded,
                  semanticLabel: l10n.lockControlsSemanticLabel,
                  onTap: onToggleLock,
                ),
                _RailButton(
                  icon: Icons.replay_10_rounded,
                  semanticLabel: l10n.replay10SemanticLabel,
                  onTap: () => _guarded(onReplay10),
                ),
                _RailButton(
                  icon: Icons.skip_previous_rounded,
                  semanticLabel: l10n.previousSemanticLabel,
                  onTap: onPrevious,
                ),
                _PlayButton(
                  isPlaying: isPlaying,
                  playLabel: l10n.playSemanticLabel,
                  pauseLabel: l10n.pauseSemanticLabel,
                  onTap: () => _guarded(onPlayPause),
                ),
                _RailButton(
                  icon: Icons.skip_next_rounded,
                  semanticLabel: l10n.nextSemanticLabel,
                  onTap: onNext,
                ),
                _RailButton(
                  icon: Icons.forward_10_rounded,
                  semanticLabel: l10n.forward10SemanticLabel,
                  onTap: () => _guarded(onForward10),
                ),
                _RailButton(
                  icon: isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  semanticLabel: l10n.fullscreenSemanticLabel,
                  onTap: onToggleFullscreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SeekBar(
              positionMs: positionMs,
              durationMs: durationMs,
              enabled: canControl,
              onChanged: onSeek,
              onDisabledInteraction: onUnauthorizedTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.semanticLabel, required this.onTap});

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.videoPlayerCard.withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.videoPlayerBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(width: 44, height: 44, child: Icon(icon, color: AppColors.white, size: 22)),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.playLabel,
    required this.pauseLabel,
    required this.onTap,
  });

  final bool isPlaying;
  final String playLabel;
  final String pauseLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? pauseLabel : playLabel,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.videoPlayerPrimary, AppColors.videoPlayerPrimaryHover],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.videoPlayerPrimary.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({
    required this.positionMs,
    required this.durationMs,
    required this.enabled,
    required this.onChanged,
    required this.onDisabledInteraction,
  });

  final int positionMs;
  final int durationMs;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final VoidCallback onDisabledInteraction;

  @override
  Widget build(BuildContext context) {
    final double max = durationMs > 0 ? durationMs.toDouble() : 1;
    final double value = positionMs.clamp(0, max).toDouble();

    return Row(
      children: [
        Text(
          formatPlaybackDuration(positionMs),
          style: const TextStyle(color: AppColors.white, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTapDown: enabled ? null : (_) => onDisabledInteraction(),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.videoPlayerPrimary,
                inactiveTrackColor: AppColors.videoPlayerBorder,
                thumbColor: AppColors.videoPlayerPrimary,
                overlayColor: AppColors.videoPlayerPrimary.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: max,
                onChanged: enabled ? (v) => onChanged(v.round()) : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '-${formatPlaybackDuration((durationMs - positionMs).clamp(0, durationMs))}',
          style: const TextStyle(color: AppColors.white, fontSize: 12),
        ),
      ],
    );
  }
}
