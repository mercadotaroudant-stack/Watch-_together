import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/primary_button.dart';

/// Email sign-up (new account). Reached only via "Create Account" on
/// [EmailAuthScreen] — there is no independent Sign Up route, per spec.
///
/// On success, goes to Complete Profile — this is always a new account
/// by definition, so unlike [EmailAuthScreen] there's no "does this
/// account already exist" branch to simulate.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go(RouteNames.completeProfile);
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
                      l10n.createAccountHeading,
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
                      validator: Validators.password(l10n),
                      passwordVisibilityToggleSemanticLabel:
                          l10n.passwordVisibilityToggleSemanticLabel,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: l10n.confirmPasswordFieldLabel,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.confirmPassword(
                        l10n,
                        () => _passwordController.text,
                      ),
                      passwordVisibilityToggleSemanticLabel:
                          l10n.passwordVisibilityToggleSemanticLabel,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.createAccountHeading,
                      height: 58,
                      onPressed: _handleCreateAccount,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            child: Text(
                              l10n.signInLink,
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
