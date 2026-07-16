import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'create_room_text_field.dart';

/// Section 6 — the room password field, only meaningful (and only
/// validated) while [enabled] is true, i.e. while Room Type is Private.
/// Left visible-but-disabled otherwise, matching this screen's mockup,
/// rather than collapsing away — so the layout doesn't jump when
/// switching room type.
class PasswordSection extends StatelessWidget {
  const PasswordSection({
    super.key,
    required this.controller,
    required this.enabled,
    required this.validator,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateRoomTextField(
            controller: controller,
            hintText: l10n.roomPasswordFieldHint,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            enabled: enabled,
            maxLength: 30,
            validator: enabled ? validator : null,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.roomPasswordHelperText,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
