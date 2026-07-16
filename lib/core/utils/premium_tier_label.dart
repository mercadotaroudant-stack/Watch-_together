import '../../models/enums.dart';
import '../localization/generated/app_localizations.dart';

/// "Premium Basic"/"Premium Plus"/"Premium Max" — the one place this
/// mapping lives, so the drawer header and My Profile's Current Plan
/// row can't drift out of sync with each other.
String premiumTierLabel(AppLocalizations l10n, PremiumTier tier) {
  return switch (tier) {
    PremiumTier.basic => l10n.drawerPremiumBadgeBasic,
    PremiumTier.plus => l10n.drawerPremiumBadgePlus,
    PremiumTier.max => l10n.drawerPremiumBadgeMax,
  };
}
