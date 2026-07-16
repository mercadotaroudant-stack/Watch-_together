import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/presence_status.dart';
import '../../providers/friends_screen_provider.dart';
import 'add_friend_screen.dart';
import 'friends_actions.dart';
import 'friends_filter.dart';
import 'friends_search_screen.dart';
import 'widgets/friend_list_tile.dart';
import 'widgets/friend_options_sheet.dart';
import 'widgets/friend_request_card.dart';
import 'widgets/friends_animated_entry.dart';
import 'widgets/friends_empty_state.dart';
import 'widgets/friends_filter_chips.dart';
import 'widgets/friends_header.dart';
import 'widgets/invite_friends_banner.dart';
import 'widgets/sort_options_sheet.dart';

/// The invite link shared through the native share sheet. Real deep-link
/// generation (e.g. a dynamic/short link carrying a referral id) belongs
/// to a proper Dynamic Links integration; this is a stable placeholder
/// so the share flow itself — the part this screen owns — is complete
/// and wired end to end.
const String _kInviteLink = 'https://watchtogether.app/invite';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  FriendsFilter _filter = FriendsFilter.all;
  FriendsSortMode _sort = FriendsSortMode.online;

  int _presenceRank(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return 0;
      case PresenceStatus.away:
        return 1;
      case PresenceStatus.offline:
        return 2;
    }
  }

  List<FriendProfile> _sortFriends(List<FriendProfile> friends) {
    final List<FriendProfile> sorted = List.of(friends);
    switch (_sort) {
      case FriendsSortMode.online:
      case FriendsSortMode.status:
        sorted.sort((a, b) {
          final int rankCompare =
              _presenceRank(presenceOf(a.user)).compareTo(_presenceRank(presenceOf(b.user)));
          if (rankCompare != 0) return rankCompare;
          return (a.user.displayName ?? '').toLowerCase().compareTo(
                (b.user.displayName ?? '').toLowerCase(),
              );
        });
        break;
      case FriendsSortMode.recentlyAdded:
        sorted.sort((a, b) => b.friendsSince.compareTo(a.friendsSince));
        break;
      case FriendsSortMode.alphabetical:
        sorted.sort((a, b) =>
            (a.user.displayName ?? '').toLowerCase().compareTo((b.user.displayName ?? '').toLowerCase()));
        break;
    }
    return sorted;
  }

  Future<void> _handleFriendMenu(BuildContext context, FriendProfile friend) async {
    final actions = FriendsActions(ref);
    final action = await FriendOptionsSheet.show(context);
    if (action == null || !context.mounted) return;
    await _dispatchAction(context, actions, action, friend);
  }

  Future<void> _handleLongPress(BuildContext context, FriendProfile friend) async {
    final actions = FriendsActions(ref);
    final action = await FriendQuickActionsSheet.show(context);
    if (action == null || !context.mounted) return;
    await _dispatchAction(context, actions, action, friend);
  }

  Future<void> _dispatchAction(
    BuildContext context,
    FriendsActions actions,
    FriendAction action,
    FriendProfile friend,
  ) async {
    final String name = friend.user.displayName ?? '';
    switch (action) {
      case FriendAction.viewProfile:
        actions.showComingSoon(context);
        break;
      case FriendAction.inviteToRoom:
        actions.showInviteToRoomUnavailable(context);
        break;
      case FriendAction.voiceCall:
      case FriendAction.videoCall:
        actions.showComingSoon(context);
        break;
      case FriendAction.removeFriend:
        await actions.removeFriend(context, friendId: friend.user.uid, friendName: name);
        break;
      case FriendAction.blockUser:
        await actions.blockUser(context, userId: friend.user.uid, userName: name);
        break;
      case FriendAction.reportUser:
        await actions.reportUser(context, userId: friend.user.uid, userName: name);
        break;
    }
  }

  Future<void> _openSort() async {
    final mode = await SortOptionsSheet.show(context, selected: _sort);
    if (mode != null) setState(() => _sort = mode);
  }

  void _shareInvite() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    SharePlus.instance.share(ShareParams(text: l10n.friendsInviteShareText(_kInviteLink)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final actions = FriendsActions(ref);

    final friendsAsync = ref.watch(liveFriendsProvider);
    final requestsAsync = ref.watch(liveFriendRequestsProvider);
    final sentAsync = ref.watch(liveSentRequestsProvider);
    final blockedAsync = ref.watch(liveBlockedUsersProvider);

    final List<FriendProfile> allFriends = friendsAsync.valueOrNull ?? const [];
    final List<FriendRequestDisplay> requests = requestsAsync.valueOrNull ?? const [];
    final List<FriendProfile> sentRequests = sentAsync.valueOrNull ?? const [];
    final List<FriendProfile> blocked = blockedAsync.valueOrNull ?? const [];

    final List<FriendProfile> onlineFriends =
        allFriends.where((f) => presenceOf(f.user) == PresenceStatus.online).toList();

    return Scaffold(
      backgroundColor: AppColors.friendsBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.friendsPrimary,
          backgroundColor: AppColors.friendsCard,
          onRefresh: () async {
            ref.invalidate(liveFriendsProvider);
            ref.invalidate(liveFriendRequestsProvider);
            ref.invalidate(liveSentRequestsProvider);
            ref.invalidate(liveBlockedUsersProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              FriendsHeader(
                onSearchTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FriendsSearchScreen()),
                ),
                onNotificationsTap: () => context.push(RouteNames.notifications),
                onAddFriendTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                ),
              ),
              const SizedBox(height: 24),
              FriendsFilterChips(
                selected: _filter,
                requestsCount: requests.length,
                sentCount: sentRequests.length,
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: 24),
              if (_filter == FriendsFilter.requests) ...[
                _buildRequestsSection(l10n, requests, actions, capped: false),
              ] else if (_filter == FriendsFilter.sent) ...[
                _buildSentRequestsSection(l10n, sentRequests, actions),
              ] else if (_filter == FriendsFilter.blocked) ...[
                _buildBlockedSection(l10n, blocked, actions),
              ] else ...[
                if (_filter == FriendsFilter.all && requests.isNotEmpty) ...[
                  _buildRequestsSection(l10n, requests, actions, capped: true),
                  const SizedBox(height: 24),
                ],
                _buildAllFriendsSection(
                  l10n,
                  _filter == FriendsFilter.online ? onlineFriends : allFriends,
                  actions,
                ),
                const SizedBox(height: 24),
                InviteFriendsBanner(onTap: _shareInvite),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsSection(
    AppLocalizations l10n,
    List<FriendRequestDisplay> requests,
    FriendsActions actions, {
    required bool capped,
  }) {
    if (requests.isEmpty) {
      return FriendsEmptyState(
        icon: Icons.mark_email_unread_outlined,
        title: l10n.friendsNoRequestsTitle,
        subtitle: l10n.friendsNoRequestsSubtitle,
      );
    }

    final List<FriendRequestDisplay> visible =
        capped && requests.length > 2 ? requests.sublist(0, 2) : requests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.friendsRequestsSectionTitle,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            if (capped && requests.length > 2)
              FriendsPressableScale(
                onTap: () => setState(() => _filter = FriendsFilter.requests),
                child: Text(
                  l10n.friendsSeeAll,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.friendsPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < visible.length; i++) ...[
          FriendsAnimatedEntry(
            index: i,
            child: FriendRequestCard(
              name: visible[i].requester.displayName ?? '—',
              photoUrl: visible[i].requester.photoUrl,
              mutualFriendsCount: visible[i].mutualFriendsCount,
              onAccept: () => actions.acceptRequest(
                context,
                requesterId: visible[i].requester.uid,
                requesterName: visible[i].requester.displayName ?? '',
              ),
              onReject: () => actions.declineRequest(context, requesterId: visible[i].requester.uid),
            ),
          ),
          if (i != visible.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSentRequestsSection(
    AppLocalizations l10n,
    List<FriendProfile> sent,
    FriendsActions actions,
  ) {
    if (sent.isEmpty) {
      return FriendsEmptyState(
        icon: Icons.send_rounded,
        title: l10n.friendsNoSentRequestsTitle,
        subtitle: l10n.friendsNoSentRequestsSubtitle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.friendsChipSent} (${sent.length})',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.friendsCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.friendsBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < sent.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: FriendsAnimatedEntry(
                    index: i,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sent[i].user.displayName ?? '—',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => actions.cancelRequest(
                            context,
                            recipientId: sent[i].user.uid,
                          ),
                          child: Text(
                            l10n.friendsCancelRequestButton,
                            style: GoogleFonts.poppins(
                              color: AppColors.friendsPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllFriendsSection(
    AppLocalizations l10n,
    List<FriendProfile> friends,
    FriendsActions actions,
  ) {
    if (friends.isEmpty) {
      return FriendsEmptyState(
        icon: Icons.person_search_rounded,
        title: l10n.friendsNoFriendsTitle,
        subtitle: l10n.friendsNoFriendsSubtitle,
        actionLabel: l10n.friendsFindFriendsButton,
        onAction: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFriendScreen())),
      );
    }

    final List<FriendProfile> sorted = _sortFriends(friends);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.friendsAllFriendsSectionTitle} (${friends.length})',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            FriendsPressableScale(
              onTap: _openSort,
              child: Row(
                children: [
                  Text(
                    l10n.friendsSortLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.friendsPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.tune_rounded, size: 18, color: AppColors.friendsPrimary),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.friendsCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.friendsBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < sorted.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FriendsAnimatedEntry(
                    index: i,
                    child: FriendListTile(
                      name: sorted[i].user.displayName ?? '—',
                      photoUrl: sorted[i].user.photoUrl,
                      presence: presenceOf(sorted[i].user),
                      showDivider: i != sorted.length - 1,
                      onChatTap: () => actions.showComingSoon(context),
                      onMenuTap: () => _handleFriendMenu(context, sorted[i]),
                      onLongPress: () => _handleLongPress(context, sorted[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedSection(
    AppLocalizations l10n,
    List<FriendProfile> blocked,
    FriendsActions actions,
  ) {
    if (blocked.isEmpty) {
      return FriendsEmptyState(
        icon: Icons.block_rounded,
        title: l10n.friendsNoBlockedTitle,
        subtitle: l10n.friendsNoBlockedSubtitle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.friendsChipBlocked} (${blocked.length})',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.friendsCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.friendsBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < blocked.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: FriendsAnimatedEntry(
                    index: i,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            blocked[i].user.displayName ?? '—',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => actions.unblockUser(
                            context,
                            userId: blocked[i].user.uid,
                            userName: blocked[i].user.displayName ?? '',
                          ),
                          child: Text(
                            l10n.friendsMenuUnblockUser,
                            style: GoogleFonts.poppins(
                              color: AppColors.friendsPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
