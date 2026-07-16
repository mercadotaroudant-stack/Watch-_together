import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/primary_button.dart';

/// The "Continue with Google" / "Continue with Facebook" confirmation
/// dialog.
///
/// One widget for both providers (only the [provider] name text
/// differs) — this is the UI-only stand-in for a real account picker;
/// Phase 4 replaces tapping "Continue" here with the actual Google/
/// Facebook sign-in SDK flow, per the spec's note that this dialog's
/// *behavior* changes but its presence doesn't.
///
/// Returns `true` via [Navigator.pop] if the user taps Continue, `false`
/// (or `null`) if they cancel/dismiss — callers only need to act on the
/// `true` case.
class SocialContinueDialog extends StatelessWidget {
  const SocialContinueDialog({super.key, required this.provider});

  final String provider;

  static Future<bool?> show(BuildContext context, {required String provider}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SocialContinueDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.socialDialogTitle(provider),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.socialDialogMessage(provider),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.continueButton,
                    height: 48,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
