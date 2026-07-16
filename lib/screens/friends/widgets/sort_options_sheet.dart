import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../friends_filter.dart';

class SortOptionsSheet extends StatelessWidget {
  const SortOptionsSheet({super.key, required this.selected});

  final FriendsSortMode selected;

  static Future<FriendsSortMode?> show(BuildContext context, {required FriendsSortMode selected}) {
    return showModalBottomSheet<FriendsSortMode>(
      context: context,
      backgroundColor: AppColors.friendsCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SortOptionsSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.friendsBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.friendsSortSheetTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            _OptionTile(
              label: l10n.onlineLabel,
              selected: selected == FriendsSortMode.online,
              onTap: () => Navigator.of(context).pop(FriendsSortMode.online),
            ),
            _OptionTile(
              label: l10n.friendsSortRecentlyAdded,
              selected: selected == FriendsSortMode.recentlyAdded,
              onTap: () => Navigator.of(context).pop(FriendsSortMode.recentlyAdded),
            ),
            _OptionTile(
              label: l10n.friendsSortAlphabetical,
              selected: selected == FriendsSortMode.alphabetical,
              onTap: () => Navigator.of(context).pop(FriendsSortMode.alphabetical),
            ),
            _OptionTile(
              label: l10n.friendsSortByStatus,
              selected: selected == FriendsSortMode.status,
              onTap: () => Navigator.of(context).pop(FriendsSortMode.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.friendsPrimary)
          : null,
    );
  }
}
