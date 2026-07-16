import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A small, all-caps section label used above [SettingsScreen]'s
/// General list. Colors are hardcoded (not pulled from [AppColors])
/// because this screen intentionally breaks from the app's dark theme —
/// per spec, Settings is a white-background/black-text screen.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: const Color(0xFF6B7280), // neutral gray-500, readable on white
        ),
      ),
    );
  }
}
