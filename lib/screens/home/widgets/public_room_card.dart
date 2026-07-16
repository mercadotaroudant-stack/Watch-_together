import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/join_request_model.dart';
import '../../../models/participant_model.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/home_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/room_stream_providers.dart';
import '../../room_details/room_details_args.dart';

/// A single Public Rooms card: real room cover/title/status/participant
/// preview from Firestore, plus a real review-first join flow —
/// tapping "Join" calls [RoomRepository.requestToJoin] (never joins the
/// room outright) and the card reactively reflects the real
/// `join_requests` document: pending -> "Waiting for admin approval",
/// then either the user shows up in the room's real participants
/// (accepted -> auto-opens the room) or the request just disappears
/// with no membership (rejected -> back to "Join", with a toast).
class PublicRoomCard extends ConsumerWidget {
  const PublicRoomCard({super.key, required this.room});

  final RoomModel room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? currentUserId = ref.watch(currentUserIdProvider);
    final UserModel? currentUser = ref.watch(authStateProvider).valueOrNull;

    final AsyncValue<List<ParticipantModel>> participantsAsync =
        ref.watch(participantsStreamProvider(room.id));
    final AsyncValue<JoinRequestModel?> joinRequestAsync =
        ref.watch(myJoinRequestForRoomProvider(room.id));

    final List<ParticipantModel> participants = participantsAsync.valueOrNull ?? const [];
    final bool isMember = currentUserId != null && participants.any((p) => p.userId == currentUserId);
    final bool hasPendingRequest = joinRequestAsync.valueOrNull != null;

    // React to a request resolving: became a member -> accepted; the
    // request just vanished while still not a member -> rejected.
    ref.listen(myJoinRequestForRoomProvider(room.id), (previous, next) {
      final bool wasPending = previous?.valueOrNull != null;
      final bool isPendingNow = next.valueOrNull != null;
      if (wasPending && !isPendingNow && !isMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeJoinRequestRejected)),
        );
      }
    });

    Future<void> openRoom() async {
      if (currentUser == null) return;
      final userModel = await ref.read(userRepositoryProvider).getUser(room.hostId);
      if (!context.mounted) return;
      context.push(
        RouteNames.roomDetailsPath(room.id),
        extra: RoomDetailsArgs(room: room, host: userModel ?? currentUser, participants: participants),
      );
    }

    Future<void> requestJoin() async {
      if (currentUser == null) return;
      try {
        await ref.read(roomRepositoryProvider).requestToJoin(
              roomId: room.id,
              userId: currentUser.uid,
              displayName: currentUser.displayName ?? currentUser.email,
              photoUrl: currentUser.photoUrl,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.homeWaitingForApproval)),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.somethingWentWrong)),
          );
        }
      }
    }

    return Container(
      width: 230,
      height: 290,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.homeCard,
        border: Border.all(color: AppColors.homeBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CoverImage(url: room.coverImageUrl),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _StatusBadge(status: room.status),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Row(
                    children: [
                      _ParticipantAvatars(participants: participants),
                      const SizedBox(width: 8),
                      Text(
                        '${room.participantIds.length} / ${room.maxParticipants}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: isMember
                      ? _JoinButton(label: l10n.homeOpenRoomButton, onTap: openRoom)
                      : hasPendingRequest
                          ? _WaitingButton(label: l10n.homeWaitingForApproval)
                          : _JoinButton(label: l10n.homeJoinRoomButton, onTap: requestJoin),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = url != null && url!.isNotEmpty;
    if (!hasImage) return _fallback();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homePrimary, AppColors.homeSecondary],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_rounded, color: AppColors.white, size: 44),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RoomStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isLive = status == RoomStatus.playing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isLive ? AppColors.error : AppColors.homeMutedText).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isLive ? l10n.homeStatusLive : l10n.homeStatusWaiting,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  const _ParticipantAvatars({required this.participants});

  final List<ParticipantModel> participants;

  @override
  Widget build(BuildContext context) {
    final List<ParticipantModel> shown = participants.take(3).toList();
    if (shown.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 24,
      width: (16 + shown.length * 16).toDouble(),
      child: Stack(
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(
              left: (i * 16).toDouble(),
              child: _MiniAvatar(photoUrl: shown[i].photoUrl),
            ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 1.5),
        color: AppColors.homePrimary.withOpacity(0.4),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 14, color: AppColors.white),
              )
            : const Icon(Icons.person, size: 14, color: AppColors.white),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [AppColors.homePrimary, AppColors.homeSecondary]),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class _WaitingButton extends StatelessWidget {
  const _WaitingButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.homeBorder,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.homeSecondaryText),
      ),
    );
  }
}
