import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/watch_history_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/watch_history_provider.dart';
import 'utils/history_formatting.dart';
import 'widgets/continue_watching_card.dart';
import 'widgets/history_confirm_dialog.dart';
import 'widgets/history_empty_state.dart';
import 'widgets/history_header.dart';
import 'widgets/history_item_card.dart';
import 'widgets/history_options_sheet.dart';
import 'widgets/history_search_bar.dart';

class WatchHistoryScreen extends ConsumerStatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  ConsumerState<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends ConsumerState<WatchHistoryScreen> {
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openHistoryEntry(WatchHistoryModel entry) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final room = await ref.read(roomRepositoryProvider).getRoom(entry.roomId);
    if (!mounted) return;
    if (room == null) {
      _showSnack(l10n.historyRoomUnavailableMessage);
      return;
    }
    context.push(RouteNames.videoPlayerPath(entry.roomId));
  }

  Future<void> _viewRoomDetails(WatchHistoryModel entry) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final room = await ref.read(roomRepositoryProvider).getRoom(entry.roomId);
    if (!mounted) return;
    if (room == null) {
      _showSnack(l10n.historyRoomUnavailableMessage);
      return;
    }
    context.push(RouteNames.roomDetailsPath(entry.roomId));
  }

  Future<void> _removeEntry(WatchHistoryModel entry) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final bool confirmed = await showHistoryConfirmDialog(
      context,
      title: l10n.historyRemoveDialogTitle,
      message: l10n.historyRemoveDialogMessage,
      confirmLabel: l10n.historyRemoveButton,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(watchHistoryRepositoryProvider).removeEntry(userId: uid, historyId: entry.id);
      _showSnack(l10n.historyItemRemovedMessage);
    } catch (_) {
      _showSnack(l10n.somethingWentWrong);
    }
  }

  Future<void> _handleMenu(WatchHistoryModel entry) async {
    final action = await HistoryOptionsSheet.show(context, isUnfinished: !entry.isCompleted);
    if (action == null || !mounted) return;
    switch (action) {
      case HistoryItemAction.continueWatching:
        await _openHistoryEntry(entry);
        break;
      case HistoryItemAction.viewRoomDetails:
        await _viewRoomDetails(entry);
        break;
      case HistoryItemAction.remove:
        await _removeEntry(entry);
        break;
    }
  }

  Future<void> _clearHistory() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String? uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final bool confirmed = await showHistoryConfirmDialog(
      context,
      title: l10n.historyClearDialogTitle,
      message: l10n.historyClearDialogMessage,
      confirmLabel: l10n.historyClearButton,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(watchHistoryRepositoryProvider).clearHistory(uid);
      _showSnack(l10n.historyClearedMessage);
    } catch (_) {
      _showSnack(l10n.somethingWentWrong);
    }
  }

  void _openSearch() => setState(() => _searchActive = true);

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(liveWatchHistoryProvider);
    final List<WatchHistoryModel> history = historyAsync.valueOrNull ?? const [];

    final WatchHistoryModel? continueWatchingEntry = mostRecentUnfinished(history);

    final List<WatchHistoryModel> visible = _query.trim().isEmpty
        ? history
        : history.where((e) => e.videoTitle.toLowerCase().contains(_query.toLowerCase())).toList();

    final Map<HistorySection, List<WatchHistoryModel>> grouped = groupHistoryByDate(visible);

    return Scaffold(
      backgroundColor: AppColors.historyBackground,
      body: SafeArea(
        child: history.isEmpty
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: HistoryHeader(
                      onBackTap: () => Navigator.of(context).maybePop(),
                      onSearchTap: _openSearch,
                      onClearTap: _clearHistory,
                      showClear: false,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: HistoryEmptyState(
                        title: l10n.historyEmptyTitle,
                        subtitle: l10n.historyEmptySubtitle,
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _searchActive
                      ? HistorySearchBar(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          onClose: _closeSearch,
                        )
                      : HistoryHeader(
                          onBackTap: () => Navigator.of(context).maybePop(),
                          onSearchTap: _openSearch,
                          onClearTap: _clearHistory,
                          showClear: true,
                        ),
                  if (!_searchActive && continueWatchingEntry != null)
                    ContinueWatchingCard(onTap: () => _openHistoryEntry(continueWatchingEntry)),
                  if (_query.trim().isNotEmpty && visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          l10n.historyNoSearchResults,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.historySecondaryText),
                        ),
                      ),
                    )
                  else
                    for (final section in grouped.keys) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 26, bottom: 14),
                        child: Text(
                          historySectionLabel(l10n, section),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.historyPrimaryText,
                          ),
                        ),
                      ),
                      for (final entry in grouped[section]!)
                        HistoryItemCard(
                          entry: entry,
                          onOpen: () => _openHistoryEntry(entry),
                          onMenuTap: () => _handleMenu(entry),
                        ),
                    ],
                ],
              ),
      ),
    );
  }
}
