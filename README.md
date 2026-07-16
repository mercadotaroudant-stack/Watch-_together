# WatchTogether — Flutter (Phase 1 + Phase 2 + Phase 3.1 + Phase 3.2 + Phase 3.3 + Phase 3.4.1 + Phase 3.5 + Phase 3.6 + Phase 3.7 + Phase 3.8)

Package: `com.watchtogether.app`
Framework: Flutter (stable channel), Dart
Firebase project: `watch-together-468f2`

**Phase 1** (foundation): project architecture, theming, typography,
localization infrastructure, navigation skeleton, responsive-design
utilities.

**Phase 2** (backend foundation): Firebase (Core, Auth, Firestore, Cloud
Messaging, Analytics, Crashlytics, Remote Config; Storage prepared but
unused), typed models for every collection, services, repositories,
centralized error handling, toggleable logging, dependency injection,
and secure local storage.

**Phase 3.1** (splash screen): the app's entry-point UI — a staged
fade/scale intro that navigates onward after a fixed delay.

**Phase 3.2** (onboarding): three onboarding pages with a reusable
language selector (top-right pill + bottom sheet, instant in-place
language switching, RTL-ready).

**Phase 3.3** (authentication flow): Google/Facebook/Email choice,
email sign-in/sign-up/forgot-password, and a Complete Profile step for
new accounts — all UI + navigation + validation, no Firebase calls.

**Phase 3.4.1** (this update — safety notice): a non-dismissible
community-guidelines dialog shown exactly once, the first time any
account-creation/sign-in path is about to reach Home — see "Safety
notice" below for a language-support discrepancy worth your attention.

**Phase 3.5** (room details): a single room's detail view — preview,
host, who's watching, voice/chat/leave controls — typed against Phase
2's `RoomModel`/`UserModel`/`ParticipantModel`, ready for whenever a
room list screen exists to navigate here with real data.

**Phase 3.6** (navigation drawer): the app-wide `AppDrawer`, giving
every post-auth screen a consistent way to reach Profile, Premium,
Friends, Watch History, Notifications, Settings, and the informational
pages (Help, Community Guidelines, Privacy Policy, Terms, About).

**Phase 3.7** (create room): the Create Room form — public/private room
type, movie title + optional cover + video URL (MP4 free, M3U8
Premium-gated), an accepted-friends invite picker, a max-participants
slider capped by plan, and the four room-behavior toggles — writing
straight into Phase 2's `RoomModel`/`RoomRepository` and opening Phase
3.5's Room Details screen as the new room's host. See "Create Room"
below.

**Phase 3.8** (this update — video player): the actual in-room
watch-party screen `RoomDetailsScreen`'s preview card now opens —
forced pre-roll, lock/transport controls, mic/speaker/chat/participants
rail, live participant list with join-request review, real chat, and
Leave-with-host-transfer + Continue Watching logging. First real caller
of Phase 2's `streamRoom`/`streamParticipants`. See "Video Player"
below.

---

## ⚠️ One-time setup: generating the native (Android) project + wiring Firebase

This project was authored in an environment without the Flutter SDK or
network access, so the `lib/` architecture, `pubspec.yaml`, and Firebase
config below were hand-built — but the native `android/` Gradle project
(which Flutter normally scaffolds for you, including the binary Gradle
wrapper jar) was **not** generated here, to avoid shipping a
hand-faked/broken wrapper.

`android/app/google-services.json` **is** already included — it's your
real file, copied in as-is, for the `watch-together-468f2` Firebase
project / `com.watchtogether.app` package.

### 1. Scaffold the native project

From the project root:

```bash
flutter create --platforms=android --org com.watchtogether .
```

This only *adds missing files* (the `android/` folder, minus the
`google-services.json` you already have) — it will not touch your
existing `lib/`, `pubspec.yaml`, `l10n.yaml`, or
`android/app/google-services.json`.

### 2. Add the Google Services Gradle plugin

Flutter's current template uses Kotlin DSL (`build.gradle.kts`); older
projects use Groovy (`build.gradle`). Edit whichever one `flutter
create` generated for you:

**`android/settings.gradle.kts`** (Kotlin DSL) — add the plugin to the
existing `plugins { }` block:

```kotlin
plugins {
    // ...existing entries...
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

**`android/app/build.gradle.kts`** — apply it and set the minimum SDK
Firebase Auth requires:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // add this line
}

android {
    defaultConfig {
        applicationId = "com.watchtogether.app"
        minSdk = 23 // Firebase Auth requires >= 23; flutter create may default lower
        // ...existing targetSdk/versionCode/versionName...
    }
}
```

