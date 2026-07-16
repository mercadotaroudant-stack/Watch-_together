import '../../models/enums.dart';

/// The maximum room size each real Premium tier unlocks — the same
/// numbers advertised on the Premium screen's plan cards (see
/// `premium_plan_content.dart`'s Basic/Plus/Max feature lists), kept
/// here as actual `int`s so participant-limit logic (Create Room's
/// slider, room-join checks, etc.) has one real source of truth instead
/// of re-deriving it from display strings.
abstract final class PremiumTierLimits {
  static const int freeMaxParticipants = 4;

  static const Map<PremiumTier, int> maxParticipantsByTier = {
    PremiumTier.basic: 8,
    PremiumTier.plus: 15,
    PremiumTier.max: 20,
  };

  /// The real cap for a user's current subscription — [freeMaxParticipants]
  /// unless they have an *active* premium subscription with a known tier.
  static int maxParticipantsFor({required bool isActive, PremiumTier? tier}) {
    if (!isActive || tier == null) return freeMaxParticipants;
    return maxParticipantsByTier[tier] ?? freeMaxParticipants;
  }
}
