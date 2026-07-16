import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/primary_button.dart';

/// Forgot Password — email in, "Send Reset Email", then an inline
/// success confirmation. Reached only via "Forgot Password?" on
/// [EmailAuthScreen].
///
/// No email is actually sent (no Firebase in this phase) — submitting a
/// valid email just swaps this screen's content to the success state.
/// Phase 4 wires the real `FirebaseAuth.sendPasswordResetEmail` call in
/// front of that same success UI.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(backgroundColor: AppColors.authBackground, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _emailSent
                    ? _SuccessContent(key: const ValueKey('success'), email: _emailController.text.trim())
                    : _FormContent(
                        key: const ValueKey('form'),
                        formKey: _formKey,
                        emailController: _emailController,
                        onSubmit: _handleSendResetEmail,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.forgotPasswordHeading,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.forgotPasswordSubtitle,
            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.secondaryText, height: 1.4),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: l10n.emailFieldLabel,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email(l10n),
          ),
          const SizedBox(height: 32),
          PrimaryButton(label: l10n.sendResetEmail, height: 58, onPressed: onSubmit),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.resetEmailSuccessTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.resetEmailSuccessMessage(email),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.secondaryText, height: 1.4),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: l10n.backToSignIn,
          height: 58,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
