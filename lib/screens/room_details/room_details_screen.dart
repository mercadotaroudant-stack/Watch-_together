import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/fade_switcher.dart';
import 'room_details_args.dart';
import 'widgets/banner_ad_placeholder.dart';
import 'widgets/host_info_card.dart';
import 'widgets/participants_row.dart';
import 'widgets/room_controls_bar.dart';
import 'widgets/room_options_bottom_sheet.dart';
import 'widgets/room_preview_card.dart';

/// The Room Details screen: room preview, host, who's watching, and the
/// voice/chat/leave controls.
///
/// Pure UI + navigation, per this phase's scope — no WebRTC, no
/// Firestore writes. [args] is expected to come from whichever screen
/// navigates here with an already-loaded `RoomModel`/`UserModel`/
/// `ParticipantModel`s (a future room list, reusing Phase 2's
/// `RoomRepository`/`UserRepository`); if it's missing (e.g. a bad deep
/// link), this shows a calm empty state instead of fabricating room
/// content.
///
/// Deliberately has no bottom navigation bar — only the reserved
/// [BannerAdPlaceholder] strip, per spec.
class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key, required this.args});

  final RoomDetailsArgs? args;

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fade;
  bool _voiceEnabled = false;

  static const Duration _fadeDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: _fadeDuration);
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleMenuPressed() async {
    final RoomOption? option = await RoomOptionsBottomSheet.show(context);
    if (option == null || !mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    switch (option) {
      case RoomOption.copyCode:
        final String code = widget.args?.room.id ?? '';
        await Clipboard.setData(ClipboardData(text: code));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.roomCodeCopiedMessage)),
        );
      case RoomOption.share:
      case RoomOption.invite:
      case RoomOption.report:
        // Share/invite/report all require platform integrations
        // (share sheet, deep links, a moderation backend) out of scope
        // for this UI-only phase — surfaced consistently via the same
        // "coming soon" pattern used elsewhere (e.g. Complete Profile's
        // camera button) rather than silently doing nothing.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.featureComingSoonMessage)),
        );
    }
  }

  Future<void> _handleLeavePressed() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.roomCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.leaveRoomConfirmTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        content: Text(
          l10n.leaveRoomConfirmMessage,
          style: GoogleFonts.poppins(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.leaveRoom,
              style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.pop();
  }

  void _handleChatPressed() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.chatComingSoonMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RoomDetailsArgs? args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.roomBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _RoomDetailsAppBar(
              title: args?.room.title ?? '',
              onBackPressed: () => context.pop(),
              onMenuPressed: _handleMenuPressed,
            ),
            Expanded(
              child: args == null
                  ? const _RoomUnavailableState()
                  : FadeTransition(
                      opacity: _fade,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RoomPreviewCard(
                                  room: args.room,
                                  watchingCount: args.participants.length,
                                  onTap: () => context
                                      .push(RouteNames.videoPlayerPath(args.room.id)),
                                ),
                                const SizedBox(height: 20),
                                HostInfoCard(host: args.host),
                                const SizedBox(height: 28),
                                ParticipantsRow(participants: args.participants),
                                const SizedBox(height: 36),
                                RoomControlsBar(
                                  isVoiceEnabled: _voiceEnabled,
                                  onVoiceTogglePressed: () =>
                                      setState(() => _voiceEnabled = !_voiceEnabled),
                                  onChatPressed: _handleChatPressed,
                                  onLeavePressed: _handleLeavePressed,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const BannerAdPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _RoomDetailsAppBar extends StatelessWidget {
  const _RoomDetailsAppBar({
    required this.title,
    required this.onBackPressed,
    required this.onMenuPressed,
  });

  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  static const double _height = 64;
  static const double _buttonSize = 48;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          SizedBox(
            width: _buttonSize,
            height: _buttonSize,
            child: Semantics(
              button: true,
              label: l10n.back,
              child: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
              ),
            ),
          ),
          Expanded(
            child: FadeSwitcher(
              switchKey: title,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: _buttonSize,
            height: _buttonSize,
            child: Semantics(
              button: true,
              label: l10n.roomOptionsSemanticLabel,
              child: IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomUnavailableState extends StatelessWidget {
  const _RoomUnavailableState();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 56, color: AppColors.secondaryText),
            const SizedBox(height: 16),
            Text(
              l10n.roomUnavailableTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.roomUnavailableMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
