import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/join_request_model.dart';
import '../../../models/participant_model.dart';
import '../../../models/room_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/room_stream_providers.dart';
import 'invite_friends_sheet.dart';

enum _ParticipantMenuAction { makeModerator, removeFromRoom, viewProfile }

/// Opens the Participants bottom sheet: 70–80% of the screen height,
/// slide-up from the bottom, `#111118` background with a 28px top
/// radius — the redesign of what used to be a fixed 320dp right-edge
/// panel, now matching the reference mock.
///
/// Still built on the same realtime streams
/// (`participantsStreamProvider`/`pendingJoinRequestsStreamProvider`)
/// as before, so join requests, roles, and online state all update
/// live with no extra plumbing.
Future<void> showParticipantsPanel(
  BuildContext context, {
  required RoomModel room,
  required String currentUserId,
  required String currentUserName,
  required bool isHost,
  required ValueChanged<JoinRequestModel> onAcceptRequest,
  required ValueChanged<JoinRequestModel> onRejectRequest,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ParticipantsSheet(
      room: room,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      isHost: isHost,
      onAcceptRequest: onAcceptRequest,
      onRejectRequest: onRejectRequest,
    ),
  );
}

class _ParticipantsSheet extends ConsumerStatefulWidget {
  const _ParticipantsSheet({
    required this.room,
    required this.currentUserId,
    required this.currentUserName,
    required this.isHost,
    required this.onAcceptRequest,
    required this.onRejectRequest,
  });

  final RoomModel room;
  final String currentUserId;
  final String currentUserName;
  final bool isHost;
  final ValueChanged<JoinRequestModel> onAcceptRequest;
  final ValueChanged<JoinRequestModel> onRejectRequest;

  @override
  ConsumerState<_ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends ConsumerState<_ParticipantsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _inviteLink() {
    final String base = 'watchtogether://join/${widget.room.id}';
    if (widget.room.isPrivate && (widget.room.passcode?.isNotEmpty ?? false)) {
      return '$base?code=${widget.room.passcode}';
    }
    return base;
  }

