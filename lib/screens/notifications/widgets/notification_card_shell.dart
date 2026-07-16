import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The read/unread card chrome every notification type shares — avatar
/// slot, title/body/timestamp, the small unread dot, an
/// [AnimatedContainer] read/unread transition, and (optionally) swipe-
/// to-dismiss. Type-specific cards (room invite, friend request, ...)
/// only need to supply [avatar], [title]/[body]/[timeLabel], and an
/// optional [actions] row — this widget handles everything else so
/// every card in the list stays visually consistent.
class NotificationCardShell extends StatelessWidget {
  const NotificationCardShell({
    super.key,
    required this.isRead,
    required this.avatar,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.actions,
    this.onTap,
    this.dismissibleKey,
    this.confirmDismiss,
    this.onDismissed,
  });

  final bool isRead;
  final Widget avatar;
  final String title;
  final String? body;
  final String timeLabel;
  final Widget? actions;
  final VoidCallback? onTap;

  /// When non-null, the card is wrapped in a [Dismissible] using this
  /// key. Left null entirely for items that must never be swiped away
  /// (e.g. an admin join-request, which isn't a notification document
  /// at all — see `AdminJoinRequestCard`).
  final Key? dismissibleKey;
  final Future<bool> Function()? confirmDismiss;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final Widget card = _buildCard(context);
    if (dismissibleKey == null) return card;

    return Dismissible(
      key: dismissibleKey!,
      direction: DismissDirection.endToStart,
      background: _dismissBackground(),
      confirmDismiss: (_) => confirmDismiss?.call() ?? Future.value(false),
      onDismissed: (_) => onDismissed?.call(),
      child: card,
    );
  }

  Widget _dismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsetsDirectional.only(end: 22),
      alignment: AlignmentDirectional.centerEnd,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            color: isRead ? AppColors.notificationsSurface : AppColors.homeWelcomeCardEnd,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead ? const Color(0xFF242433) : AppColors.homePrimary.withOpacity(0.30),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.homeBadgePurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (body != null && body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.homeSecondaryText),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.homeMutedText),
                    ),
                    if (actions != null) ...[
                      const SizedBox(height: 10),
                      actions!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
