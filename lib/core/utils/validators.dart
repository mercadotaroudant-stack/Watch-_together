import '../localization/generated/app_localizations.dart';

/// Form-field validators shared by the email sign-in, create-account,
/// and forgot-password screens — kept in one place so the email regex
/// and password length rule can't drift between forms.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? Function(String?) email(AppLocalizations l10n) {
    return (value) {
      final String trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return l10n.emailRequiredError;
      if (!_emailPattern.hasMatch(trimmed)) return l10n.emailInvalidError;
      return null;
    };
  }

  static String? Function(String?) password(AppLocalizations l10n) {
    return (value) {
      final String v = value ?? '';
      if (v.isEmpty) return l10n.passwordRequiredError;
      if (v.length < 6) return l10n.passwordTooShortError;
      return null;
    };
  }

  static String? Function(String?) confirmPassword(
    AppLocalizations l10n,
    String Function() originalPassword,
  ) {
    return (value) {
      if (value != originalPassword()) return l10n.confirmPasswordMismatchError;
      return null;
    };
  }

  static String? Function(String?) displayName(AppLocalizations l10n) {
    return (value) {
      if ((value ?? '').trim().isEmpty) return l10n.displayNameRequiredError;
      return null;
    };
  }

  /// Age is optional (per spec) — only validated when non-empty.
  static String? Function(String?) age(AppLocalizations l10n) {
    return (value) {
      final String trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return null;
      final int? parsed = int.tryParse(trimmed);
      if (parsed == null || parsed <= 0 || parsed > 120) return l10n.ageInvalidError;
      return null;
    };
  }
}
