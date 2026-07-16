import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// A small, all-caps section label, dark-theme version of
/// `SettingsSectionLabel` (that one is hardcoded white/black for the
/// standalone Settings screen; My Profile stays on the app's real dark
/// palette).
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.menuSecondaryText,
        ),
      ),
    );
  }
}

/// One toggle row — dark-theme equivalent of `SettingsSwitchTile`.
class ProfileSwitchRow extends StatelessWidget {
  const ProfileSwitchRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String emoji;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text(emoji, style: const TextStyle(fontSize: 17))),
          const SizedBox(width: 12),
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
                    color: AppColors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.menuSecondaryText),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.menuPrimaryPurple),
        ],
      ),
    );
  }
}

/// A tappable row showing the current value + chevron — dark-theme
/// equivalent of `SettingsNavTile`.
class ProfileNavRow extends StatelessWidget {
  const ProfileNavRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(width: 26, child: Text(emoji, style: const TextStyle(fontSize: 17))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.menuSecondaryText),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.menuSecondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded card container wrapping one profile section's rows —
/// [AppColors.menuCard] on [AppColors.menuBorder], matching the spec
/// palette.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.menuCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.menuBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
