import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'create_room_text_field.dart';

/// Section 2 — movie title, optional cover image, and the video URL
/// (with the MP4-free / M3U8-premium format badges underneath).
class MovieInfoSection extends StatelessWidget {
  const MovieInfoSection({
    super.key,
    required this.titleController,
    required this.videoUrlController,
    required this.titleValidator,
    required this.videoUrlValidator,
    required this.isPremium,
    required this.onChooseImagePressed,
    required this.onConvertVideoPressed,
  });

  final TextEditingController titleController;
  final TextEditingController videoUrlController;
  final String? Function(String?) titleValidator;
  final String? Function(String?) videoUrlValidator;
  final bool isPremium;
  final VoidCallback onChooseImagePressed;
  final VoidCallback onConvertVideoPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.roomTitleFieldLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        CreateRoomTextField(
          controller: titleController,
          hintText: l10n.roomTitleFieldHint,
          prefixIcon: Icons.movie_creation_outlined,
          maxLength: 100,
          validator: titleValidator,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.roomCoverLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.createRoomBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.createRoomBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.createRoomPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.createRoomPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.roomCoverSubtitle,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.secondaryText),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onChooseImagePressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.createRoomPrimaryHover,
                  side: const BorderSide(color: AppColors.createRoomPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: Text(
                  l10n.chooseImageButton,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.videoUrlFieldLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        CreateRoomTextField(
          controller: videoUrlController,
          hintText: l10n.videoUrlFieldHint,
          prefixIcon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          validator: videoUrlValidator,
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: '${l10n.convertVideoPrompt} ${l10n.convertVideoLink}',
          child: InkWell(
            onTap: onConvertVideoPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${l10n.convertVideoPrompt} ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  Text(
                    l10n.convertVideoLink,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.createRoomPrimaryHover,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.supportedFormatsLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.createRoomPrimaryHover,
              ),
            ),
            const _FormatBadge(label: 'MP4', icon: Icons.check_circle_rounded, color: AppColors.success),
            const _FormatBadge(label: 'M3U8 (HLS)', icon: Icons.workspace_premium_rounded, color: AppColors.warning),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '👑 ${l10n.premiumFeatureBadge}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
