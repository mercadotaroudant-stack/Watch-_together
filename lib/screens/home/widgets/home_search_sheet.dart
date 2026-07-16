import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/room_model.dart';
import '../../../providers/home_providers.dart';
import 'public_room_card.dart';

/// A search sheet over the same real, live public-rooms data the "Public
/// Rooms" section already streams — filters client-side by title as the
/// user types. No separate search backend/screen exists yet, so this
/// stays a lightweight overlay on top of [publicRoomsStreamProvider]
/// rather than a new route.
class HomeSearchSheet extends ConsumerStatefulWidget {
  const HomeSearchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.homeBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const HomeSearchSheet(),
    );
  }

  @override
  ConsumerState<HomeSearchSheet> createState() => _HomeSearchSheetState();
}

class _HomeSearchSheetState extends ConsumerState<HomeSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<RoomModel> rooms = ref.watch(publicRoomsStreamProvider).valueOrNull ?? const [];
    final List<RoomModel> filtered = _query.isEmpty
        ? rooms
        : rooms.where((r) => r.title.toLowerCase().contains(_query.toLowerCase())).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.homeBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  style: GoogleFonts.poppins(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: l10n.homeSearchHint,
                    hintStyle: GoogleFonts.poppins(color: AppColors.homeMutedText),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.homeMutedText),
                    filled: true,
                    fillColor: AppColors.homeCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.homeBorder),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l10n.homeNoPublicRooms,
                          style: GoogleFonts.poppins(color: AppColors.homeSecondaryText),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: PublicRoomCard(room: filtered[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
