/// Real support-contact configuration for Help & Support's "Contact
/// Support" row.
///
/// **Intentionally blank.** No support email/URL has been provided for
/// WatchTogether yet, and per the spec this must not be invented. Fill
/// in exactly one of these once a real channel exists:
///
/// - [supportEmail]: opens the device's mail app via a `mailto:` link.
/// - [supportUrl]: opens a support page/chat (e.g. Intercom, a
///   contact form) via the in-app browser instead.
///
/// `HelpSupportScreen` checks [isConfigured] and shows an honest "not
/// set up yet" state rather than a dead or fake button when both are
/// empty.
abstract final class SupportConfig {
  /// TODO(support): real support inbox, e.g. 'support@watchtogether.app'.
  static const String supportEmail = '';

  /// TODO(support): real support page/chat URL, if using one instead of email.
  static const String supportUrl = '';

  static bool get isConfigured => supportEmail.isNotEmpty || supportUrl.isNotEmpty;
}
