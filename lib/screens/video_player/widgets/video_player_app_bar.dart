import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class VideoPlayerAppBar extends StatelessWidget {
  const VideoPlayerAppBar({
    super.key,
    required this.title,
    required this.isAdmin,
    required this.memberCount,
    required this.maxParticipants,
    required this.onBackPressed,
    required this.onLeavePressed,
  });

  final String title;
  final bool isAdmin;
  final int memberCount;
  final int maxParticipants;
  final VoidCallback onBackPressed;
  final VoidCallback onLeavePressed;

  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.videoPlayerBackground,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.back,
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 20),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(
                              l10n.videoPlayerAdminBadge,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Icon(Icons.people_alt_outlined,
                        size: 14, color: AppColors.videoPlayerSecondaryText),
                    const SizedBox(width: 4),
                    Text(
                      l10n.roomMembersCount(memberCount, maxParticipants),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.videoPlayerSecondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: l10n.leaveRoom,
            child: OutlinedButton.icon(
              onPressed: onLeavePressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: Text(
                l10n.leaveRoom,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
