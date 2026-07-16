import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import 'legal_document_screen.dart';

/// Full-page expansion of the same points shown once in
/// `SafetyNoticeDialog` after account creation — this screen doesn't
/// change that dialog's one-time acceptance behavior, it just makes the
/// same rules available to re-read any time from the drawer.
class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return LegalDocumentScreen(
      title: l10n.drawerCommunityGuidelines,
      sections: [
        LegalSection(heading: l10n.guidelinesResponsibleUseTitle, body: l10n.guidelinesResponsibleUseBody),
        LegalSection(heading: l10n.guidelinesAllowedContentTitle, body: l10n.guidelinesAllowedContentBody),
        LegalSection(
          heading: l10n.guidelinesProhibitedContentTitle,
          body: l10n.guidelinesProhibitedContentBody,
        ),
        LegalSection(heading: l10n.guidelinesLocalLawsTitle, body: l10n.guidelinesLocalLawsBody),
        LegalSection(heading: l10n.guidelinesRespectOthersTitle, body: l10n.guidelinesRespectOthersBody),
        LegalSection(heading: l10n.guidelinesReportingTitle, body: l10n.guidelinesReportingBody),
      ],
    );
  }
}
