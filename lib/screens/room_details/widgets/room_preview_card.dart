import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/room_model.dart';

/// The large gradient room preview: no real video/poster, per spec —
/// just a dark purple gradient, a glowing centered play icon, a LIVE
/// badge, and a title/watching-count overlay at the bottom.
class RoomPreviewCard extends StatefulWidget {
  const RoomPreviewCard({
    super.key,
    required this.room,
    required this.watchingCount,
    this.onTap,
  });

  final RoomModel room;
  final int watchingCount;

  /// Opens the Video Player (Phase 3.8) for this room. Optional so this
  /// card still renders as a plain preview wherever a caller doesn't
  /// want it tappable.
  final VoidCallback? onTap;

  static const double _height = 220;
  static const double _radius = 24;

  @override
  State<RoomPreviewCard> createState() => _RoomPreviewCardState();
}

class _RoomPreviewCardState extends State<RoomPreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isLive = widget.room.status == RoomStatus.playing;

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(RoomPreviewCard._radius),
      child: SizedBox(
        height: RoomPreviewCard._height,
        width: double.infinity,
        child: Stack(
          children: [
            // Base gradient placeholder — no images, per spec.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A1458),
                    AppColors.roomCard,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.theaters_rounded,
                  size: 96,
                  color: AppColors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Glowing centered play icon.
            Center(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final double glow = 0.4 + (_glowController.value * 0.35);
                  return Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(glow),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: const Icon(Icons.play_arrow_rounded, size: 40, color: AppColors.white),
              ),
            ),

            // LIVE badge, top-left.
            if (isLive)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 70,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.liveBadge,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Title + watching count overlay, bottom.
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Text(
                        l10n.watchingCount(widget.watchingCount),
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
