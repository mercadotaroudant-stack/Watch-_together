import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/support_config.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/repository_providers.dart';
import '../profile/widgets/profile_shared_rows.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.menuBackground,
      appBar: AppBar(
        backgroundColor: AppColors.menuBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          l10n.drawerHelpSupport,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: const [
            _FaqSection(),
            _ReportProblemSection(),
            _ContactSupportSection(),
          ],
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<(String, String)> faqs = [
      (l10n.faqQuestion1, l10n.faqAnswer1),
      (l10n.faqQuestion2, l10n.faqAnswer2),
      (l10n.faqQuestion3, l10n.faqAnswer3),
      (l10n.faqQuestion4, l10n.faqAnswer4),
      (l10n.faqQuestion5, l10n.faqAnswer5),
      (l10n.faqQuestion6, l10n.faqAnswer6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.helpFaqSection),
        Container(
          decoration: BoxDecoration(
            color: AppColors.menuCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.menuBorder),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: AppColors.menuBorder),
            child: Column(
              children: [
                for (int i = 0; i < faqs.length; i++)
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: AppColors.menuPrimaryPurple,
                    collapsedIconColor: AppColors.menuSecondaryText,
                    title: Text(
                      faqs[i].$1,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          faqs[i].$2,
                          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.menuSecondaryText),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportProblemSection extends ConsumerStatefulWidget {
  const _ReportProblemSection();

  @override
  ConsumerState<_ReportProblemSection> createState() => _ReportProblemSectionState();
}

class _ReportProblemSectionState extends ConsumerState<_ReportProblemSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.helpReportProblemSection),
        ProfileSectionCard(
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.helpReportProblemHint,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.menuSecondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: 500,
              enabled: !_isSubmitting,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white),
              decoration: InputDecoration(
                hintText: l10n.helpReportProblemPlaceholder,
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.menuSecondaryText),
                filled: true,
                fillColor: AppColors.menuSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.menuPrimaryPurple,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : Text(
                        l10n.helpReportProblemSubmit,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            if (_submitted) ...[
              const SizedBox(height: 8),
              Text(
                l10n.helpReportProblemSuccess,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.menuSuccess),
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String description = _controller.text.trim();
    if (description.isEmpty) return;

    final String? uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    setState(() {
      _isSubmitting = true;
      _submitted = false;
    });
    try {
      // Reuses the same real ReportRepository/`reports` collection the
      // Friends flow's "Report User" sheet writes to — this is a
      // problem report with no reported user/room, not a new system.
      await ref.read(reportRepositoryProvider).submitReport(
            reporterId: uid,
            reason: ReportReason.other,
            description: description,
          );
      if (mounted) {
        _controller.clear();
        setState(() => _submitted = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.helpReportProblemError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _ContactSupportSection extends StatelessWidget {
  const _ContactSupportSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.helpContactSupportSection),
        ProfileSectionCard(
          children: [
            ProfileNavRow(
              emoji: '💬',
              label: SupportConfig.isConfigured
                  ? l10n.helpContactSupportAction
                  : l10n.helpContactSupportUnavailable,
              value: '',
              onTap: () => _contactSupport(context, l10n),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _contactSupport(BuildContext context, AppLocalizations l10n) async {
    if (!SupportConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.helpContactSupportUnavailable)),
      );
      return;
    }
    final Uri uri = SupportConfig.supportEmail.isNotEmpty
        ? Uri(scheme: 'mailto', path: SupportConfig.supportEmail)
        : Uri.parse(SupportConfig.supportUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
