import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../friends_actions.dart';
import '../utils/friend_relationship_status.dart';
import 'friend_avatar.dart';

/// A single real-user search result. The Add Friend button's label and
/// enabled state are entirely driven by [status] (computed by the
/// caller from real, live relationship data) — this widget never keeps
/// its own "did I already tap this" flag as a substitute for that,
/// except for the brief in-flight `_sending` spinner while the actual
/// request is being written.
class AddFriendResultCard extends ConsumerStatefulWidget {
  const AddFriendResultCard({super.key, required this.user, required this.status});

  final UserModel user;
  final FriendRelationshipStatus status;

  @override
  ConsumerState<AddFriendResultCard> createState() => _AddFriendResultCardState();
}

class _AddFriendResultCardState extends ConsumerState<AddFriendResultCard> {
  bool _sending = false;

  Future<void> _handleAdd() async {
    if (_sending) return;
    setState(() => _sending = true);
    await FriendsActions(ref).sendRequest(context, toUserId: widget.user.uid);
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _handleAccept() async {
    if (_sending) return;
    setState(() => _sending = true);
    await FriendsActions(ref).acceptRequest(
      context,
      requesterId: widget.user.uid,
      requesterName: widget.user.displayName ?? '',
    );
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = widget.user.displayName ?? '—';

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.notificationsSurface,
        border: Border.all(color: AppColors.homeBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          FriendAvatar(name: name, photoUrl: widget.user.photoUrl, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                if (widget.user.isPremium) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.homeBadgePurple.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.drawerPremiumBadge,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.homeBadgePurple,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(l10n),
        ],
      ),
    );
  }

  Widget _buildActionButton(AppLocalizations l10n) {
    if (_sending) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(9),
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.homePrimary),
        ),
      );
    }

    switch (widget.status) {
      case FriendRelationshipStatus.friends:
        return _StaticPill(label: l10n.addFriendAlreadyFriendsLabel);
      case FriendRelationshipStatus.requestSent:
        return _StaticPill(label: l10n.addFriendRequestSentLabel);
      case FriendRelationshipStatus.requestReceived:
        return _GradientButton(label: l10n.notificationsAcceptAction, onTap: _handleAccept);
      case FriendRelationshipStatus.none:
        return _GradientButton(label: l10n.addFriendAddButton, onTap: _handleAdd);
    }
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

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
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [AppColors.homePrimary, AppColors.homeSecondary]),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class _StaticPill extends StatelessWidget {
  const _StaticPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.homeBorder,
      ),
      child: Text(
        label,
        maxLines: 1,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.homeSecondaryText),
      ),
    );
  }
}
