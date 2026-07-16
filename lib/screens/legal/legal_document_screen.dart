import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Shared shell for Community Guidelines / Privacy Policy / Terms of
/// Service — a title, an optional intro note, and a list of
/// heading+body sections. Kept as one real widget rather than three
/// near-duplicate screens so all three stay visually consistent and
/// any future content update only touches the content lists, not
/// layout code.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.title,
    required this.sections,
    this.introNote,
    super.key,
  });

  final String title;
  final List<LegalSection> sections;

  /// An optional banner shown above the sections — used by Privacy
  /// Policy/Terms of Service to flag that final legal copy hasn't been
  /// provided yet, per the integration-point requirement in the spec.
  final String? introNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuBackground,
      appBar: AppBar(
        backgroundColor: AppColors.menuBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (introNote != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.menuGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.menuGold.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.menuGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        introNote!,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.menuGold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (final section in sections) ...[
              Text(
                section.heading,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.menuSecondaryText,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
