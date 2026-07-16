import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/admin_join_requests_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../friends/widgets/friend_avatar.dart';
import '../utils/notification_formatting.dart';
import 'notification_card_shell.dart';

/// "X wants to join Y" — the Admin/Host-facing card for a real, pending
/// [AdminJoinRequestItem] (see that provider's doc comment for how it's
/// composed). Accept/Reject call the exact same
/// `RoomRepository.acceptJoinRequest`/`rejectJoinRequest` the Video
/// Player's Participants panel already uses, so accepting here and
/// accepting there behave identically — including participants
/// streams updating in real time and the request document being
/// deleted once resolved (which is what makes it disappear from this
/// list on its own; no local dismiss/swipe is offered here).
class AdminJoinRequestCard extends ConsumerWidget {
  const AdminJoinRequestCard({super.key, required this.item});

  final AdminJoinRequestItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return NotificationCardShell(
      isRead: false,
      avatar: FriendAvatar(name: item.request.displayName, photoUrl: item.request.photoUrl, size: 52),
      title: l10n.notificationsJoinRequestTitle(item.request.displayName, item.room.title),
      body: null,
      timeLabel: relativeNotificationTimeLabel(l10n, item.request.requestedAt),
      actions: Row(
        children: [
          _AcceptButton(
            label: l10n.notificationsAcceptAction,
            onTap: () => ref.read(roomRepositoryProvider).acceptJoinRequest(item.request),
          ),
          const SizedBox(width: 10),
          _RejectButton(
            label: l10n.notificationsRejectAction,
            onTap: () => ref.read(roomRepositoryProvider).rejectJoinRequest(item.request),
          ),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.success),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  const _RejectButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.error.withOpacity(0.12),
            border: Border.all(color: AppColors.error.withOpacity(0.40)),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
