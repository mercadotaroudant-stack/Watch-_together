import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A tappable settings row showing the current value and a chevron —
/// used for "App Language" and "Default Video Quality", which open a
/// picker rather than toggling directly.
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 26, child: Text(emoji, style: const TextStyle(fontSize: 17))),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
