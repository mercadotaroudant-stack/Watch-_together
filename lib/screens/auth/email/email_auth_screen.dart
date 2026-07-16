import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/home_navigation.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/primary_button.dart';

/// Email sign-in (existing account). Reached only via the Email button
/// on [AuthenticationScreen] — there's no route that lands here
/// directly, per spec ("no standalone Sign In screen").
///
/// Continue simulates an *existing* account and goes straight to Home
/// (through [navigateToHomeWithSafetyGate], so the first-launch Safety
/// Notice still shows if this happens to be this device's first-ever
/// arrival at Home); Phase 4 replaces the "existing account" simulation
/// with a real Firebase Auth call.
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      await navigateToHomeWithSafetyGate(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(backgroundColor: AppColors.authBackground, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.emailAuthHeading,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: l10n.emailFieldLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email(l10n),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: l10n.passwordFieldLabel,
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password(l10n),
                      passwordVisibilityToggleSemanticLabel:
                          l10n.passwordVisibilityToggleSemanticLabel,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(RouteNames.forgotPassword),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: Text(
                          l10n.forgotPasswordLink,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(label: l10n.continueButton, height: 58, onPressed: _handleContinue),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.createAccount),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            child: Text(
                              l10n.createAccountLink,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
