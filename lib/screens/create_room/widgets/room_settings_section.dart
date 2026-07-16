import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Section 4 — the max-participants slider. Free accounts are capped at
/// 4; a Premium account's cap is [maxAllowed] — the real limit for the
/// user's actual tier (see `PremiumTierLimits`/`maxRoomParticipantsProvider`),
/// not a flat number.
class RoomSettingsSection extends StatelessWidget {
  const RoomSettingsSection({
    super.key,
    required this.maxParticipants,
    required this.isPremium,
    required this.maxAllowed,
    required this.onChanged,
  });

  final int maxParticipants;
  final bool isPremium;

  /// The real cap for this user's current plan (Free or their actual
  /// premium tier) — see `maxRoomParticipantsProvider`.
  final int maxAllowed;
  final ValueChanged<int> onChanged;

  static const int _freeCap = 4;
  static const int _floor = 2;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int cap = isPremium ? maxAllowed : _freeCap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt_outlined, size: 18, color: AppColors.secondaryText),
            const SizedBox(width: 8),
            Text(
              l10n.maxParticipantsLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.createRoomPrimary,
            inactiveTrackColor: AppColors.createRoomBorder,
            thumbColor: AppColors.createRoomPrimary,
            overlayColor: AppColors.createRoomPrimary.withOpacity(0.2),
            valueIndicatorColor: AppColors.createRoomPrimary,
            valueIndicatorTextStyle: GoogleFonts.poppins(color: AppColors.white, fontSize: 12),
          ),
          child: Slider(
            value: maxParticipants.toDouble().clamp(_floor.toDouble(), cap.toDouble()),
            min: _floor.toDouble(),
            max: cap.toDouble(),
            divisions: cap - _floor,
            label: '$maxParticipants',
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_floor',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
              ),
              Text(
                isPremium ? '$cap' : '$_freeCap 👑',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.freePlanParticipantsNote,
                    style: GoogleFonts.poppins(fontSize: 11, height: 1.4, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
