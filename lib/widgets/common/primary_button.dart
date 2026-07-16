import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// The app's primary filled action button: solid (or gradient) purple,
/// white Poppins SemiBold label, rounded corners.
///
/// Deliberately its own widget rather than relying solely on
/// `ElevatedButtonTheme` (Phase 1's global theme default is a smaller,
/// more general-purpose button — see `core/theme/app_theme.dart`): this
/// exact size/weight combination is a specific "hero CTA" style first
/// needed by onboarding's Next/Get Started button, and is reused
/// anywhere else that same visual weight is called for. [height] and
/// [useGradient] are configurable because different screens specify
/// slightly different values (onboarding: 56dp solid; authentication:
/// 58dp solid; Complete Profile: 58dp gradient) while everything else
/// about the button stays identical.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.height = 56,
    this.radius = 16,
    this.useGradient = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Overrides [label] for screen readers when the visible text alone
  /// wouldn't be a clear enough action description.
  final String? semanticLabel;

  final double height;
  final double radius;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    final Widget labelWidget = Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );

    return SizedBox(
      height: height,
      child: Semantics(
        button: true,
        label: semanticLabel ?? label,
        child: useGradient
            ? Material(
                color: Colors.transparent,
                borderRadius: borderRadius,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: isEnabled
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.4),
                              AppColors.secondary.withOpacity(0.4),
                            ],
                          ),
                  ),
                  child: InkWell(
                    borderRadius: borderRadius,
                    onTap: onPressed,
                    child: Center(child: labelWidget),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: labelWidget,
              ),
      ),
    );
  }
}
