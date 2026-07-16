import 'package:equatable/equatable.dart';

import '../core/utils/firestore_converters.dart';
import 'enums.dart';

/// Mirrors a document in the `premium` collection.
///
/// Document id convention: the user's uid, so a user has exactly one
/// premium record, upserted rather than appended to.
class PremiumModel extends Equatable {
  const PremiumModel({
    required this.id,
    this.isActive = false,
    this.tier = PremiumTier.basic,
    this.plan = PremiumPlan.monthly,
    required this.startedAt,
    this.expiresAt,
    this.autoRenew = false,
    this.provider = PremiumProvider.googlePlay,
    this.transactionId,
  });

  /// Same value as the owning user's uid.
  final String id;
  final bool isActive;

  /// Basic / Plus / Max — which paid tier this subscription is for.
  /// Added for the Premium screen (Phase 3.11); older documents without
  /// a `tier` field default to [PremiumTier.basic] via [fromMap].
  final PremiumTier tier;
  final PremiumPlan plan;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final PremiumProvider provider;
  final String? transactionId;

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory PremiumModel.fromMap(String id, Map<String, dynamic> map) {
    return PremiumModel(
      id: id,
      isActive: map['isActive'] as bool? ?? false,
      tier: PremiumTierX.fromValue(map['tier'] as String?),
      plan: PremiumPlanX.fromValue(map['plan'] as String?),
      startedAt: FirestoreConverters.timestampToDate(map['startedAt']) ?? DateTime.now(),
      expiresAt: FirestoreConverters.timestampToDate(map['expiresAt']),
      autoRenew: map['autoRenew'] as bool? ?? false,
      provider: PremiumProviderX.fromValue(map['provider'] as String?),
      transactionId: map['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'tier': tier.name,
      'plan': plan.name,
      'startedAt': FirestoreConverters.dateToTimestamp(startedAt),
      'expiresAt': FirestoreConverters.dateToTimestamp(expiresAt),
      'autoRenew': autoRenew,
      'provider': provider.name,
      'transactionId': transactionId,
    };
  }

  PremiumModel copyWith({
    bool? isActive,
    PremiumTier? tier,
    PremiumPlan? plan,
    DateTime? expiresAt,
    bool? autoRenew,
    PremiumProvider? provider,
    String? transactionId,
  }) {
    return PremiumModel(
      id: id,
      isActive: isActive ?? this.isActive,
      tier: tier ?? this.tier,
      plan: plan ?? this.plan,
      startedAt: startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      provider: provider ?? this.provider,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  List<Object?> get props =>
      [id, isActive, tier, plan, startedAt, expiresAt, autoRenew, provider, transactionId];
}
