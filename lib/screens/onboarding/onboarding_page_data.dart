import 'package:flutter/material.dart';

/// One onboarding page's content.
///
/// [title]/[subtitle] are already-localized strings (resolved from
/// `AppLocalizations` by the caller) rather than ARB keys themselves, so
/// this class stays plain Dart with no `BuildContext` dependency.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.primaryIcon,
    this.secondaryIcons = const [],
  });

  final String title;
  final String subtitle;

  /// The large centered icon in the page's placeholder illustration —
  /// see `OnboardingIllustration`'s doc comment for why this is a vector
  /// composition rather than bundled artwork.
  final IconData primaryIcon;

  /// Small badge icons layered around the primary icon, evoking a
  /// composite illustration (e.g. chat + voice + video) without needing
  /// multiple bespoke image assets.
  final List<IconData> secondaryIcons;
}
