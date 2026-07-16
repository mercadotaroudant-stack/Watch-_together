import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'widgets/auth_divider.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/social_continue_dialog.dart';

/// The authentication entry point: Google / Facebook / Email choice.
///
/// Per spec there is no standalone "Sign In" screen — this *is* the
/// app's one authentication landing screen, reached from onboarding's
/// Skip/Get Started. Google and Facebook both show
/// [SocialContinueDialog] then go straight to Complete Profile (a
/// UI-only stand-in — Phase 4 replaces this with real Google/Facebook
/// sign-in that branches on whether the account is new). Email opens
/// the separate email sign-in flow.
class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  Future<void> _handleGooglePressed(BuildContext context) async {
    final bool? confirmed = await SocialContinueDialog.show(context, provider: 'Google');
    if (confirmed == true && context.mounted) {
      context.go(RouteNames.completeProfile);
    }
  }

  Future<void> _handleFacebookPressed(BuildContext context) async {
    final bool? confirmed = await SocialContinueDialog.show(context, provider: 'Facebook');
    if (confirmed == true && context.mounted) {
      context.go(RouteNames.completeProfile);
    }
  }

  void _handleEmailPressed(BuildContext context) => context.push(RouteNames.emailAuth);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.authCard,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Logo(),
                    const SizedBox(height: 20),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SocialAuthButton(
                      label: l10n.continueWithGoogle,
                      icon: const _GoogleIcon(),
                      backgroundColor: AppColors.white,
                      foregroundColor: Colors.black,
                      onPressed: () => _handleGooglePressed(context),
                    ),
                    const SizedBox(height: 16),
                    SocialAuthButton(
                      label: l10n.continueWithFacebook,
                      icon: const Icon(Icons.facebook, size: 24, color: AppColors.white),
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: AppColors.white,
                      onPressed: () => _handleFacebookPressed(context),
                    ),
                    const SizedBox(height: 24),
                    const AuthDivider(),
                    const SizedBox(height: 24),
                    SocialAuthButton(
                      label: l10n.continueWithEmail,
                      icon: const Icon(Icons.mail_outline_rounded, size: 24, color: AppColors.primary),
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      onPressed: () => _handleEmailPressed(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    const double size = 96;

    return Semantics(
      image: true,
      label: l10n.splashLogoSemanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          AssetPaths.appLogo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.white, size: 44),
          ),
        ),
      ),
    );
  }
}

/// A simple "G" glyph standing in for Google's brand mark.
///
/// The real multi-color Google "G" logo is Google's IP and isn't
/// bundled with Flutter/Material Icons, and this sandbox has no network
/// access to source the official asset — a plain glyph avoids
/// reproducing that mark inaccurately. Swap for the official asset
/// (via `google_sign_in`'s branding guidelines) when wiring real Google
/// Sign-In in Phase 4.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
    );
  }
}
