import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/watch_history_model.dart';

/// A single 150×210dp Continue Watching poster card, driven entirely by
/// a real [WatchHistoryModel] entry — poster, title, and a progress bar
/// computed from the entry's own `lastPositionMs`/`durationMs`, never a
/// placeholder value.
class ContinueWatchingPosterCard extends StatelessWidget {
  const ContinueWatchingPosterCard({super.key, required this.entry, required this.onTap});

  final WatchHistoryModel entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double progress = entry.progress.clamp(0.0, 1.0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.homeCard,
            border: Border.all(color: AppColors.homeBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Poster(url: entry.backgroundImageUrl),
              const Center(
                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.videoTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.homeProgressTrack,
                          valueColor: const AlwaysStoppedAnimation(AppColors.homePrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = url != null && url!.isNotEmpty;
    if (!hasImage) return _fallback();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homePrimary, AppColors.homeSecondary],
        ),
      ),
    );
  }
}
