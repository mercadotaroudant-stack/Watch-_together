import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Per spec: no Visa/Mastercard/PayPal/Apple Pay logos, since none of
/// those are actually integrated — this app charges through Google
/// Play Billing only.
class PaymentSecuritySection extends StatelessWidget {
  const PaymentSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.premiumCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.premiumCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, size: 52, color: AppColors.premiumBrightPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.premiumSecurePaymentTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.premiumSecurePaymentDescription,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.premiumSecondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
