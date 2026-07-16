import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/about/about_screen.dart';
import '../../screens/auth/authentication_screen.dart';
import '../../screens/auth/email/create_account_screen.dart';
import '../../screens/auth/email/email_auth_screen.dart';
import '../../screens/auth/email/forgot_password_screen.dart';
import '../../screens/complete_profile/complete_profile_screen.dart';
import '../../screens/create_room/create_room_screen.dart';
import '../../screens/friends/friends_screen.dart';
import '../../screens/help_support/help_support_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/join_room/join_room_screen.dart';
import '../../screens/legal/community_guidelines_screen.dart';
import '../../screens/legal/privacy_policy_screen.dart';
import '../../screens/legal/terms_of_service_screen.dart';
import '../../screens/my_rooms/my_rooms_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/my_profile_screen.dart';
import '../../screens/watch_history/watch_history_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/premium/premium_screen.dart';
import '../../screens/room_details/room_details_args.dart';
import '../../screens/room_details/room_details_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/video_player/video_player_screen.dart';
import 'route_names.dart';

/// The single [GoRouter] instance for the app, exposed as a Riverpod
/// provider so it can later depend on auth/session state (e.g. redirecting
/// to a login route) without any widget needing to reach for a global.
///
/// go_router was chosen over Navigator 1.0/imperative routing and over
/// `auto_route` for a declarative, URL-based API with built-in deep-link
/// and redirect support — see README.md for the full rationale.
///
/// As of Phase 4, the flow is: [SplashScreen] -> [OnboardingScreen] ->
/// [AuthenticationScreen] -> (Google/Facebook dialog, or the email
/// sub-flow) -> [CompleteProfileScreen] (new accounts only) -> the real
/// [HomeScreen] at [RouteNames.home].
///
/// [RouteNames.createRoom] (Phase 3.7) and [RouteNames.joinRoom]
/// (Phase 4) are reachable from [HomeScreen]'s Quick Actions, and on
/// success push [RouteNames.roomDetails] with real, just-written
/// `RoomModel`/`UserModel` data. [RouteNames.videoPlayer] (Phase 3.8) is
/// one tap further in, from [RoomDetailsScreen]'s preview card.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.authentication,
        name: 'authentication',
        builder: (context, state) => const AuthenticationScreen(),
      ),
      GoRoute(
        path: RouteNames.emailAuth,
        name: 'emailAuth',
        builder: (context, state) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: RouteNames.createAccount,
        name: 'createAccount',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.completeProfile,
        name: 'completeProfile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.createRoom,
        name: 'createRoom',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: RouteNames.joinRoom,
        name: 'joinRoom',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const MyProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.premium,
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: RouteNames.friends,
        name: 'friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: RouteNames.myRooms,
        name: 'myRooms',
        builder: (context, state) => const MyRoomsScreen(),
      ),
      GoRoute(
        path: RouteNames.watchHistory,
        name: 'watchHistory',
        builder: (context, state) => const WatchHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.helpSupport,
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: RouteNames.communityGuidelines,
        name: 'communityGuidelines',
        builder: (context, state) => const CommunityGuidelinesScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RouteNames.termsOfService,
        name: 'termsOfService',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: RouteNames.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteNames.roomDetails,
        name: 'roomDetails',
        builder: (context, state) => RoomDetailsScreen(args: state.extra as RoomDetailsArgs?),
      ),
      GoRoute(
        path: RouteNames.videoPlayer,
        name: 'videoPlayer',
        builder: (context, state) =>
            VideoPlayerScreen(roomId: state.pathParameters['roomId']!),
      ),
    ],
  );
});
