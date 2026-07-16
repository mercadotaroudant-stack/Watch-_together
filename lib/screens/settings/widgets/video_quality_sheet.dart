import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../providers/general_settings_provider.dart';

/// The picker opened by tapping "Default Video Quality" in
/// [SettingsScreen]. Kept as a plain white sheet (rather than the app's
/// usual dark [AppColors.surface] bottom sheet) to match the white/black
/// styling of the Settings screen it's launched from.
class VideoQualitySheet extends StatelessWidget {
  const VideoQualitySheet({super.key, required this.selected, required this.onSelected});

  final VideoQuality selected;
  final ValueChanged<VideoQuality> onSelected;

  static Future<void> show(
    BuildContext context, {
    required VideoQuality selected,
    required ValueChanged<VideoQuality> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => VideoQualitySheet(selected: selected, onSelected: onSelected),
    );
  }

  String _labelFor(AppLocalizations l10n, VideoQuality quality) {
    return switch (quality) {
      VideoQuality.auto => l10n.videoQualityAuto,
      VideoQuality.p1080 => l10n.videoQuality1080,
      VideoQuality.p720 => l10n.videoQuality720,
      VideoQuality.p480 => l10n.videoQuality480,
      VideoQuality.p360 => l10n.videoQuality360,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.videoQualityPickerTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final quality in VideoQuality.values)
              ListTile(
                title: Text(
                  _labelFor(l10n, quality),
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                ),
                trailing: quality == selected
                    ? const Icon(Icons.check_rounded, color: Color(0xFF7C3AED))
                    : null,
                onTap: () {
                  onSelected(quality);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
