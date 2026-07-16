import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../providers/repository_providers.dart';
import 'profile_shared_rows.dart';

class ProfileAccountActionsSection extends ConsumerStatefulWidget {
  const ProfileAccountActionsSection({super.key});

  @override
  ConsumerState<ProfileAccountActionsSection> createState() =>
      _ProfileAccountActionsSectionState();
}

class _ProfileAccountActionsSectionState extends ConsumerState<ProfileAccountActionsSection> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(l10n.profileAccountActionsSection),
        ProfileSectionCard(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isDeleting ? null : _confirmAndDelete,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_forever_rounded, size: 20, color: AppColors.menuDanger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.profileDeleteAccount,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.menuDanger,
                          ),
                        ),
                      ),
                      if (_isDeleting)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.menuDanger),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.menuCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.profileDeleteAccountConfirmTitle,
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.profileDeleteAccountConfirmMessage,
          style: GoogleFonts.poppins(color: AppColors.menuSecondaryText, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins(color: AppColors.menuSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.profileDeleteAccount,
              style: GoogleFonts.poppins(color: AppColors.menuDanger, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final String? uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount(uid);
      if (mounted) context.go(RouteNames.authentication);
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileDeleteAccountError)),
        );
      }
    }
  }
}