*(Groovy equivalent, if that's what you have instead: add `classpath
'com.google.gms:google-services:4.4.2'` to the root `build.gradle`'s
`dependencies {}`, and `apply plugin: 'com.google.gms.google-services'`
at the bottom of `android/app/build.gradle`, plus the same `minSdk = 23`
change.)*

### 3. Install and run

```bash
flutter pub get
flutter run
```

`generate: true` in `pubspec.yaml` means `AppLocalizations` is
generated automatically on this first build, so no manual `flutter
gen-l10n` step is needed.

### 4. (Optional, once you've added the logo) generate the app icon + splash

See `assets/logo/README.md` — this project references
`assets/logo/app_logo.png`, which couldn't be downloaded into the
project here (no network access in this sandbox).

---

## Folder structure

```
lib/
├── main.dart                     # Entrypoint: Firebase/Crashlytics/RemoteConfig bootstrap -> runApp
├── app.dart                      # WatchTogetherApp root widget + temporary FoundationScreen
├── firebase_options.dart         # Hand-authored from google-services.json (Android only)
├── core/
│   ├── constants/                 # Spacing/radii/durations, asset paths, Firestore collection names
│   ├── theme/                     # Colors, typography, ThemeData (Material 3, dark)
│   ├── localization/               # ARB files + supported-locale metadata + generated output
│   ├── navigation/                 # go_router config + route name constants
│   ├── errors/                     # AppException hierarchy + Firebase error mapper
│   ├── utils/                      # Responsive helpers, BuildContext extensions, Firestore converters
│   └── helpers/                    # AppLogger (toggleable, Crashlytics-integrated)
├── models/                       # UserModel, RoomModel, ParticipantModel, MessageModel, FriendModel,
│                                    NotificationModel, PremiumModel, WatchHistoryModel, ReportModel,
│                                    AppSettingsModel, enums.dart
├── services/                     # AuthService, FirestoreService, RoomService, NotificationService,
│                                    FriendService, AnalyticsService, RemoteConfigService,
│                                    CrashlyticsService, LocalStorageService, SecureStorageService
├── repositories/                 # One per collection/feature — see "Repositories" below
├── providers/                    # Riverpod DI: service_providers, repository_providers,
│                                    auth_state_provider, locale_provider, storage_service_provider,
│                                    app_version_provider, friends_provider (Phase 3.7),
│                                    room_stream_providers (Phase 3.8)
├── widgets/
│   ├── common/                     # PrimaryButton, SecondaryButton, AppTextField, FadeSwitcher
│   ├── language_selector/          # LanguageSelector (reusable — see "Language selector" below)
│   ├── app_drawer/                 # AppDrawer (Phase 3.6)
│   └── dialogs/                    # SafetyNoticeDialog (Phase 3.4.1)
└── screens/
    ├── splash/                     # Phase 3.1
    ├── onboarding/                 # Phase 3.2
    ├── auth/                       # Phase 3.3 — see "Authentication flow" below
    │   ├── widgets/
    │   └── email/
    │       └── widgets/
    ├── complete_profile/           # Phase 3.3
    │   └── widgets/
    ├── room_details/               # Phase 3.5 — see "Room details" below
    │   └── widgets/
    ├── create_room/                # Phase 3.7 — see "Create Room" below
    │   └── widgets/
    └── video_player/                # Phase 3.8 — see "Video Player" below
        └── widgets/

assets/
├── logo/  icons/  illustrations/  animations/  images/   # mapped in pubspec.yaml
└── fonts/                                                # not used yet; see its README.md

android/
└── app/google-services.json      # your real Firebase config, already in place
```

Every otherwise-empty folder has a short `README.md` explaining what
belongs there, instead of throwaway placeholder files.

---

## Architecture decisions

**State management — Riverpod (`flutter_riverpod`).**
Chosen over `Provider`, `Bloc`, and `GetX` for a large-scale app because:
- Compile-time safety: providers are read via typed references, not
  `context.watch<T>()` string/type lookups, so refactors surface as
  compile errors, not runtime "provider not found" crashes.
- No `BuildContext` requirement to read state, which matters once
  business logic (repositories, services) needs state outside the
  widget tree.
- Built-in support for async state (`FutureProvider`/`StreamProvider`),
  which this app will need heavily once Firestore real-time listeners
  (watch-party sync) land in later phases.
- First-class testability — providers can be overridden per-test
  without a widget tree, as shown in `test/app_test.dart`.

**Navigation — `go_router`.**
Declarative, URL-based routing with built-in deep-link support — needed
for features like "open a shared room link" later — and official
support/maintenance from the Flutter team, over rolling a custom
`Navigator` 2.0 delegate or adding `auto_route`'s code-gen step this
early.

**Localization — Flutter's built-in ARB/`gen-l10n` pipeline**, not
`easy_localization` or a custom JSON loader. It's zero extra runtime
dependencies, type-safe (`AppLocalizations.of(context).appName` is a
generated method, not a string key lookup), and is the approach the
Flutter team recommends for new apps.

**Responsive design — hand-written breakpoint helpers**
(`core/utils/responsive.dart`), not `flutter_screenutil` or
`responsive_framework`. The breakpoint logic needed (small phone /
large phone / tablet) is a handful of `MediaQuery` comparisons; adding
a package for it would violate the "no unnecessary packages"
requirement.

**Dependency injection — Riverpod providers, not `get_it`.**
Riverpod (already the state-management choice) is also the DI
container: every service and repository is exposed via a `Provider` in
`providers/service_providers.dart` / `providers/repository_providers.dart`,
constructed lazily and cached, and swappable in tests via
`ProviderScope(overrides: [...])` — see `test/app_test.dart`'s existing
pattern. Adding `get_it` on top would mean two competing DI systems for
no benefit.

**Service vs. Repository split.**
`services/` wrap a single external SDK (Firebase Auth, Firestore, FCM,
...) and know nothing about this app's models — they take/return raw
SDK types or maps. `repositories/` compose one or more services,
translate to/from typed `models/`, and are what the app is meant to
depend on everywhere else. `RoomService`/`FriendService` are the two
exceptions that contain composite, multi-collection write logic
(create a room + its host participant atomically; move a friend request
between collections) — that logic lives at the service layer because
it's Firestore-transaction/batch mechanics, not domain translation, but
it's still only ever called through `RoomRepository`/`FriendRepository`.

**Error handling — a typed `AppException` hierarchy + a Firebase error
mapper.**
No repository or service lets a raw `FirebaseException`/
`FirebaseAuthException` escape — `core/errors/firebase_error_mapper.dart`
translates every Firebase error code into a user-safe message on one of
`AuthException` / `FirestoreException` / `StorageException` /
`MessagingException` (all `AppException` subtypes). A separate
`DomainException` covers business-rule rejections that were never a
Firebase error at all (e.g. "this room is full"). Phase 3 UI can catch
one exception type and show `exception.message` directly.

**Logging — a single `AppLogger`, not a logging package.**
`core/helpers/app_logger.dart` wraps `dart:developer`'s `log`, gated by
`AppLogger.isEnabled` (defaults to `kDebugMode`, flippable with one line
for production) and separately forwards warnings/errors to Crashlytics
regardless of that flag, since crash reports should keep flowing in
release builds even with console logging off.

**Local storage — split by sensitivity.**
`LocalStorageService` (`shared_preferences`) holds low-stakes UI
preferences: selected language, theme preference. `SecureStorageService`
(`flutter_secure_storage`, backed by Android Keystore) holds the
auth-session mirror and the cached premium-status flag — data worth
encrypting at rest even though Firebase Auth already persists the real
session internally.

---

## Theme

Single global **dark** theme (Material 3), defined in
`core/theme/app_theme.dart`, built from the palette in
`core/theme/app_colors.dart`:

| Token | Hex |
|---|---|
| Primary | `#7C3AED` |
| Secondary | `#A855F7` |
| Background | `#0B0B12` |
| Surface | `#161622` |
| Border | `#2A2A3C` |
| Success | `#22C55E` |
| Warning | `#F59E0B` |
| Error | `#EF4444` |
| White | `#FFFFFF` |

## Typography

Poppins via `google_fonts`, mapped onto the full Material 3 type scale
(display/headline/title/body/label × large/medium/small) in
`core/theme/app_typography.dart`. See `assets/fonts/README.md` for how
to switch to a bundled (offline-safe) font instead of runtime fetching.

## Localization

Infrastructure only — no screens are translated yet. 8 languages are
wired up with a minimal common-string ARB file each:
English, Arabic (RTL), French, Spanish, Turkish, Hindi, Japanese,
Portuguese. RTL is handled automatically by `MaterialApp` based on the
resolved locale — no manual `Directionality` wrapping needed anywhere
in the app.

## Navigation

`go_router` is wired via `appRouterProvider`
(`core/navigation/app_router.dart`) with a single root route pointing
at the temporary `FoundationScreen`. Add real routes to
`core/navigation/route_names.dart` + `app_router.dart` as each screen
is built in Phase 3.

## Responsive design

`context.deviceType` / `context.isTablet` / `context.responsiveValue(...)`
(`core/utils/responsive.dart`) cover small phones, large phones, and
tablets without a third-party dependency.

---

## Firebase & backend (Phase 2)

**Products configured:** Core, Auth, Firestore, Cloud Messaging,
Analytics, Crashlytics, Remote Config. **Storage** is a dependency and
has an error-mapping case ready (`StorageException` /
`FirebaseErrorMapper.mapStorageError`) but no service/repository calls
it yet, per spec.

**Collections & their models** (`lib/models/`, `lib/core/constants/firestore_collections.dart`):

| Collection | Model | Repository |
|---|---|---|
| `users` | `UserModel` | `AuthRepository` (identity) + `UserRepository` (profile) |
| `rooms` | `RoomModel` | `RoomRepository` |
| `participants` | `ParticipantModel` | `RoomRepository` |
| `messages` | `MessageModel` | `MessageRepository` |
| `friends` | `FriendModel` | `FriendRepository` |
| `friend_requests` | `FriendModel` | `FriendRepository` |
| `notifications` | `NotificationModel` | `NotificationRepository` |
| `watch_history` | `WatchHistoryModel` | `WatchHistoryRepository` |
| `premium` | `PremiumModel` | `PremiumRepository` |
| `reports` | `ReportModel` | `ReportRepository` |
| `app_settings` | `AppSettingsModel`* | `AppSettingsRepository` |

\* `AppSettingsModel` wasn't in the original model list but was added so
every collection gets the same typed treatment — see the model file's
doc comment.

No fake/seed data was inserted into any collection.

**Authentication** (`AuthService` + `AuthRepository`): email sign-up,
email sign-in, forgot-password, logout, and an `authStateChanges()`
stream (exposed app-wide as `authStateProvider`, a `StreamProvider<UserModel?>`
in `providers/auth_state_provider.dart`) that doubles as "current user"
and "auto-login" — Firebase Auth restores its own persisted session on
launch, and this stream simply reflects that. A local session mirror in
`SecureStorageService` lets a future splash screen render an optimistic
"signed in" state before that stream's first emission. No auth UI was
built (per spec) — only the services/repositories/providers a
sign-up/sign-in screen will call in Phase 3.

**Cloud Messaging**: `NotificationService` handles permission, token
retrieval/refresh, and foreground/background message streams;
`NotificationRepository.registerForPushNotifications(uid)` ties a
token to a user's `fcmTokens` array. A top-level background handler
(`firebaseMessagingBackgroundHandler`) is registered in `main.dart`.

**Everything else not covered above** — Analytics event logging,
Remote Config keys/defaults, Crashlytics hooks — is documented inline
in each service's doc comment (`lib/services/`).

---

## Splash screen (Phase 3.1)

`lib/screens/splash/splash_screen.dart` is now the app's initial route
(`RouteNames.splash`, `'/'`). It runs a staged fade/scale intro, then
navigates to `RouteNames.foundation` (still `FoundationScreen`) after
exactly `AppConstants.splashNavigationDelay` (2.5s) — a plain
`Timer`, deliberately independent of the ~1.8s intro animation, so the
navigation delay stays correct even if the animation timing is tuned
later.

**Animation sequence** (one `AnimationController`, sub-animations
carved out via `Interval`, all timing constants local to the screen in
`_SplashTiming`):

1. Background fade-in — 400ms, `Curves.easeOut`
2. Logo fade + scale (0.85 → 1.0) — 700ms, `Curves.easeOutCubic`
3. App name fade-in — 400ms, `Curves.easeOut`
4. Tagline fade-in — 400ms, `Curves.easeOut`
5. Loading indicator fade-in — 300ms, `Curves.easeOut`

**Logo handling**: `SplashLogo` (`screens/splash/widgets/`) renders
`AssetPaths.appLogo` at 140×140dp, 24dp corner radius, with a soft
purple glow (`BoxShadow`, primary color at 35% opacity, 40px blur). If
that file is missing — true right now, see "Not included" below — it
falls back to a same-size branded placeholder instead of crashing, so
the screen still looks intentional until the real logo is added.

**Version text**: `SplashVersionText` reads the real installed version
via `PackageInfo.fromPlatform()` (`providers/app_version_provider.dart`),
falling back to `AppConstants.fallbackAppVersion` while that resolves
or if it fails — never a hardcoded display string.

**Localization**: every string (`appName`, `splashTagline`,
`appVersionLabel` with a `{version}` placeholder, and the two semantic
labels) is a generated `AppLocalizations` key across all 8 languages —
nothing is hardcoded in the widget tree.

**Accessibility**: the logo and loading indicator are each wrapped in
`Semantics` with the localized labels the spec calls for
(`splashLogoSemanticLabel` / `splashLoadingSemanticLabel`).

**Responsive**: content is centered in a `SingleChildScrollView` (so
nothing overflows on small phones or in landscape) and width-capped via
the existing `context.maxContentWidth` (Phase 1's responsive util) on
tablets, rather than stretching edge-to-edge.

---

## Onboarding (Phase 3.2)

`lib/screens/onboarding/onboarding_screen.dart` is a 3-page
`PageView` (`RouteNames.onboarding`, reached from splash). Skip (page 1)
and Get Started (page 3) both navigate to `RouteNames.signIn` — still
`FoundationScreen`, per the same "temporary, replaced later" pattern
splash used for its own next-screen. Back/Next move between pages via
`PageController.animateToPage` (300ms, `easeInOut`).

**Per-page animation** (all keyed off `isActive = currentPage == index`,
so it replays on every swipe, not just first build):
- Illustration: fade + scale 0.9→1.0, 500ms, `easeOutCubic`
  (`OnboardingIllustration`)
- Title/subtitle: fade, 300ms (`OnboardingPageContent`)

**Bottom bar** (`OnboardingBottomBar`): the page indicator + button row
slide up + fade once, 300ms, when the screen first mounts — not
replayed per swipe, since only the button *labels* change between
pages (Skip↔Back, Next↔Get Started), and re-sliding the whole bar on
every swipe would fight the page's own animations rather than
complement them.

**Illustrations are placeholders.** No bespoke onboarding artwork was
provided and this sandbox has no network access to source any (same
constraint as the app logo — see `assets/logo/README.md`). Each page
gets a deliberately-designed vector composition instead (gradient
panel + brand-colored icon collage, `OnboardingIllustration`) rather
than blocking the phase on missing assets. `assets/illustrations/` is
reserved for real artwork later; swap it in the same
`Image.asset` + `errorBuilder`-fallback pattern `SplashLogo` already
uses.

**Local storage**: `LocalStorageService.keyOnboardingCompleted` reserves
the `onboarding_completed` key name, per spec — nothing reads or writes
it yet. Get Started does not mark onboarding complete; that decision
belongs to whichever screen ends up owning app-start routing, once one
exists.

---

## Authentication flow (Phase 3.3)

```
Onboarding → Authentication → Google / Facebook / Email
                                  │
                    (Google/Facebook: confirm dialog)
                                  │
                                  ▼
                         Complete Profile → Home

Email → Sign In → Home directly (simulates an existing account)
      → Create Account → Complete Profile → Home (always a new account)
      → Forgot Password → inline success message
```

**No standalone Sign In/Sign Up screen.** `AuthenticationScreen`
(`RouteNames.authentication`) is the one entry point, exactly per spec.
Email sign-in/sign-up live under `screens/auth/email/` and are reachable
*only* via the Email button and its own "Create Account" link — nothing
routes to them directly.

**Google/Facebook** show `SocialContinueDialog` (one widget, provider
name templated) then go straight to Complete Profile. There's no real
Google/Facebook logo asset bundled (no network access in this sandbox,
and the real Google "G" mark is Google's IP) — a plain "G" glyph stands
in for Google; Facebook uses Flutter's built-in `Icons.facebook`. Phase
4 replaces the whole dialog with real SDK sign-in and branches on
whether the account already exists, per the spec's flow diagram.

**Validation** (`core/utils/validators.dart`, shared across all three
email screens so the email regex and password-length rule can't drift):
email format, password ≥ 6 characters, confirm-password match, required
display name, optional-but-numeric age (1–120).

**Complete Profile** collects display name, age, country (searchable
bottom sheet over all ~195 countries — see `core/constants/countries.dart`;
flags are computed from ISO codes via Unicode regional-indicator
symbols, not bundled images), and preferred language (a *profile*
attribute, distinct from the app's UI language — see
`LanguagePickerField`'s doc comment for why that's not the same
component as `LanguageSelector`). The camera button is a placeholder
(SnackBar only) — no `image_picker` dependency in this UI-only phase.

**Navigation**: `push`/`pop` for the lateral email sub-flow (so the
system back button/gesture returns to the previous auth screen); `go`
for the forward-only transitions (Authentication → Complete Profile →
Home, and Email Sign-In → Home) that shouldn't be back-navigable.

---

## Language selector

`widgets/language_selector/LanguageSelector` is the reusable top-right
pill button (globe icon, current language, chevron) that opens
`LanguageOptionsSheet` — a Material 3 bottom sheet listing all 8
languages (flag, native name, checkmark on the selected one). It's
fully self-contained: it reads `localeProvider` and calls
`localeProvider.notifier.setLocale(...)` itself, so it can be dropped
into Sign In, Sign Up, or Settings later with zero additional wiring,
per spec.

Selecting a language updates `localeProvider`, which `WatchTogetherApp`
(`app.dart`, wired since Phase 1) already watches — so the whole app's
text updates immediately with no restart, reload, or navigation, and
the user stays on the same onboarding page. Title/subtitle text is
wrapped in `FadeSwitcher` (`widgets/common/`) keyed on the current
locale, giving the 150ms fade the spec calls for on that transition.
Arabic switches the whole app to RTL automatically (Flutter's own
locale-driven `Directionality`, already in place since Phase 1) — Row
children (buttons, page indicator dots) mirror automatically because
they were built in logical start→end order rather than hardcoded
left/right; the language selector itself stays visually top-*right*
regardless of RTL, matching the spec's fixed-corner placement.

---

## Safety notice (Phase 3.4.1)

`SafetyNoticeDialog` (`widgets/dialogs/`) is shown exactly once, gated
by `LocalStorageService.hasAcceptedCommunityNotice` — unlike the
`onboarding_completed` key (reserved but unwired), this flag is fully
read/written: `core/utils/home_navigation.dart`'s
`navigateToHomeWithSafetyGate` is the single chokepoint every
"authentication succeeded" path now routes through
(`CompleteProfileScreen` and `EmailAuthScreen`'s Continue both call it
instead of navigating to Home directly), so the dialog is guaranteed to
appear before Home is ever reached for the first time — regardless of
whether that happened via Google, Facebook, or email.

**Non-dismissible, exactly per spec**: `barrierDismissible: false`,
wrapped in `PopScope(canPop: false)` to block the system back
gesture/button. The only exit is the accept button, which persists the
flag and then calls the same navigation gate (now a no-op check) to
continue to Home.

**⚠️ Language list discrepancy worth flagging**: this phase's spec
lists English, Arabic, French, Spanish, Portuguese, **Deutsch**,
Turkish, and Hindi — swapping out Japanese (supported by every other
part of the app since Phase 1) for German. Rather than silently drop
Japanese or silently add German as an unrequested 9th language, this
dialog was translated into the app's **existing 8 languages**
(including Japanese, not German) so nothing already built breaks. If
you do want German added app-wide — or Japanese dropped — that's a
larger, deliberate change touching every screen's ARB files, `l10n.yaml`
support list, and `SupportedLocales`, worth its own explicit ask.

---

## Room details (Phase 3.5)

`RoomDetailsScreen` (`RouteNames.roomDetails`, `/room/:roomId`) takes a
`RoomDetailsArgs` (bundling an already-loaded `RoomModel`, `UserModel`
host, and `List<ParticipantModel>`) via go_router's `extra` — it never
fetches or fabricates room data itself. As of Phase 3.7, `CreateRoomScreen`
pushes here with the real, just-written room on success; nothing else
(e.g. a room *list*) navigates here yet, but it no longer needs a
dedicated caller invented just to demo it — see "Create Room" below.

If `args` is ever null (e.g. a malformed deep link), the screen shows a
calm "Room Unavailable" state rather than crashing or rendering fake
content.

**No images anywhere** — the room preview is a dark purple gradient with
a centered, softly-glowing play icon (2s pulse loop) and a `LIVE` badge
driven by `room.status`; participant/host avatars are gradient circles
with an initial letter, not photos. All per spec ("no external images,
URLs, movie posters, or real content").

**Its own color pair**: `AppColors.roomBackground` (`#080812`) /
`roomCard` (`#121222`) / `roomBorder`, distinct from both the app's
default surface tokens and the authentication flow's — same pattern
already established for the auth screens in Phase 3.3.

**Deliberately no bottom navigation bar** on this screen — only the
reserved `BannerAdPlaceholder` strip at the bottom, per spec.

**Interactions that are UI-only stand-ins**, each surfaced with a
"coming soon" SnackBar rather than doing nothing silently: Share Room,
Invite Friends, Report Room (need platform share sheets / a moderation
backend), and Chat (needs the realtime chat this phase doesn't build).
Copy Room Code is the one option that's fully real — it copies
`room.id` to the clipboard. Voice Chat is a local on/off visual toggle
only; WebRTC isn't wired. Leave Room asks for confirmation, then pops
the route.

---

## Create Room (Phase 3.7)

`CreateRoomScreen` (`RouteNames.createRoom`, `/home/create-room`) is
the six-section form from the spec: Room Type (public/private, with
the password field only meaningful for private), Movie/Video
Information (title, optional cover, MP4/M3U8 video URL), Friends
(optional invite picker), Room Settings (max participants), More
Settings (voice chat / text chat / screen control / start-muted
toggles), and the password field itself. Reachable today via a
temporary FAB on `FoundationScreen` — real Home will replace that once
it exists, same as `RouteNames.roomDetails` before this phase.

**Friends picker**: backed by a new `friendsWithProfilesProvider`
(`lib/providers/friends_provider.dart`), which joins
`FriendRepository.streamFriends` (bare relationship rows) with
`UserRepository.getUser` per friend so the picker can show real names,
avatars, and online status — a join `FriendRepository` alone doesn't
provide. It resolves once per screen visit rather than staying
reactive; see the provider's doc comment for the trade-off.

**Premium gating**: `UserModel.isPremium` (already on the signed-in
user from `authStateProvider`) drives both the max-participants cap
(4 for free, 20 for Premium) and the M3U8 gate — entering an `.m3u8`
URL as a free user shows the spec's "This feature requires Premium.
Upgrade now?" dialog (`PremiumRequiredDialog`) instead of letting the
form submit; Upgrade pushes `RouteNames.premium` (still a "coming
soon" stand-in from Phase 3.6's drawer work).

**`RoomModel` grew five fields** this phase — `coverImageUrl`,
`allowVoiceChat`, `allowChat`, `allowScreenControl`,
`startWithMutedAudio` — all optional/defaulted, so existing Phase 3.5
room-details code and any previously-written Firestore documents keep
working unchanged. `RoomRepository.createRoom` grew matching optional
parameters.

**Its own color quartet**: `AppColors.createRoomBackground` (`#09090B`,
shared with the auth flow's exact value but named separately),
`createRoomCard` (`#12121A`), `createRoomBorder` (`#2B2B38`), and the
violet `createRoomPrimary`/`createRoomPrimaryHover` pair (`#8B5CF6` /
`#A855F7`) — distinct from every other screen's palette, per spec.

**No image picking** — "Choose Image" surfaces the same
`photoUploadComingSoonMessage` SnackBar `CompleteProfileScreen`
already uses for its camera button (no `image_picker` dependency yet);
"Convert your video" surfaces the shared `featureComingSoonMessage`
SnackBar rather than opening an undetermined external site. Friend
avatars are initial-letter gradient circles, matching `HostInfoCard`'s
no-external-images convention from Phase 3.5.

---

## Video Player (Phase 3.8)

`VideoPlayerScreen` (`RouteNames.videoPlayer`, `/room/:roomId/watch`)
is what `RoomDetailsScreen`'s preview card now opens into — tap it and
`RoomPreviewCard`'s new `onTap` pushes here. Unlike every earlier
screen in this project, it takes **no `extra` payload** — just a
`roomId` path parameter — because everything it needs is streamed live
via the new `lib/providers/room_stream_providers.dart`
(`roomStreamProvider`, `participantsStreamProvider`,
`messagesStreamProvider`, `pendingJoinRequestsStreamProvider`, all
`autoDispose.family`). Those wrap `RoomService.streamRoom`/
`streamParticipants`, which Phase 2 built but nothing had called until
now.

**Forced pre-roll**: `AdLoadingOverlay` sits over the video area for a
fixed 4 seconds on entry (no skip button, per spec) before local
playback state flips to playing — the same "space reserved, no real
SDK" precedent as `BannerAdPlaceholder` in Room Details, not a real
AdMob interstitial.

**No real video decoding.** This project still has no `video_player`/
HLS package, so the "video" is a plain black surface; playback is a
locally-ticking clock seeded from, and periodically resynced against,
`RoomModel.currentPositionMs`/`isPlaying` (real fields, really written
back via `RoomRepository.updatePlaybackState` — see below). A raw
MP4/M3U8 URL has no embedded duration without probing it, so the seek
bar's total length is a generous local placeholder
(`_durationMs`, ≥ 2 hours), clearly named and scoped to *display*
only — it never gets written to Firestore.

**Playback sync is real, permission is enforced**: the host can always
play/pause/seek/±10s; a member can too only if `RoomModel
.allowScreenControl` is on (set at Create Room) — otherwise every one
of those buttons shows the spec's exact "Only the room owner can
control playback." SnackBar instead of doing anything. Every
authorized action calls `updatePlaybackState`, which every other
client's `roomStreamProvider` picks up and resyncs to. Lock, fullscreen
(`SystemChrome.setEnabledSystemUIMode`), mic, and speaker are
per-viewer and never gated. Previous/Next aren't part of the spec's
synced set and there's no playlist for them to act on, so both just
show "coming soon".

**Participants panel** (`ParticipantsPanel`, 320dp, slides in over the
right rail) shows the live participant list with role
(Owner/Admin/Member, from `ParticipantModel.role`) and mic state, plus
— for the host, on rooms with pending requests — "Ahmed wants to
join." Accept/Reject cards. Those are backed by genuinely new
`RoomRepository` methods (`requestToJoin`, `streamPendingJoinRequests`,
`accept`/`rejectJoinRequest`) and a new `join_requests` collection /
`JoinRequestModel`. **Nothing calls `requestToJoin` yet** — there's no
"browse public rooms" screen in this project to call it from — so this
flow is fully implemented and functional but only exercisable once
that screen exists, the same position `RoomDetailsScreen` itself was
in before Phase 3.7.

**Chat is real**, not a placeholder: `ChatPanel` sends/streams through
the existing `MessageRepository` (built in Phase 2, likewise
previously uncalled). System join/leave messages
(`MessageType.system`, content `'joined'`/`'left'`) double as the data
behind `SystemToastOverlay`'s "Ahmed joined the room." toasts — sent
once per screen entry/leave, filtered out of the chat log itself, and
matched against a per-session "already toasted" set so a chat-history
resync never re-shows an old join as if it just happened.

**Leaving** goes through one path regardless of trigger (Leave button,
app bar back arrow, or the hardware/gesture back button — intercepted
via `PopScope(canPop: false)`): confirm, send a "left" system message,
log a `WatchHistoryRepository.logWatchSession` entry (title, URL,
`RoomModel.coverImageUrl`, and how far the person got) if the video
wasn't finished, then `RoomRepository.leaveRoomAndTransferHostIfNeeded`
— a new method that promotes whichever remaining participant joined
earliest to host if the person leaving was the host, so a room never
ends up without one.

**Its own color set**: `AppColors.videoPlayerBackground` (`#000000`,
true black — not `roomBackground`'s near-black from Room Details),
`videoPlayerCard` (`#111111`), `videoPlayerBorder` (`#2A2A2A`), and a
secondary-text shade (`#9CA3AF`) a touch cooler than the app-wide one —
all per spec. `videoPlayerPrimary`/`videoPlayerPrimaryHover` alias
`createRoomPrimary`/`primary` respectively (same hex values, no
restating).

---

## Not included (by design)

**Phase 2 (backend):**
- Firebase Storage usage (dependency + error mapping only, no upload code)
- iOS platform folder (Android remains the stated primary platform)
- Push notification *handling* UI (tap-to-navigate, in-app badges) — the
  FCM plumbing exists, but turning a tapped notification into a screen
  transition needs a screen to transition to first

**Phase 3.1 (splash):**
- The actual `assets/logo/app_logo.png` file — still not downloadable
  in this sandbox (no network access); every screen that shows the logo
  falls back to a branded placeholder of the same size until it's added
  — see `assets/logo/README.md`

**Phase 3.2 (onboarding):**
- Real onboarding illustrations — same no-network-access constraint as
  the logo; see `assets/illustrations/` and `OnboardingIllustration`'s
  doc comment
- Reading/writing the `onboarding_completed` flag — only the key name
  is reserved

**Phase 3.3 (authentication):**
- Any real Google/Facebook/Firebase Auth calls — `SocialContinueDialog`,
  the email forms, and Complete Profile are all UI-only stand-ins, per
  spec ("لا تقم بربط Firebase أو Google أو Facebook في هذه المرحلة")
- Persisting anything Complete Profile collects — no Firestore write
  happens; Continue just navigates
- The real Google "G" logo mark (IP + no network access) — a plain
  glyph stands in
- Real photo selection on Complete Profile's camera button (no
  `image_picker` dependency yet)

**Phase 3.5 (room details):**
- WebRTC (voice chat, video sync) — the mic button is a local visual
  toggle only
- Realtime chat, room sharing, invites, and reporting — all four
  surface a "coming soon" message rather than doing anything real
- AdMob — `BannerAdPlaceholder` reserves the space and nothing else

**Phase 3.7 (create room):**
- Real image picking for the room cover — no `image_picker` dependency
  yet, same constraint as Complete Profile's camera button; "Choose
  Image" surfaces a "coming soon" SnackBar
- The actual video-conversion destination — "Convert your video here"
  surfaces a "coming soon" SnackBar rather than opening a site, since
  the spec leaves that URL "to be determined later from app settings"
- A real Home/room-list screen — `CreateRoomScreen` is reachable via a
  temporary FAB on `FoundationScreen` until one exists
- Enforcing the free plan's 4-participant cap or the Premium gate
  server-side — both are client-side only in this phase, same trust
  model as the rest of Phase 3

**Phase 3.8 (video player):**
- Real video decoding/HLS playback — no `video_player` dependency yet;
  the video area is a black surface and the seek bar's total length is
  a local placeholder, never a fabricated real runtime (see "Video
  Player" above)
- A real AdMob interstitial for the pre-roll — `AdLoadingOverlay` is a
  fixed 4-second timer, the same "space reserved" precedent as
  `BannerAdPlaceholder`
- WebRTC for the mic/speaker rail — both toggles are local/per-viewer
  UI state (mic state does write to Firestore for the participants
  panel to show, but no audio is actually captured or transmitted)
- A "Speaking" indicator in the participants panel — spec calls for
  one, but it needs a real audio pipeline this phase doesn't have; only
  Muted/Online are shown
- Anything that *creates* a join request — `RoomRepository
  .requestToJoin` and the review UI for it are fully built, but nothing
  calls it without a "browse public rooms" screen to call it from
- A real emoji picker — the chat panel's emoji button inserts one fixed
  emoji rather than opening a picker

**Phase 3.4.1 (safety notice):**
- German (Deutsch) as a supported language — see the discrepancy note
  in "Safety notice" above
- Dynamic OS-level font scaling / high-contrast mode testing — the
  dialog uses ordinary `Text`/`MediaQuery`-respecting widgets (so it
  inherits whatever the OS requests) but wasn't tested against extreme
  scale factors specifically
