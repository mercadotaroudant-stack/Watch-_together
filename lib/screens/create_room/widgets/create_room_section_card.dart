import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The "① Section Title" card shell every Create Room section (Room
/// Type, Movie/Video Information, Friends, Room Settings, ...) is built
/// on: a numbered badge + title row, an optional trailing widget (e.g.
/// the Free/Premium Plan badge on Room Settings), then [child] inside a
/// bordered, rounded card using this screen's own dark palette.
///
/// Kept as one shared widget rather than duplicating the badge+card
/// chrome in every section file, so the exact spacing/typography only
/// has one place to stay consistent.
class CreateRoomSectionCard extends StatelessWidget {
  const CreateRoomSectionCard({
    super.key,
    required this.number,
    required this.title,
    required this.child,
    this.trailing,
  });

  final int number;
  final String title;
  final Widget child;
  final Widget? trailing;

  static const double _badgeSize = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.createRoomCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.createRoomBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.createRoomPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
