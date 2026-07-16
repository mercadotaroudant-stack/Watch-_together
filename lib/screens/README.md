# screens/

One subfolder per feature (e.g. `screens/auth/`, `screens/room/`), each
containing that feature's screen widget(s) plus any screen-only helper
widgets under a `widgets/` subfolder. Screens read state via Riverpod
providers and never call a repository or service directly.

## screens/splash/ (Phase 3.1)

The app's entry-point screen — a staged fade/scale intro that, after a
fixed delay, navigates to onboarding.

## screens/onboarding/ (Phase 3.2)

The three-page onboarding flow. Skip and Get Started navigate to
`RouteNames.authentication`.

## screens/auth/ (Phase 3.3)

The authentication flow: `authentication_screen.dart` (Google/Facebook/
Email choice — there is no standalone Sign In screen, per spec) and
`email/` (email sign-in, create account, forgot password). Pure UI: no
Firebase, no real Google/Facebook SDK calls.

## screens/complete_profile/ (Phase 3.3)

Shown once for a new account regardless of which sign-up path led here.
Continue is a UI-only stand-in that navigates to the temporary Home
placeholder — nothing is persisted yet.

## screens/room_details/ (Phase 3.5)

A single room's detail view — preview, host, who's watching, and the
voice/chat/leave controls. Not wired into the app's linear flow yet
(there's no room list/Home screen to launch it from with a real
`RoomModel`); fully built and routable on its own, typed against the
`RoomModel`/`UserModel`/`ParticipantModel`s already built in Phase 2.
See `room_details_screen.dart`'s doc comment.

Every other feature (home, friends, ...) remains empty until its own
phase.
