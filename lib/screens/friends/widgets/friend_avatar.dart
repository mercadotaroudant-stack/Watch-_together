import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/presence_status.dart';

class FriendAvatar extends StatelessWidget {
  const FriendAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.size = 64,
    this.presence,
  });

  final String name;
  final String? photoUrl;
  final double size;

  /// When non-null, draws the small colored status dot at the
  /// bottom-right of the avatar.
  final PresenceStatus? presence;

  Color _presenceColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return AppColors.friendsOnline;
      case PresenceStatus.away:
        return AppColors.friendsAway;
      case PresenceStatus.offline:
        return AppColors.friendsOffline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    final Widget circle = ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _initialFallback(initial),
            )
          : _initialFallback(initial),
    );

    if (presence == null) return SizedBox(width: size, height: size, child: circle);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: _presenceColor(presence!),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.friendsBackground, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialFallback(String initial) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.friendsPrimary, AppColors.friendsSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
