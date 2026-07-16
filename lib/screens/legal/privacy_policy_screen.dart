import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import 'legal_document_screen.dart';

/// TODO(legal): replace [_sections] with WatchTogether's actual,
/// lawyer-reviewed Privacy Policy once it exists. The section list
/// below is a real, honest placeholder — it names the categories a
/// privacy policy needs to cover (what's collected, why, third
/// parties, retention, rights) without asserting any specific legal
/// claim about how WatchTogether actually handles data, since no real
/// policy text was provided to base that on.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return LegalDocumentScreen(
      title: l10n.drawerPrivacyPolicy,
      introNote: l10n.legalContentPendingNote,
      sections: [
        LegalSection(heading: l10n.privacyDataCollectedTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.privacyDataUseTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.privacyThirdPartiesTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.privacyRetentionTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.privacyYourRightsTitle, body: l10n.legalPlaceholderBody),
        LegalSection(heading: l10n.privacyContactTitle, body: l10n.legalPlaceholderBody),
      ],
    );
  }
}
