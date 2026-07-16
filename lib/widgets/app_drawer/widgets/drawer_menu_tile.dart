import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// One row of [AppDrawer]'s menu list — an emoji glyph, a label, and an
/// optional trailing badge (used for e.g. an unread notifications
/// count), styled consistently for both the 13 standard items and the
/// destructive "Logout" row via [isDestructive].
class DrawerMenuTile extends StatelessWidget {
  const DrawerMenuTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailingBadge,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  /// Small count/text shown at the trailing edge (e.g. unread badge).
  final String? trailingBadge;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isDestructive ? AppColors.error : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailingBadge!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (!isDestructive)
                Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
