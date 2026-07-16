import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import 'quick_action_card.dart';

/// The Home screen's "Quick Actions" section — Create Room, Join Room,
/// Friends, History. Every card routes to an already-existing screen
/// (or, for Join Room, the new [RouteNames.joinRoom]) — no duplicate
/// screens are created here.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.homeQuickActionsTitle,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              QuickActionCard(
                icon: Icons.add_circle_rounded,
                title: l10n.homeQuickActionCreateRoom,
                description: l10n.homeQuickActionCreateRoomDesc,
                gradientColors: const [AppColors.homePrimary, AppColors.homeSecondary],
                onTap: () => context.push(RouteNames.createRoom),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.meeting_room_rounded,
                title: l10n.homeQuickActionJoinRoom,
                description: l10n.homeQuickActionJoinRoomDesc,
                onTap: () => context.push(RouteNames.joinRoom),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.people_alt_rounded,
                title: l10n.homeQuickActionFriends,
                description: l10n.homeQuickActionFriendsDesc,
                onTap: () => context.push(RouteNames.friends),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.history_rounded,
                title: l10n.homeQuickActionHistory,
                description: l10n.homeQuickActionHistoryDesc,
                onTap: () => context.push(RouteNames.watchHistory),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
