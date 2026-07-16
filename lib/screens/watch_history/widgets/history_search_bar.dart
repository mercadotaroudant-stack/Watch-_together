import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class HistorySearchBar extends StatelessWidget {
  const HistorySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.historyElevatedCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.historyBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 22, color: AppColors.historyMutedText),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: GoogleFonts.poppins(fontSize: 16, color: AppColors.historyPrimaryText),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: l10n.historySearchHint,
                hintStyle: GoogleFonts.poppins(fontSize: 16, color: AppColors.historyMutedText),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.cancel,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 20, color: AppColors.historyMutedText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
