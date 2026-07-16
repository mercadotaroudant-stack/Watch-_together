import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../utils/notification_filter.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({super.key, required this.selected, required this.onChanged});

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Map<NotificationFilter, String> labels = {
      NotificationFilter.all: l10n.notificationsFilterAll,
      NotificationFilter.rooms: l10n.notificationsFilterRooms,
      NotificationFilter.friends: l10n.notificationsFilterFriends,
      NotificationFilter.app: l10n.notificationsFilterApp,
    };

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final filter in NotificationFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _FilterPill(
                label: labels[filter]!,
                isSelected: filter == selected,
                onTap: () => onChanged(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? null : AppColors.homeCard,
            gradient: isSelected
                ? const LinearGradient(colors: [AppColors.homePrimary, AppColors.homeSecondary])
                : null,
            border: isSelected ? null : Border.all(color: AppColors.homeBorder),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.white : AppColors.homeSecondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
