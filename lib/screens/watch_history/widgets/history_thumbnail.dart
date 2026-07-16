import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_colors.dart';

class HistoryThumbnail extends StatelessWidget {
  const HistoryThumbnail({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.borderRadius,
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(),
            Container(color: Colors.black.withOpacity(0.20)),
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
      );
    }
    return Image.asset(
      AssetPaths.videoPlaceholder,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
    );
  }

  /// The app's own gradient-plus-icon fallback — used when there's no
  /// saved background image *and* the bundled placeholder asset isn't
  /// available. Never a network/Unsplash-style placeholder.
  Widget _defaultPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.historyGradientStart, AppColors.historyGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 40),
    );
  }
}
