import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import '../../../models/watch_history_model.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/watch_history_provider.dart';
import '../../room_details/room_details_args.dart';
import 'continue_watching_poster_card.dart';

/// The Home screen's "Continue Watching" section — only rendered when
/// the signed-in user has a real, unfinished [WatchHistoryModel] entry
/// (per [mostRecentUnfinished]); otherwise this widget renders nothing
/// at all, exactly as spec requires ("if empty, hide the section").
class ContinueWatchingSection extends ConsumerWidget {
  const ContinueWatchingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<WatchHistoryModel> history = ref.watch(liveWatchHistoryProvider).valueOrNull ?? const [];
    final WatchHistoryModel? entry = mostRecentUnfinished(history);

    if (entry == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.homeContinueWatchingTitle,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ContinueWatchingPosterCard(
                entry: entry,
                onTap: () => _resume(context, ref, entry),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _resume(BuildContext context, WidgetRef ref, WatchHistoryModel entry) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser == null) return;

    final RoomModel? room = await ref.read(roomRepositoryProvider).getRoom(entry.roomId);
    if (!context.mounted) return;

    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.homeRoomNoLongerAvailable)));
      return;
    }

    final hostUser = await ref.read(userRepositoryProvider).getUser(room.hostId);
    if (!context.mounted) return;

    context.push(
      RouteNames.roomDetailsPath(room.id),
      extra: RoomDetailsArgs(room: room, host: hostUser ?? currentUser, participants: const []),
    );
  }
}
