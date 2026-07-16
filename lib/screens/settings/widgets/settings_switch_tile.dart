import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single toggle row on the (white/black) Settings screen.
///
/// Deliberately hardcodes black text / a light divider rather than
/// reading from [Theme.of(context)] — this screen is the one
/// intentional exception to WatchTogether's app-wide dark theme, so it
/// must not accidentally inherit dark-theme colors if a parent `Theme`
/// changes later.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text(emoji, style: const TextStyle(fontSize: 17))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }
}
