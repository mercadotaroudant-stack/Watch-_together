import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../models/room_model.dart';
import '../../providers/room_stream_providers.dart';

/// The drawer's "🎬 My Rooms" destination: the real rooms the signed-in
/// user hosts, split into Active and Ended.
///
/// There is intentionally no "Scheduled" tab: [RoomModel] has no
/// scheduling field in this codebase yet (rooms are created and start
/// immediately), so a Scheduled tab would have nothing real to show.
/// Per the spec ("display scheduled room information if scheduling is
/// supported"), once room scheduling exists this is the place to add
/// that third tab.
class MyRoomsScreen extends ConsumerWidget {
  const MyRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<RoomModel>> roomsAsync = ref.watch(myRoomsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.menuBackground,
        appBar: AppBar(
          backgroundColor: AppColors.menuBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: Text(
            l10n.drawerMyRooms,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.menuPrimaryPurple,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.menuSecondaryText,
            labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: l10n.myRoomsActiveTab),
              Tab(text: l10n.myRoomsEndedTab),
            ],
          ),
        ),
        body: roomsAsync.when(
          data: (rooms) {
            final List<RoomModel> active =
                rooms.where((r) => r.status != RoomStatus.ended).toList();
            final List<RoomModel> ended =
                rooms.where((r) => r.status == RoomStatus.ended).toList();
            return TabBarView(
              children: [
                _RoomList(rooms: active, isActiveTab: true, l10n: l10n),
                _RoomList(rooms: ended, isActiveTab: false, l10n: l10n),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.menuPrimaryPurple),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              l10n.myRoomsLoadError,
              style: GoogleFonts.poppins(color: AppColors.menuSecondaryText),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList({required this.rooms, required this.isActiveTab, required this.l10n});

  final List<RoomModel> rooms;
  final bool isActiveTab;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isActiveTab ? l10n.myRoomsActiveEmpty : l10n.myRoomsEndedEmpty,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.menuSecondaryText),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RoomCard(room: rooms[index], isActiveTab: isActiveTab, l10n: l10n),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.isActiveTab, required this.l10n});

  final RoomModel room;
  final bool isActiveTab;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final bool hasCover = room.coverImageUrl != null && room.coverImageUrl!.isNotEmpty;

    return Material(
      color: AppColors.menuCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(RouteNames.roomDetailsPath(room.id)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.menuBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: hasCover
                      ? Image.network(
                          room.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _fallbackCover(),
                        )
                      : _fallbackCover(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(status: room.status),
                        const SizedBox(width: 8),
                        Icon(Icons.people_alt_rounded, size: 13, color: AppColors.menuSecondaryText),
                        const SizedBox(width: 3),
                        Text(
                          '${room.participantIds.length}/${room.maxParticipants}',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.menuSecondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().add_jm().format(room.createdAt),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.menuSecondaryText),
                    ),
                  ],
                ),
              ),
              if (isActiveTab)
                TextButton(
                  onPressed: () => context.push(RouteNames.roomDetailsPath(room.id)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.menuPrimaryPurple,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    l10n.myRoomsJoinButton,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.menuSecondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: AppColors.menuSurface,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_creation_rounded, color: AppColors.menuSecondaryText),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RoomStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final (String label, Color color) = switch (status) {
      RoomStatus.waiting => (l10n.myRoomsStatusWaiting, AppColors.menuPrimaryPurple),
      RoomStatus.playing => (l10n.myRoomsStatusPlaying, AppColors.menuSuccess),
      RoomStatus.paused => (l10n.myRoomsStatusPaused, AppColors.menuGold),
      RoomStatus.ended => (l10n.myRoomsStatusEnded, AppColors.menuSecondaryText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
