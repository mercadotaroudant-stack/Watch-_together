/// Shared enums for the Firestore-backed models.
///
/// Every enum here is stored in Firestore as its lowercase [name] (via
/// `.name`) and parsed back with a `fromValue` factory that falls back to
/// a safe default instead of throwing on unrecognized/legacy values.

enum VideoSource { youtube, direct, upload }

extension VideoSourceX on VideoSource {
  static VideoSource fromValue(String? value) => VideoSource.values.firstWhere(
        (e) => e.name == value,
        orElse: () => VideoSource.direct,
      );
}

enum RoomStatus { waiting, playing, paused, ended }

extension RoomStatusX on RoomStatus {
  static RoomStatus fromValue(String? value) => RoomStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => RoomStatus.waiting,
      );
}

enum ParticipantRole { host, moderator, member }

extension ParticipantRoleX on ParticipantRole {
  static ParticipantRole fromValue(String? value) => ParticipantRole.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ParticipantRole.member,
      );
}

enum MessageType { text, system, emoji }

extension MessageTypeX on MessageType {
  static MessageType fromValue(String? value) => MessageType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => MessageType.text,
      );
}

enum FriendStatus { pending, accepted, declined, blocked }

extension FriendStatusX on FriendStatus {
  static FriendStatus fromValue(String? value) => FriendStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => FriendStatus.pending,
      );
}

enum NotificationType { friendRequest, roomInvite, message, system, premium }

extension NotificationTypeX on NotificationType {
  static NotificationType fromValue(String? value) => NotificationType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NotificationType.system,
      );
}

enum PremiumPlan { monthly, yearly, lifetime }

extension PremiumPlanX on PremiumPlan {
  static PremiumPlan fromValue(String? value) => PremiumPlan.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PremiumPlan.monthly,
      );
}

/// Which paid tier a premium subscription belongs to — Basic, Plus, or
/// Max (Phase 3.11, the Premium/"Go Premium" screen). Independent of
/// [PremiumPlan], which is the *billing period* (monthly/yearly); a
/// subscription has exactly one of each, e.g. `(tier: plus, plan: yearly)`.
enum PremiumTier { basic, plus, max }

extension PremiumTierX on PremiumTier {
  static PremiumTier fromValue(String? value) => PremiumTier.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PremiumTier.basic,
      );
}

enum PremiumProvider { googlePlay, appStore, promo }

extension PremiumProviderX on PremiumProvider {
  static PremiumProvider fromValue(String? value) => PremiumProvider.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PremiumProvider.googlePlay,
      );
}

enum ReportReason { spam, harassment, inappropriateContent, impersonation, other }

extension ReportReasonX on ReportReason {
  static ReportReason fromValue(String? value) => ReportReason.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ReportReason.other,
      );
}

enum ReportStatus { pending, reviewed, actioned, dismissed }

extension ReportStatusX on ReportStatus {
  static ReportStatus fromValue(String? value) => ReportStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ReportStatus.pending,
      );
}

/// A pending request to join a room whose owner reviews it before the
/// requester becomes a participant — see `JoinRequestModel` and the
/// Video Player's Participants panel (Phase 3.8).
enum JoinRequestStatus { pending, accepted, rejected }

extension JoinRequestStatusX on JoinRequestStatus {
  static JoinRequestStatus fromValue(String? value) => JoinRequestStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => JoinRequestStatus.pending,
      );
}
