# widgets/

Reusable, feature-agnostic UI components built on the `core/theme`
design tokens. A screen-specific widget belongs next to its screen
under `screens/<feature>/widgets/` instead — everything here is meant
to be dropped into more than one screen.

- `common/` — `PrimaryButton` (solid or gradient, configurable height —
  used by onboarding, authentication, and Complete Profile alike),
  `SecondaryButton`, `AppTextField` (the one text-field style used
  across every auth form, with a built-in password-visibility toggle),
  `FadeSwitcher` (a small named wrapper around `AnimatedSwitcher` for
  keyed cross-fades)
- `language_selector/` — `LanguageSelector`, the self-contained
  top-right language pill + bottom sheet. Introduced in onboarding
  (Phase 3.2), reused as-is with zero modification wherever else a
  language switcher is needed.
