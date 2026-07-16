import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/participant_model.dart';

/// "Watching Now" + a capped, overlapping row of participant avatars.
///
/// Deliberately no username list underneath (per spec, "to avoid
/// clutter") — this is a presence indicator, not a roster.
class ParticipantsRow extends StatelessWidget {
  const ParticipantsRow({super.key, required this.participants});

  final List<ParticipantModel> participants;

  static const int _maxVisible = 5;
  static const double _avatarSize = 48;
  static const double _overlap = 14;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<ParticipantModel> visible = participants.take(_maxVisible).toList();
    final int overflow = participants.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.watchingNowTitle,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _avatarSize,
          child: Stack(
            children: [
              for (int i = 0; i < visible.length; i++)
                Positioned(
                  left: i * (_avatarSize - _overlap),
                  child: _ParticipantAvatar(participant: visible[i]),
                ),
              if (overflow > 0)
                Positioned(
                  left: visible.length * (_avatarSize - _overlap),
                  child: _OverflowBadge(count: overflow),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.participant});

  final ParticipantModel participant;

  @override
  Widget build(BuildContext context) {
    final String initial =
        participant.displayName.isNotEmpty ? participant.displayName[0].toUpperCase() : '?';

    return Semantics(
      label: participant.displayName,
      child: Container(
        width: ParticipantsRow._avatarSize,
        height: ParticipantsRow._avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.roomBackground, width: 2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ),
    );
  }
}

class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ParticipantsRow._avatarSize,
      height: ParticipantsRow._avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.roomCard,
        border: Border.all(color: AppColors.roomBackground, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
      ),
    );
  }
}
