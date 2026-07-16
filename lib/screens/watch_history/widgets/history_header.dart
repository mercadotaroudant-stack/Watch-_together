import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({
    super.key,
    required this.onBackTap,
    required this.onSearchTap,
    required this.onClearTap,
    required this.showClear,
  });

  final VoidCallback onBackTap;
  final VoidCallback onSearchTap;
  final VoidCallback onClearTap;

  /// The Clear History button only makes sense when there's something
  /// to clear.
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onBackTap,
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.historyPrimaryText, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.historyScreenTitle,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.historyPrimaryText,
              ),
            ),
          ),
          _IconButton(
            icon: Icons.search_rounded,
            iconSize: 24,
            iconColor: AppColors.historyPrimaryText,
            semanticLabel: l10n.friendsSearchButtonLabel,
            onTap: onSearchTap,
          ),
          if (showClear) ...[
            const SizedBox(width: 10),
            _IconButton(
              icon: Icons.delete_outline_rounded,
              iconSize: 23,
              iconColor: AppColors.historySecondaryText,
              semanticLabel: l10n.historyClearButton,
              onTap: onClearTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.historyElevatedCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.historyBorder),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
