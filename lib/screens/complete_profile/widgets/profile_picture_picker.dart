import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// The 120dp circular profile picture with a small camera button
/// overlay.
///
/// Tapping the camera button shows an informational SnackBar rather
/// than opening an image picker — no `image_picker` dependency or
/// platform permissions are wired in this UI-only phase. Swapping in
/// real photo selection later only touches [onCameraPressed]'s
/// implementation, not this widget's layout.
class ProfilePicturePicker extends StatelessWidget {
  const ProfilePicturePicker({super.key, required this.onCameraPressed});

  final VoidCallback onCameraPressed;

  static const double _size = 120;
  static const double _cameraButtonSize = 36;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, size: 56, color: AppColors.white),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: l10n.photoUploadComingSoonMessage,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCameraPressed,
                  child: Container(
                    width: _cameraButtonSize,
                    height: _cameraButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.authCard, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
