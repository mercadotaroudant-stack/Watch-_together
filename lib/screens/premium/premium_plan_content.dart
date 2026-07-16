import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';

/// One plan card's worth of display content for the Premium carousel.
///
/// Plan brand names ("Basic"/"Plus"/"Max") are intentionally not
/// localized — kept as literal Latin product names in every language,
/// matching the reference design (the Arabic mock still reads "Basic
/// Plus Max" for the titles while the badge above each is translated).
class PremiumPlanContent {
  const PremiumPlanContent({
    required this.tier,
    required this.name,
    required this.badge,
    required this.subtitle,
    required this.features,
    required this.accentColor,
    required this.icon,
  });

  final PremiumTier tier;
  final String name;
  final String badge;
  final String subtitle;
  final List<String> features;
  final Color accentColor;
  final IconData icon;
}

/// Builds the three plan cards, in carousel order: Basic, Plus, Max.
List<PremiumPlanContent> buildPremiumPlans(AppLocalizations l10n) {
  return [
    PremiumPlanContent(
      tier: PremiumTier.basic,
      name: 'Basic',
      badge: l10n.premiumBasicBadge,
      subtitle: l10n.premiumBasicSubtitle,
      accentColor: AppColors.premiumBasicAccent,
      icon: Icons.workspace_premium_rounded,
      features: [
        l10n.premiumBasicFeature1,
        l10n.premiumBasicFeature2,
        l10n.premiumBasicFeature3,
        l10n.premiumBasicFeature4,
        l10n.premiumBasicFeature5,
        l10n.premiumBasicFeature6,
        l10n.premiumBasicFeature7,
        l10n.premiumBasicFeature8,
      ],
    ),
    PremiumPlanContent(
      tier: PremiumTier.plus,
      name: 'Plus',
      badge: l10n.premiumMostPopularBadge,
      subtitle: l10n.premiumPlusSubtitle,
      accentColor: AppColors.premiumBrightPurple,
      icon: Icons.diamond_rounded,
      features: [
        l10n.premiumPlusFeature1,
        l10n.premiumPlusFeature2,
        l10n.premiumPlusFeature3,
        l10n.premiumPlusFeature4,
        l10n.premiumPlusFeature5,
        l10n.premiumPlusFeature6,
        l10n.premiumPlusFeature7,
        l10n.premiumPlusFeature8,
        l10n.premiumPlusFeature9,
        l10n.premiumPlusFeature10,
        l10n.premiumPlusFeature11,
      ],
    ),
    PremiumPlanContent(
      tier: PremiumTier.max,
      name: 'Max',
      badge: l10n.premiumMaxBadge,
      subtitle: l10n.premiumMaxSubtitle,
      accentColor: AppColors.premiumMaxAccent,
      icon: Icons.workspace_premium_rounded,
      features: [
        l10n.premiumMaxFeature1,
        l10n.premiumMaxFeature2,
        l10n.premiumMaxFeature3,
        l10n.premiumMaxFeature4,
        l10n.premiumMaxFeature5,
        l10n.premiumMaxFeature6,
        l10n.premiumMaxFeature7,
        l10n.premiumMaxFeature8,
        l10n.premiumMaxFeature9,
        l10n.premiumMaxFeature10,
        l10n.premiumMaxFeature11,
      ],
    ),
  ];
}
