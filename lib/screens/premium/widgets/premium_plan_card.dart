import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/subscription_products.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/premium_model.dart';
import '../../../providers/premium_providers.dart';
import '../premium_plan_content.dart';

class PremiumPlanCard extends ConsumerWidget {
  const PremiumPlanCard({
    required this.content,
    required this.billingPeriod,
    required this.currentPremium,
    super.key,
  });

  final PremiumPlanContent content;
  final PremiumPlan billingPeriod;

  /// The user's real, current subscription (from Firestore via
  /// `premiumStatusProvider`) — `null`/inactive if they don't have one.
  /// Used only to show this exact plan as already-owned; never assumed.
  final PremiumModel? currentPremium;

  bool get _isPlus => content.tier == PremiumTier.plus;
  bool get _isMax => content.tier == PremiumTier.max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String productId = SubscriptionProductIds.forPlan(content.tier, billingPeriod);
    final bool isConfigured = productId.isNotEmpty;
    final AsyncValue<Map<String, ProductDetails>> productsAsync =
        ref.watch(premiumProductDetailsProvider);
    final ProductDetails? product = productsAsync.valueOrNull?[productId];
    final PurchaseState purchaseState = ref.watch(purchaseControllerProvider);
    final bool isPending = purchaseState.isPending(content.tier);
    final bool isCurrentPlan = currentPremium?.isActive == true &&
        currentPremium?.tier == content.tier &&
        currentPremium?.plan == billingPeriod;
    final bool canPurchase = isConfigured && product != null && !isPending && !isCurrentPlan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: _isPlus ? null : AppColors.premiumCardBackground,
        gradient: _isPlus
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.premiumPlusGradientStart, AppColors.premiumPlusGradientEnd],
              )
            : null,
        border: Border.all(
          color: _isPlus
              ? AppColors.premiumPlusBorder
              : _isMax
                  ? AppColors.premiumMaxBorder
                  : AppColors.premiumCardBorder,
          width: _isPlus ? 2 : (_isMax ? 1.5 : 1),
        ),
        boxShadow: [
          if (_isPlus)
            BoxShadow(
              color: AppColors.premiumBrightPurple.withOpacity(0.25),
              blurRadius: 24,
              spreadRadius: 2,
            )
          else if (_isMax)
            BoxShadow(
              color: AppColors.premiumMaxAccent.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 1,
            )
          else
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(content: content),
          const SizedBox(height: 20),
          _IconGlow(content: content),
          const SizedBox(height: 16),
          Text(
            content.name,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: _isPlus ? AppColors.white : content.accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content.subtitle,
            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.premiumSecondaryText),
          ),
          const SizedBox(height: 20),
          _PriceRow(
            product: product,
            isConfigured: isConfigured,
            billingPeriod: billingPeriod,
            l10n: l10n,
          ),
          const SizedBox(height: 20),
          _ChoosePlanButton(
            content: content,
            enabled: canPurchase,
            isLoading: isPending,
            isCurrentPlan: isCurrentPlan,
            l10n: l10n,
            onPressed: canPurchase
                ? () => ref
                    .read(purchaseControllerProvider.notifier)
                    .buy(content.tier, billingPeriod)
                : null,
          ),
          const SizedBox(height: 20),
          ...content.features.expand(
            (feature) => [
              _FeatureRow(text: feature, accentColor: content.accentColor),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.content});

  final PremiumPlanContent content;

  @override
  Widget build(BuildContext context) {
    final bool isPlus = content.tier == PremiumTier.plus;
    final bool isMax = content.tier == PremiumTier.max;

    return Container(
      height: isPlus ? 34 : 30,
      padding: EdgeInsets.symmetric(horizontal: isPlus ? 18 : 14),
      decoration: BoxDecoration(
        gradient: isPlus
            ? const LinearGradient(
                colors: [AppColors.premiumPrimaryPurple, AppColors.premiumGradientEnd],
              )
            : null,
        color: isMax
            ? AppColors.premiumMaxAccent
            : (isPlus ? null : AppColors.premiumBasicBadgeBackground),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlus) ...[
            const Icon(Icons.star_rounded, size: 16, color: AppColors.white),
            const SizedBox(width: 6),
          ],
          Text(
            content.badge,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isMax
                  ? AppColors.premiumMaxBadgeText
                  : (isPlus ? AppColors.white : AppColors.premiumBasicBadgeText),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGlow extends StatelessWidget {
  const _IconGlow({required this.content});

  final PremiumPlanContent content;

  @override
  Widget build(BuildContext context) {
    final double size = content.tier == PremiumTier.basic ? 90 : 100;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  content.accentColor.withOpacity(0.3),
                  content.accentColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
          Icon(content.icon, size: size * 0.6, color: content.accentColor),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.product,
    required this.isConfigured,
    required this.billingPeriod,
    required this.l10n,
  });

  final ProductDetails? product;
  final bool isConfigured;
  final PremiumPlan billingPeriod;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Text(
        isConfigured ? l10n.premiumPriceLoading : l10n.premiumPriceUnavailable,
        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.premiumMutedText),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          // The real, already-localized/currency-formatted price string
          // straight from Google Play — never computed or hardcoded here.
          product!.price,
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          billingPeriod == PremiumPlan.yearly ? l10n.premiumPerYearSuffix : l10n.premiumPerMonthSuffix,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.premiumSecondaryText),
        ),
      ],
    );
  }
}

class _ChoosePlanButton extends StatefulWidget {
  const _ChoosePlanButton({
    required this.content,
    required this.enabled,
    required this.isLoading,
    required this.isCurrentPlan,
    required this.l10n,
    required this.onPressed,
  });

  final PremiumPlanContent content;
  final bool enabled;
  final bool isLoading;
  final bool isCurrentPlan;
  final AppLocalizations l10n;
  final VoidCallback? onPressed;

  @override
  State<_ChoosePlanButton> createState() => _ChoosePlanButtonState();
}

class _ChoosePlanButtonState extends State<_ChoosePlanButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final bool isPlus = widget.content.tier == PremiumTier.plus;
    final bool isMax = widget.content.tier == PremiumTier.max;

    final Color textColor = isPlus
        ? AppColors.white
        : (isMax ? AppColors.premiumMaxAccent : AppColors.premiumAccentPurple);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _scale = 0.97) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.enabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: 56,
              decoration: BoxDecoration(
                gradient: isPlus
                    ? const LinearGradient(
                        colors: [AppColors.premiumPrimaryPurple, AppColors.premiumGradientEnd],
                      )
                    : null,
                color: isPlus ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isPlus
                    ? null
                    : Border.all(
                        color: isMax ? AppColors.premiumMaxAccent : AppColors.premiumAccentPurple,
                        width: 1.5,
                      ),
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: textColor),
                      )
                    : Text(
                        widget.isCurrentPlan
                            ? widget.l10n.premiumCurrentPlanButton
                            : widget.l10n.premiumChoosePlanButton,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: widget.enabled ? textColor : textColor.withOpacity(0.4),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 42),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 22, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 15, color: AppColors.premiumFeatureText),
            ),
          ),
        ],
      ),
    );
  }
}
