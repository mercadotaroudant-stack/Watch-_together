/// Route path constants for go_router.
///
/// Kept as a flat list of string paths (rather than an enum) because
/// go_router matches on path strings directly, including nested/param
/// segments (e.g. `/room/:roomId`) that don't map cleanly to enum values.
abstract final class RouteNames {
  /// App entry point — the splash screen (Phase 3.1).
  static const String splash = '/';

  /// The three-page onboarding flow (Phase 3.2).
  static const String onboarding = '/onboarding';

  /// The authentication entry point (Phase 3.3) — Google/Facebook/Email
  /// choice. Per spec there is no standalone "Sign In" screen; this
  /// *is* the app's one authentication landing screen.
  static const String authentication = '/auth';

  /// Email sign-in (existing account) — reached only via the Email
  /// button on [authentication].
  static const String emailAuth = '/auth/email';

  /// Email sign-up (new account) — reached only via "Create Account" on
  /// [emailAuth].
  static const String createAccount = '/auth/create-account';

  /// Reached only via "Forgot Password" on [emailAuth].
  static const String forgotPassword = '/auth/forgot-password';

  /// Shown once for a new account, from any sign-up path (Google,
  /// Facebook, or email Create Account).
  static const String completeProfile = '/complete-profile';

  /// The real Home screen (Phase 4) — landing spot for "already signed
  /// in" / "profile complete". Was `FoundationScreen` (a temporary
  /// bootstrap screen) until Phase 4 replaced it with `HomeScreen`.
  static const String home = '/home';

  /// Create Room (Phase 3.7), reached from Home's Quick Actions.
  /// Not nested under `/home/...` like the drawer destinations below —
  /// it's a primary Home action, not a drawer entry — but still a
  /// child route of the app's post-auth section.
  static const String createRoom = '/home/create-room';

  /// Join Room (Phase 4), reached from Home's Quick Actions. Room-code
  /// only, per spec — no room name/search. Sibling of [createRoom],
  /// same rationale for not living under a drawer-style path.
  static const String joinRoom = '/home/join-room';

  /// A single room's detail view (Phase 3.5). Takes a `roomId` path
  /// segment for deep-linking (e.g. a shared room link), and expects a
  /// `RoomDetailsArgs` via go_router's `extra` when navigated to from
  /// within the app, so the caller's already-loaded `RoomModel`/
  /// `UserModel`/`ParticipantModel`s (from Phase 2's repositories) don't
  /// need to be re-fetched. See `RoomDetailsScreen`'s doc comment.
  static const String roomDetails = '/room/:roomId';

  /// Builds a concrete [roomDetails] path for a given room id.
  static String roomDetailsPath(String roomId) => '/room/$roomId';

  /// The actual in-room watch-party screen (Phase 3.8) — video area,
  /// transport controls, mic/speaker/chat/participants rail. Nested
  /// under [roomDetails]'s own `/room/:roomId` segment (as `/watch`)
  /// since it's the next step *from* Room Details, not a sibling of it.
  /// Everything it needs (room, participants, chat, join requests) is
  /// streamed live by `roomId` alone — see `RoomRepository`'s
  /// `streamRoom`/`streamParticipants` and `room_stream_providers.dart`
  /// — so unlike [roomDetails] it takes no `extra` payload.
  static const String videoPlayer = '/room/:roomId/watch';

  /// Builds a concrete [videoPlayer] path for a given room id.
  static String videoPlayerPath(String roomId) => '/room/$roomId/watch';

  // --- Navigation Drawer destinations (Phase 3.6) ---
  //
  // All nested under `/home/...` since every one of them is only ever
  // reached from the drawer that lives on [home]. Screens not yet given
  // a full build (everything except [settings]) resolve to
  // `ComingSoonScreen` in `app_router.dart` — routed for real so the
  // drawer is fully navigable today, upgraded to real screens one at a
  // time without touching the drawer itself.
  static const String profile = '/home/profile';
  static const String premium = '/home/premium';
  static const String friends = '/home/friends';
  static const String myRooms = '/home/my-rooms';
  static const String watchHistory = '/home/watch-history';
  static const String notifications = '/home/notifications';
  static const String settings = '/home/settings';
  static const String helpSupport = '/home/help-support';
  static const String communityGuidelines = '/home/community-guidelines';
  static const String privacyPolicy = '/home/privacy-policy';
  static const String termsOfService = '/home/terms-of-service';
  static const String about = '/home/about';
}