  Future<void> _handleCopyInviteLink() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: _inviteLink()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.inviteLinkCopiedMessage)),
    );
  }

  Future<void> _handleOpenInviteFriends(List<ParticipantModel> participants) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int? sent = await showInviteFriendsSheet(
      context,
      roomId: widget.room.id,
      roomTitle: widget.room.title,
      inviterId: widget.currentUserId,
      inviterName: widget.currentUserName,
      existingParticipantIds: participants.map((p) => p.userId).toSet(),
    );
    if (!mounted || sent == null || sent <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.friendsInvitedMessage)),
    );
  }

  Future<void> _handleParticipantMenu(ParticipantModel participant) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isSelf = participant.userId == widget.currentUserId;
    final bool canModerate = widget.isHost && !isSelf && participant.role != ParticipantRole.host;

    final _ParticipantMenuAction? action = await showModalBottomSheet<_ParticipantMenuAction>(
      context: context,
      backgroundColor: AppColors.participantsSheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.participantsSheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (canModerate && participant.role == ParticipantRole.member)
                _MenuTile(
                  icon: Icons.shield_outlined,
                  label: l10n.participantsMenuMakeModerator,
                  onTap: () =>
                      Navigator.of(context).pop(_ParticipantMenuAction.makeModerator),
                ),
              if (canModerate)
                _MenuTile(
                  icon: Icons.person_remove_alt_1_rounded,
                  label: l10n.participantsMenuRemoveFromRoom,
                  isDestructive: true,
                  onTap: () =>
                      Navigator.of(context).pop(_ParticipantMenuAction.removeFromRoom),
                ),
              _MenuTile(
                icon: Icons.person_outline_rounded,
                label: l10n.participantsMenuViewProfile,
                onTap: () => Navigator.of(context).pop(_ParticipantMenuAction.viewProfile),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == null || !mounted) return;
    switch (action) {
      case _ParticipantMenuAction.makeModerator:
        await _promoteToModerator(participant);
      case _ParticipantMenuAction.removeFromRoom:
        await _confirmAndRemove(participant);
      case _ParticipantMenuAction.viewProfile:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.featureComingSoonMessage)),
        );
    }
  }

  Future<void> _promoteToModerator(ParticipantModel participant) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(roomRepositoryProvider).promoteToModerator(participant.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.participantPromotedMessage(participant.displayName))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.featureComingSoonMessage)),
      );
    }
  }

  Future<void> _confirmAndRemove(ParticipantModel participant) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.videoPlayerCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.removeParticipantConfirmTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        content: Text(
          l10n.removeParticipantConfirmMessage(participant.displayName),
          style: GoogleFonts.poppins(color: AppColors.videoPlayerSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel,
                style: GoogleFonts.poppins(color: AppColors.videoPlayerSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.participantsMenuRemoveFromRoom,
              style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(roomRepositoryProvider)
          .removeParticipant(roomId: widget.room.id, userId: participant.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.participantRemovedMessage(participant.displayName))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.featureComingSoonMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<ParticipantModel>> participantsAsync =
        ref.watch(participantsStreamProvider(widget.room.id));
    final AsyncValue<List<JoinRequestModel>> requestsAsync = widget.isHost
        ? ref.watch(pendingJoinRequestsStreamProvider(widget.room.id))
        : const AsyncValue.data([]);
    final List<ParticipantModel> allParticipants = participantsAsync.valueOrNull ?? const [];
    final int count = allParticipants.length;

    final List<ParticipantModel> filtered = _query.isEmpty
        ? allParticipants
        : allParticipants
            .where((p) => p.displayName.toLowerCase().contains(_query))
            .toList();
    final List<ParticipantModel> sorted = [...filtered]
      ..sort((a, b) => a.role.index.compareTo(b.role.index));

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.participantsSheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.participantsSheetBorder),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.participantsSheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 12),
                child: Row(
                  children: [
                    Text(
                      '${l10n.participantsLabel} ($count)',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.videoPlayerSecondaryText),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: l10n.participantsSearchHint,
                    hintStyle:
                        GoogleFonts.poppins(fontSize: 14, color: AppColors.videoPlayerSecondaryText),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: AppColors.videoPlayerSecondaryText),
                    filled: true,
                    fillColor: AppColors.videoPlayerBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.participantsSheetBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.participantsSheetBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.videoPlayerPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    ...requestsAsync.maybeWhen(
                      data: (requests) => requests
                          .map((r) => _JoinRequestCard(
                                request: r,
                                onAccept: () => widget.onAcceptRequest(r),
                                onReject: () => widget.onRejectRequest(r),
                              ))
                          .toList(),
                      orElse: () => const <Widget>[],
                    ),
                    participantsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.videoPlayerPrimary),
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.participantsPanelEmptyMessage,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                        ),
                      ),
                      data: (_) {
                        if (allParticipants.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.participantsPanelEmptyMessage,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                            ),
                          );
                        }
                        if (sorted.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.noParticipantsFoundMessage,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final p in sorted)
                              _ParticipantTile(
                                participant: p,
                                onMenuTap: () => _handleParticipantMenu(p),
                              ),
                          ],
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: AppColors.participantsSheetBorder, height: 28),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.inviteFriends,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.videoPlayerSecondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: AppColors.videoPlayerBackground,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _handleOpenInviteFriends(allParticipants),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_add_alt_1_rounded,
                                        size: 18, color: AppColors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.inviteFriends,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.white),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        size: 20, color: AppColors.videoPlayerSecondaryText),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.shareInviteLinkHint,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.videoPlayerSecondaryText),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleCopyInviteLink,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.videoPlayerPrimary,
                                side: const BorderSide(color: AppColors.videoPlayerPrimary),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.link_rounded, size: 18),
                              label: Text(
                                l10n.copyInviteLinkLabel,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive ? AppColors.error : AppColors.white;
    return Semantics(
      button: true,
      label: label,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: color),
        ),
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({required this.request, required this.onAccept, required this.onReject});

  final JoinRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.videoPlayerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.videoPlayerPrimary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.joinRequestMessage(request.displayName),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAccept,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(l10n.acceptLabel, style: GoogleFonts.poppins(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(l10n.rejectLabel, style: GoogleFonts.poppins(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant, required this.onMenuTap});

  final ParticipantModel participant;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String initial =
        participant.displayName.isNotEmpty ? participant.displayName[0].toUpperCase() : '?';
    final bool isAdmin = participant.role == ParticipantRole.host;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.videoPlayerPrimary, AppColors.videoPlayerPrimaryHover],
              ),
            ),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.adminBadgeGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.adminBadgeGold.withOpacity(0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                size: 11, color: AppColors.adminBadgeGold),
                            const SizedBox(width: 3),
                            Text(
                              l10n.roleAdmin,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.adminBadgeGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: participant.isOnline
                            ? AppColors.success
                            : AppColors.videoPlayerSecondaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      participant.isOnline ? l10n.onlineLabel : '',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.videoPlayerSecondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.videoPlayerSecondaryText),
          ),
        ],
      ),
    );
  }
}
