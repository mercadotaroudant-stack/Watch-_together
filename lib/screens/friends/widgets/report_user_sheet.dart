import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';

class ReportUserSheet extends StatelessWidget {
  const ReportUserSheet({super.key, required this.userName});

  final String userName;

  static Future<ReportReason?> show(BuildContext context, {required String userName}) {
    return showModalBottomSheet<ReportReason>(
      context: context,
      backgroundColor: AppColors.friendsCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => ReportUserSheet(userName: userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final Map<ReportReason, String> reasons = {
      ReportReason.spam: l10n.friendsReportReasonSpam,
      ReportReason.harassment: l10n.friendsReportReasonHarassment,
      ReportReason.inappropriateContent: l10n.friendsReportReasonInappropriate,
      ReportReason.impersonation: l10n.friendsReportReasonImpersonation,
      ReportReason.other: l10n.friendsReportReasonOther,
    };

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.friendsBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.friendsReportPrompt(userName),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (final entry in reasons.entries)
              ListTile(
                onTap: () => Navigator.of(context).pop(entry.key),
                title: Text(
                  entry.value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
