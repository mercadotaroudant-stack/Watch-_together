import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/storage_service_provider.dart';
import '../../widgets/dialogs/safety_notice_dialog.dart';
import '../navigation/route_names.dart';

/// The single chokepoint every "sign-in succeeded" / "profile complete"
/// path routes through on its way to Home, so the Safety Notice
/// (Phase 3.4.1) is guaranteed to show exactly once, regardless of
/// which path got the user there (Google, Facebook, or email).
///
/// Spec frames this as showing "after Google or Facebook login", but
/// the real invariant that matters is "before Home, the very first
/// time" — gating navigation itself, rather than duplicating this
/// check in every screen that can lead to Home, is what actually
/// guarantees that regardless of future auth paths added.
Future<void> navigateToHomeWithSafetyGate(BuildContext context, WidgetRef ref) async {
  final storage = ref.read(localStorageServiceProvider);

  if (!storage.hasAcceptedCommunityNotice) {
    final bool? accepted = await SafetyNoticeDialog.show(context);
    if (accepted != true) return; // dialog is non-dismissible; defensive only
    await storage.setHasAcceptedCommunityNotice(true);
  }

  if (context.mounted) context.go(RouteNames.home);
}
