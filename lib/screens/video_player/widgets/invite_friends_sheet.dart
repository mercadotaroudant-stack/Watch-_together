import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/user_model.dart';
import '../../../providers/friends_provider.dart';
import '../../../providers/repository_providers.dart';

/// Opens the "invite existing friends into this room" sheet on top of
/// the Participants panel. Reuses [friendsWithProfilesProvider] (the
/// same accepted-friends join Create Room's picker uses) and fans out a
/// [NotificationType.roomInvite] to each person selected — the existing
/// `roomInviteNotificationTitle`/`Body` strings already exist for this
/// exact payload, just with no caller until now.
///
/// Returns the number of friends actually invited (0 if the sheet was
/// dismissed without sending), so the Participants panel can show its
/// own confirmation snackbar after this sheet closes.
Future<int?> showInviteFriendsSheet(
  BuildContext context, {
  required String roomId,
  required String roomTitle,
  required String inviterId,
  required String inviterName,
  required Set<String> existingParticipantIds,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.participantsSheetBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _InviteFriendsSheet(
      roomId: roomId,
      roomTitle: roomTitle,
      inviterId: inviterId,
      inviterName: inviterName,
      existingParticipantIds: existingParticipantIds,
    ),
  );
}

class _InviteFriendsSheet extends ConsumerStatefulWidget {
  const _InviteFriendsSheet({
    required this.roomId,
    required this.roomTitle,
    required this.inviterId,
    required this.inviterName,
    required this.existingParticipantIds,
  });

  final String roomId;
  final String roomTitle;
  final String inviterId;
  final String inviterName;
  final Set<String> existingParticipantIds;

  @override
  ConsumerState<_InviteFriendsSheet> createState() => _InviteFriendsSheetState();
}

class _InviteFriendsSheetState extends ConsumerState<_InviteFriendsSheet> {
  final Set<String> _selected = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _sending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_selected.isEmpty || _sending) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);

    final repo = ref.read(notificationRepositoryProvider);
    // Already-loaded profiles (the same list this sheet's picker shows)
    // — reused here just to check each recipient's own "room
    // invitations" preference (My Profile > Notifications) rather than
    // re-fetching. Fail-open (still notify) for anyone not found in it.
    final List<UserModel> profiles = ref.read(friendsWithProfilesProvider).valueOrNull ?? const [];
    int sent = 0;
    for (final friendId in _selected) {
      UserModel? friend;
      for (final profile in profiles) {
        if (profile.uid == friendId) {
          friend = profile;
          break;
        }
      }
      if (friend != null && !friend.notifyRoomInvitations) continue;
      try {
        await repo.createNotification(
          userId: friendId,
          type: NotificationType.roomInvite,
          title: l10n.roomInviteNotificationTitle(widget.inviterName),
          body: l10n.roomInviteNotificationBody(widget.roomTitle),
          data: {
            'roomId': widget.roomId,
            'inviterId': widget.inviterId,
            'inviterName': widget.inviterName,
            'roomTitle': widget.roomTitle,
          },
        );
        sent++;
      } catch (_) {
        // Best-effort — one failed invite shouldn't block the rest.
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(sent);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<UserModel>> friendsAsync = ref.watch(friendsWithProfilesProvider);

    return FractionallySizedBox(
      heightFactor: 0.72,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.participantsSheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.selectFriendsToInviteTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(0),
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
              Expanded(
                child: friendsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.videoPlayerPrimary),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      l10n.noFriendsFoundMessage,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                    ),
                  ),
                  data: (friends) {
                    final List<UserModel> selectable = friends
                        .where((f) => !widget.existingParticipantIds.contains(f.uid))
                        .toList();
                    final List<UserModel> filtered = _query.isEmpty
                        ? selectable
                        : selectable
                            .where((f) => (f.displayName ?? '').toLowerCase().contains(_query))
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noFriendsFoundMessage,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final UserModel friend = filtered[index];
                        final bool selected = _selected.contains(friend.uid);
                        final String name = friend.displayName?.trim().isNotEmpty == true
                            ? friend.displayName!
                            : '—';
                        final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                        return CheckboxListTile(
                          value: selected,
                          activeColor: AppColors.videoPlayerPrimary,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (_) => setState(() {
                            if (selected) {
                              _selected.remove(friend.uid);
                            } else {
                              _selected.add(friend.uid);
                            }
                          }),
                          secondary: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.videoPlayerPrimary,
                                  AppColors.videoPlayerPrimaryHover
                                ],
                              ),
                            ),
                            child: Text(
                              initial,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
                            ),
                          ),
                          title: Text(
                            name,
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty || _sending ? null : _handleSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.videoPlayerPrimary,
                      disabledBackgroundColor: AppColors.videoPlayerPrimary.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(
                            _selected.isEmpty
                                ? l10n.sendInvitesButton
                                : '${l10n.sendInvitesButton} (${_selected.length})',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
