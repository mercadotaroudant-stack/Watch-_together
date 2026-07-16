import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'repository_providers.dart';

/// One-shot lookup of a user's current profile by uid — for cards that
/// only have a stored userId (e.g. a room invite's `inviterId`, a
/// friend request's `fromUserId`) and want that person's live name/
/// photo rather than a value baked into a notification's `data` at
/// write time. `autoDispose` + Riverpod's built-in request de-duping
/// means repeated cards for the same uid share one fetch.
final AutoDisposeFutureProviderFamily<UserModel?, String> userByIdProvider =
    FutureProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUser(uid);
});
