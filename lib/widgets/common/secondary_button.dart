import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's low-emphasis text button: transparent, no border, muted
/// secondary-text color. Used for onboarding's Skip/Back, and anywhere
/// else a same-weight "quiet" action sits next to a [PrimaryButton].
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const Color _textColor = Color(0xFFA1A1AA);
  static const double _height = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Semantics(
        button: true,
        label: semanticLabel ?? label,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _textColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textColor,
            ),
          ),
        ),
      ),
    );
  }
}
