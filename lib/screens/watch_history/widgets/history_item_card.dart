import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/watch_history_model.dart';
import '../utils/history_formatting.dart';
import 'history_thumbnail.dart';

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onMenuTap,
  });

  final WatchHistoryModel entry;
  final VoidCallback onOpen;
  final VoidCallback onMenuTap;

  String _formatDuration(int ms) {
    final Duration d = Duration(milliseconds: ms);
    final int hours = d.inHours;
    final int minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextDirection direction = Directionality.of(context);

    final bool hasDuration = entry.durationMs > 0;
    final double progress = hasDuration ? entry.progress.clamp(0.0, 1.0) : 0.0;

    final BorderRadius thumbnailRadius = direction == TextDirection.rtl
        ? const BorderRadius.only(topRight: Radius.circular(18), bottomRight: Radius.circular(18))
        : const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18));

    return Container(
      constraints: const BoxConstraints(minHeight: 174),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.historyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.historyBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 120,
              child: HistoryThumbnail(
                imageUrl: entry.backgroundImageUrl,
                onTap: onOpen,
                borderRadius: thumbnailRadius,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.videoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.historyPrimaryText,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Semantics(
                            button: true,
                            label: l10n.historyMenuRemove,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: onMenuTap,
                              child: const Icon(
                                Icons.more_vert_rounded,
                                size: 24,
                                color: AppColors.historySecondaryText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.videocam_outlined, size: 18, color: AppColors.historyBrightPurple),
                        const SizedBox(width: 6),
                        Text(
                          l10n.historyVideoLabel,
                          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.historySecondaryText),
                        ),
                        if (hasDuration) ...[
                          Text(
                            '  •  ',
                            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.historyMutedText),
                          ),
                          Text(
                            _formatDuration(entry.durationMs),
                            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.historySecondaryText),
                          ),
                        ],
                      ],
                    ),
                    if (hasDuration) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: AppColors.historyProgressTrack,
                                valueColor: const AlwaysStoppedAnimation(AppColors.historyBrightPurple),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              '${(progress * 100).round()}%',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.historyBrightPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      relativeWatchedLabel(l10n, entry.watchedAt),
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.historySecondaryText),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
