import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';

class PremiumLegalText extends StatelessWidget {
  const PremiumLegalText({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextStyle baseStyle = GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.premiumMutedText,
    );
    final TextStyle linkStyle = baseStyle.copyWith(
      color: AppColors.premiumAccentPurple,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.premiumLegalPrefix),
          TextSpan(
            text: l10n.drawerTermsOfService,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(RouteNames.termsOfService),
          ),
          TextSpan(text: l10n.premiumLegalConjunction),
          TextSpan(
            text: l10n.drawerPrivacyPolicy,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(RouteNames.privacyPolicy),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
