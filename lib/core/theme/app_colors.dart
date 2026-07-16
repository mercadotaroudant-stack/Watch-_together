import 'package:flutter/material.dart';

/// Raw color values for the WatchTogether dark theme.
///
/// These are intentionally kept as plain [Color] constants (rather than
/// baked directly into [ThemeData]) so any part of the app — theme, custom
/// painters, charts, etc. — can reference the exact brand palette without
/// going through `Theme.of(context)`.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFA855F7);

  // Surfaces
  static const Color background = Color(0xFF0B0B12);
  static const Color surface = Color(0xFF161622);
  static const Color border = Color(0xFF2A2A3C);

  // Feedback
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);

  // Derived, low-emphasis text/icon colors used throughout the theme.
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white @ 70%
  static const Color textDisabled = Color(0x61FFFFFF); // white @ 38%

  /// The literal secondary-text gray used by spec across splash,
  /// onboarding, and the authentication flow — distinct from
  /// [textSecondary] (which is white-at-opacity, not a solid color).
  static const Color secondaryText = Color(0xFFA1A1AA);

  // Authentication flow (Phase 3.3) — intentionally a touch darker than
  // [background]/[surface], per spec, for that flow only.
  static const Color authBackground = Color(0xFF09090B);
  static const Color authCard = Color(0xFF111118);

  // Room Details (Phase 3.5) — its own near-black/near-navy pair, per
  // spec, distinct from both [background]/[surface] and the auth flow's
  // tokens above.
  static const Color roomBackground = Color(0xFF080812);
  static const Color roomCard = Color(0xFF121222);
  static const Color roomBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Create Room (Phase 3.7) — its own background/card/border/accent quartet, per
  // spec, distinct from every palette above. [createRoomBackground]
  // happens to share [authBackground]'s exact value (both are #09090B
  // per spec) but is named separately since the two flows' palettes are
  // conceptually independent and may diverge later.
  static const Color createRoomBackground = authBackground;
  static const Color createRoomCard = Color(0xFF12121A);
  static const Color createRoomBorder = Color(0xFF2B2B38);
  static const Color createRoomPrimary = Color(0xFF8B5CF6);
  static const Color createRoomPrimaryHover = Color(0xFFA855F7);

  // Video Player (Phase 3.8) — its own background/card/border trio
  // (true black, not [roomBackground]'s near-black, since the video
  // area itself must be pure #000000 per spec) plus a secondary-text
  // shade a touch cooler than the app-wide one. [videoPlayerPrimary]
  // and [videoPlayerPrimaryHover] happen to equal [createRoomPrimary]
  // and [primary] respectively — aliased rather than restated, same as
  // [createRoomBackground] above.
  static const Color videoPlayerBackground = Color(0xFF000000);
  static const Color videoPlayerCard = Color(0xFF111111);
  static const Color videoPlayerBorder = Color(0xFF2A2A2A);
  static const Color videoPlayerPrimary = createRoomPrimary;
  static const Color videoPlayerPrimaryHover = primary;
  static const Color videoPlayerSecondaryText = Color(0xFF9CA3AF);

  // Participants bottom sheet (Phase 3.8.1) — its own background/border
  // pair per spec. [participantsSheetBackground] happens to equal
  // [authCard] (#111118) but is named separately since the sheet's
  // palette is a distinct spec surface, not a reuse of the auth flow's.
  static const Color participantsSheetBackground = Color(0xFF111118);
  static const Color participantsSheetBorder = Color(0xFF2A2A38);
  static const Color participantsSheetHandle = Color(0xFF3A3A48);
  static const Color adminBadgeGold = Color(0xFFF5B301);

  // Friends (Phase 3.9) — its own background/card/border/primary quartet,
  // per spec, distinct from every palette above. [friendsBackground] and
  // [friendsCard] happen to equal [authBackground]/[authCard] (#09090B /
  // #111118 per spec) but are named separately since this screen's
  // palette is its own spec surface, not a reuse of the auth flow's — same
  // aliasing convention as [createRoomBackground] above.
  static const Color friendsBackground = authBackground;
  static const Color friendsCard = authCard;
  static const Color friendsBorder = Color(0xFF27272F);
  static const Color friendsPrimary = Color(0xFF8B5CF6);
  static const Color friendsSecondary = Color(0xFFA855F7);
  static const Color friendsTextGray = Color(0xFF9CA3AF);
  static const Color friendsOnline = success;
  static const Color friendsAway = warning;
  static const Color friendsOffline = Color(0xFF6B7280);

  // Watch History (Phase 3.10) — its own near-black background scale,
  // distinct from every screen above (e.g. one shade darker than
  // [friendsBackground]/[authBackground]'s #09090B).
  static const Color historyBackground = Color(0xFF050507);
  static const Color historySecondaryBackground = Color(0xFF09090F);
  static const Color historyCard = Color(0xFF0D0D14);
  static const Color historyElevatedCard = Color(0xFF111118);
  static const Color historyPrimary = Color(0xFF8B5CF6);
  static const Color historyBrightPurple = Color(0xFF9333EA);
  static const Color historySecondaryPurple = Color(0xFF7C3AED);
  static const Color historyGradientStart = historyBrightPurple;
  static const Color historyGradientEnd = Color(0xFF6D28D9);
  static const Color historyPrimaryText = white;
  static const Color historySecondaryText = Color(0xFFA1A1AA);
  static const Color historyMutedText = Color(0xFF71717A);
  static const Color historyBorder = Color(0xFF27272F);
  static const Color historyProgressTrack = Color(0xFF27272F);
  static const Color historyDanger = error;
  static const Color historySuccess = success;

  // Premium / "Go Premium" (Phase 3.11) — its own background/card/border
  // set per spec, one shade darker than [historyBackground] (#050509 vs
  // #050507). Named separately rather than reused since this screen's
  // palette is its own spec surface, same convention as every quartet
  // above.
  static const Color premiumBackground = Color(0xFF050509);
  static const Color premiumCardBackground = Color(0xFF0F0F16);
  static const Color premiumCardBorder = Color(0xFF2A2A38);
  static const Color premiumBillingTrackBackground = Color(0xFF111118);
  static const Color premiumBillingTrackBorder = Color(0xFF2A2A38);

  static const Color premiumPrimaryPurple = Color(0xFF7C3AED);
  static const Color premiumAccentPurple = Color(0xFFA855F7);
  static const Color premiumGradientEnd = Color(0xFF9333EA);
  static const Color premiumBrightPurple = Color(0xFF8B5CF6);

  static const Color premiumBasicAccent = Color(0xFF8B5CF6);
  static const Color premiumBasicBadgeBackground = Color(0xFF2E1065);
  static const Color premiumBasicBadgeText = Color(0xFFC084FC);

  static const Color premiumPlusBorder = Color(0xFF8B5CF6);
  static const Color premiumPlusGradientStart = Color(0xFF21113D);
  static const Color premiumPlusGradientEnd = premiumCardBackground;

  static const Color premiumMaxAccent = Color(0xFFFBBF24);
  static const Color premiumMaxBorder = Color(0xA6FBBF24); // gold @ 65%
  static const Color premiumMaxBadgeText = Color(0xFF111111);

  static const Color premiumSecondaryText = Color(0xFFA1A1AA);
  static const Color premiumMutedText = Color(0xFF71717A);
  static const Color premiumFeatureText = Color(0xFFF4F4F5);

  static const Color premiumInactiveDot = Color(0xFF3F3F46);
  static const Color premiumActiveDot = Color(0xFF8B5CF6);

  // Menu / My Profile / My Rooms / legal & support screens — own palette
  // per spec, same convention as the Premium quartet above (close to but
  // not identical to the base [background]/[surface]/[border] triad).
  static const Color menuBackground = Color(0xFF070710);
  static const Color menuSurface = Color(0xFF0D0D18);
  static const Color menuCard = Color(0xFF111118);
  static const Color menuPrimaryPurple = Color(0xFF8B5CF6);
  static const Color menuBrightPurple = Color(0xFF9333EA);
  static const Color menuDarkViolet = Color(0xFF7C3AED);
  static const Color menuBorder = Color(0xFF242433);
  static const Color menuGold = Color(0xFFF5B942);
  static const Color menuSuccess = Color(0xFF22C55E);
  static const Color menuDanger = Color(0xFFFF3B5C);
  static const Color menuSecondaryText = Color(0xFFA7A7B8);

  // Home (Phase 4) — its own background/card/border/primary quartet,
  // per spec, one shade darker than [background] (#05050B vs #0B0B12),
  // same convention as every quartet above.
  static const Color homeBackground = Color(0xFF05050B);
  static const Color homeHeaderButtonBackground = Color(0xFF111118);
  static const Color homeHeaderButtonBorder = Color(0xFF2A2A38);
  static const Color homeWelcomeCardStart = Color(0xFF111118);
  static const Color homeWelcomeCardEnd = Color(0xFF171027);
  static const Color homeCard = Color(0xFF111118);
  static const Color homeBorder = Color(0xFF2A2A38);
  static const Color homePrimary = Color(0xFF7C3AED);
  static const Color homeSecondary = Color(0xFF9333EA);
  static const Color homePrimaryText = white;
  static const Color homeSecondaryText = Color(0xFFA1A1AA);
  static const Color homeMutedText = Color(0xFF71717A);
  static const Color homeProgressTrack = Color(0xFF27272F);
  static const Color homeBadgePurple = Color(0xFF8B5CF6);
  static const Color homeNotificationBadge = Color(0xFFA855F7);

  // Notifications (Phase 4) — reuses [homeBackground]/[homeCard]/
  // [homeBorder]/[homePrimary]/[homeSecondary]/[homeSecondaryText]/
  // [homeMutedText]/[homeBadgePurple]/[white]/[success]/[error]/
  // [warning] directly (every one an exact hex match against spec), and
  // [premiumCardBackground] for the "Surface" #0F0F16 spec calls for.
  // Only the "Elevated surface" #171722 doesn't exist anywhere yet.
  static const Color notificationsSurface = premiumCardBackground;
  static const Color notificationsElevatedSurface = Color(0xFF171722);
  static const Color notificationsPremiumGold = premiumMaxAccent;
}
