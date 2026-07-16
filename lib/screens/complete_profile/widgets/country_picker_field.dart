import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/countries.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// A tap-to-open field for picking a country, styled to match
/// [AppTextField] so it sits naturally in the same form. Opens a
/// bottom sheet with a search box over the full, alphabetically-sorted
/// [kCountries] list.
class CountryPickerField extends StatelessWidget {
  const CountryPickerField({super.key, required this.selected, required this.onChanged});

  final Country? selected;
  final ValueChanged<Country> onChanged;

  static const double _radius = 14;

  Future<void> _openPicker(BuildContext context) async {
    final Country? picked = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.authCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _CountrySearchSheet(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: selected == null ? l10n.countryFieldLabel : '${selected!.flagEmoji} ${selected!.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: () => _openPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (selected != null) ...[
                Text(selected!.flagEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  selected?.name ?? l10n.countryFieldLabel,
                  style: GoogleFonts.poppins(
                    fontSize: selected == null ? 14 : 16,
                    color: selected == null ? AppColors.secondaryText : AppColors.white,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  const _CountrySearchSheet();

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> _filtered = kCountries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final String normalized = query.trim().toLowerCase();
    setState(() {
      _filtered = normalized.isEmpty
          ? kCountries
          : kCountries.where((c) => c.name.toLowerCase().contains(normalized)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.selectCountrySheetTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: l10n.searchCountryHint,
                  hintStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final Country country = _filtered[index];
                    return Semantics(
                      button: true,
                      label: country.name,
                      child: ListTile(
                        onTap: () => Navigator.of(context).pop(country),
                        leading: Text(country.flagEmoji, style: const TextStyle(fontSize: 22)),
                        title: Text(
                          country.name,
                          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
