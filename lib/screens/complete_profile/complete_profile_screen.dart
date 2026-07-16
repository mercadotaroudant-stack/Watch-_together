import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/countries.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/home_navigation.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/primary_button.dart';
import 'widgets/country_picker_field.dart';
import 'widgets/language_picker_field.dart';
import 'widgets/profile_picture_picker.dart';

/// Shown exactly once for a new account, regardless of which sign-up
/// path led here (Google, Facebook, or email Create Account) — all
/// three navigate to `RouteNames.completeProfile`.
///
/// Continue is a UI-only stand-in today: no data is persisted anywhere
/// (no Firebase in this phase). Phase 4 saves this form's values to the
/// `users` Firestore document (see `UserModel`/`UserRepository`,
/// already built in Phase 2) before navigating onward. Navigation itself
/// goes through [navigateToHomeWithSafetyGate] so the first-launch
/// Safety Notice (Phase 3.4.1) is guaranteed to show before Home, since
/// this is the completion point for every *new*-account path.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _ageController = TextEditingController();

  Country? _selectedCountry;
  AppLanguage? _selectedLanguage;

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _handlePhotoTap() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.photoUploadComingSoonMessage)),
    );
  }

  Future<void> _handleContinue() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool formValid = _formKey.currentState?.validate() ?? false;
    final bool countryValid = _selectedCountry != null;

    if (!countryValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.countryRequiredError)),
      );
    }
    if (!formValid || !countryValid) return;

    await navigateToHomeWithSafetyGate(context, ref);
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.completeProfileHeading,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ProfilePicturePicker(onCameraPressed: _handlePhotoTap),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: l10n.displayNameFieldLabel,
                      controller: _displayNameController,
                      validator: Validators.displayName(l10n),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: l10n.ageFieldLabel,
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.age(l10n),
                    ),
                    const SizedBox(height: 20),
                    CountryPickerField(
                      selected: _selectedCountry,
                      onChanged: (country) => setState(() => _selectedCountry = country),
                    ),
                    const SizedBox(height: 20),
                    LanguagePickerField(
                      selected: _selectedLanguage,
                      onChanged: (language) => setState(() => _selectedLanguage = language),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.continueButton,
                      height: 58,
                      useGradient: true,
                      onPressed: _handleContinue,
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
