import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import 'legal_document_screen.dart';

/// TODO(legal): replace [_sections] with WatchTogether's actual Terms
/// of Service once it exists.
///
/// Note: the source spec's Terms of Service section (§9) was cut off
/// before stating its requirements. This mirrors §8 (Privacy Policy)'s
/// explicit instruction — preserve the screen architecture and clearly
/// mark the content integration point — on the assumption both legal
/// documents should be treated the same way until real ToS
/// requirements are provided.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return LegalDocumentScreen(
      title: l10n.drawerTermsOfService,
      introNote: l10n.legalContentPendingNote,
      sections: [
        LegalSection(heading: l10n.termsAcceptanceTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.termsUserResponsibilitiesTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.termsSubscriptionsTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.termsTerminationTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.termsLiabilityTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.termsContactTitle, body: l10n.legalPlaceholderBody),
      ],
    );
  }
}
