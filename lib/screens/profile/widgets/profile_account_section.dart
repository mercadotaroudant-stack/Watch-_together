import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/premium_tier_label.dart';
import '../../../models/premium_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/premium_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/service_providers.dart';
import 'profile_shared_rows.dart';

class ProfileAccountSection extends ConsumerStatefulWidget {
  const ProfileAccountSection({super.key});

  @override
  ConsumerState<ProfileAccountSection> createState() => _ProfileAccountSectionState();
}

class _ProfileAccountSectionState extends ConsumerState<ProfileAccountSection> {
  bool _isUploadingPhoto = false;
  bool _isSavingName = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(authStateProvider).valueOrNull;
    final PremiumModel? premium = ref.watch(premiumStatusProvider).valueOrNull;
    final bool isPremium = premium?.isActive ?? false;
    final String planLabel =
        isPremium ? premiumTierLabel(l10n, premium!.tier) : l10n.profilePlanFree;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.profileAccountInformationSection),
        ProfileSectionCard(
          children: [
            const SizedBox(height: 12),
            Center(
              child: _AvatarPicker(
                photoUrl: user?.photoUrl,
                isUploading: _isUploadingPhoto,
                onTap: user == null ? null : () => _pickAndUploadPhoto(user.uid),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.menuBorder),
            _EditableNameRow(
              displayName: user?.displayName ?? '',
              isSaving: _isSavingName,
              onSave: user == null ? null : (name) => _saveDisplayName(user.uid, name),
            ),
            const Divider(height: 1, color: AppColors.menuBorder),
            ProfileNavRow(
              emoji: '✉️',
              label: l10n.profileEmailLabel,
              value: user?.email ?? '',
              onTap: () {}, // read-only — Gmail auth, no edit affordance
            ),
            const Divider(height: 1, color: AppColors.menuBorder),
            ProfileNavRow(
              emoji: '👑',
              label: l10n.profileCurrentPlanLabel,
              value: planLabel,
              onTap: () {}, // informational only; use the drawer's Premium entry to change plan
            ),
            const SizedBox(height: 4),
          ],
        ),
      ],
    );
  }

  Future<void> _pickAndUploadPhoto(String uid) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final String url = await ref
          .read(storageServiceProvider)
          .uploadProfileImage(uid: uid, file: File(picked.path));
      await ref.read(authRepositoryProvider).updatePhotoUrl(uid: uid, photoUrl: url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profilePhotoUpdateError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveDisplayName(String uid, String name) async {
    setState(() => _isSavingName = true);
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(uid: uid, displayName: name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileNameUpdateError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.photoUrl, required this.isUploading, required this.onTap});

  final String? photoUrl;
  final bool isUploading;
  final VoidCallback? onTap;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
                border: Border.all(color: AppColors.menuPrimaryPurple, width: 2),
              ),
              child: ClipOval(
                child: hasPhoto
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.menuPrimaryPurple,
                  border: Border.all(color: AppColors.menuCard, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 15, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.menuSurface,
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 44, color: AppColors.menuSecondaryText),
    );
  }
}

class _EditableNameRow extends StatefulWidget {
  const _EditableNameRow({required this.displayName, required this.isSaving, required this.onSave});

  final String displayName;
  final bool isSaving;
  final ValueChanged<String>? onSave;

  @override
  State<_EditableNameRow> createState() => _EditableNameRowState();
}

class _EditableNameRowState extends State<_EditableNameRow> {
  bool _isEditing = false;
  late final TextEditingController _controller = TextEditingController(text: widget.displayName);

  @override
  void didUpdateWidget(covariant _EditableNameRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.displayName != oldWidget.displayName) {
      _controller.text = widget.displayName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (!_isEditing) {
      return ProfileNavRow(
        emoji: '📝',
        label: l10n.profileDisplayNameLabel,
        value: widget.displayName.isEmpty ? l10n.drawerGuestName : widget.displayName,
        onTap: widget.onSave == null ? () {} : () => setState(() => _isEditing = true),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 26, child: Text('📝', style: TextStyle(fontSize: 17))),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 40,
              style: GoogleFonts.poppins(fontSize: 15, color: AppColors.white),
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.menuBorder)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.menuPrimaryPurple),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          widget.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.menuPrimaryPurple),
                )
              : IconButton(
                  icon: const Icon(Icons.check_rounded, color: AppColors.menuSuccess),
                  onPressed: () {
                    final String trimmed = _controller.text.trim();
                    setState(() => _isEditing = false);
                    if (trimmed.isNotEmpty && trimmed != widget.displayName) {
                      widget.onSave?.call(trimmed);
                    }
                  },
                ),
        ],
      ),
    );
  }
}
