import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Create Room's own text-field style: a filled, bordered field with a
/// leading icon and hint text (not a floating label), per the mockup's
/// "🎬 e.g. John Wick 4" / "🔗 Paste your MP4 or M3U8 link here" fields.
///
/// Distinct from the shared [AppTextField] (auth flow) — that widget is
/// built around a floating `labelText`, while this screen's spec calls
/// for icon + placeholder + (for the title field) a live character
/// counter, so a purpose-built field was clearer than bolting optional
/// modes onto the shared one.
class CreateRoomTextField extends StatefulWidget {
  const CreateRoomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.validator,
    this.maxLength,
    this.keyboardType,
    this.isPassword = false,
    this.enabled = true,
    this.onChanged,
    this.trailing,
  });

  final String hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  /// Overrides the trailing widget entirely (e.g. the "Convert" link
  /// row lives below the field itself, not here) — reserved for a
  /// custom suffix icon if a future section needs one.
  final Widget? trailing;

  @override
  State<CreateRoomTextField> createState() => _CreateRoomTextFieldState();
}

class _CreateRoomTextFieldState extends State<CreateRoomTextField> {
  bool _obscured = true;

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && _obscured,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.white),
      cursorColor: AppColors.createRoomPrimary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.createRoomBackground,
        counterStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20, color: AppColors.createRoomPrimary)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.secondaryText,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.trailing,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.createRoomBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.createRoomBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: AppColors.createRoomBorder.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.createRoomPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
