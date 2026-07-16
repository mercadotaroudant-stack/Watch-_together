import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class CreateRoomAppBar extends StatelessWidget {
  const CreateRoomAppBar({
    super.key,
    required this.onBackPressed,
    required this.onInviteFriendsPressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onInviteFriendsPressed;

  static const double _buttonSize = 44;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _buttonSize,
            height: _buttonSize,
            child: Semantics(
              button: true,
              label: l10n.back,
              child: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.createRoomTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.createRoomSubtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _buttonSize,
            height: _buttonSize,
            child: Semantics(
              button: true,
              label: l10n.createRoomInviteFriendsSemanticLabel,
              child: IconButton(
                onPressed: onInviteFriendsPressed,
                icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.createRoomPrimaryHover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
