import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/helpers/app_logger.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/enums.dart';
import '../../models/participant_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/premium_providers.dart';
import '../../providers/repository_providers.dart';
import '../room_details/room_details_args.dart';
import 'widgets/create_room_app_bar.dart';
import 'widgets/create_room_section_card.dart';
import 'widgets/friends_section.dart';
import 'widgets/more_settings_section.dart';
import 'widgets/movie_info_section.dart';
import 'widgets/password_section.dart';
import 'widgets/premium_required_dialog.dart';
import 'widgets/room_settings_section.dart';
import 'widgets/room_type_section.dart';

/// Create Room (Phase 3.7) — set up a public or password-protected
/// room, its movie/video, who to invite, and the room's playback/
/// participant rules, then write it all to Firestore via
/// [RoomRepository.createRoom] and open [RoomDetailsScreen] as its host.
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _passwordController = TextEditingController();
  final _friendsSectionKey = GlobalKey();
  final _scrollController = ScrollController();

  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static final RegExp _videoFormatPattern = RegExp(r'\.(mp4|m3u8)(\?.*)?$', caseSensitive: false);
  static final RegExp _m3u8Pattern = RegExp(r'\.m3u8(\?.*)?$', caseSensitive: false);

  bool _isPrivate = false;
  final Set<String> _selectedFriendIds = {};
  int _maxParticipants = 4;
  bool _allowVoiceChat = true;
  bool _allowChat = true;
  bool _allowScreenControl = true;
  bool _startWithMutedAudio = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _titleController.dispose();
    _videoUrlController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRoomTypeChanged(bool isPrivate) {
    setState(() => _isPrivate = isPrivate);
  }

  void _handleToggleFriend(String friendId) {
    setState(() {
      if (!_selectedFriendIds.remove(friendId)) {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  void _handleInviteFriendsPressed() {
    final BuildContext? friendsContext = _friendsSectionKey.currentContext;
    if (friendsContext != null) {
      Scrollable.ensureVisible(
        friendsContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleChooseImagePressed() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.photoUploadComingSoonMessage)),
    );
  }

  void _handleConvertVideoPressed() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoonMessage)),
    );
  }

  String? _validateTitle(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if ((value ?? '').trim().isEmpty) return l10n.roomTitleRequiredError;
    return null;
  }

  String? _validateVideoUrl(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.videoUrlRequiredError;
    if (!_videoFormatPattern.hasMatch(trimmed)) return l10n.videoUrlInvalidError;
    return null;
  }

  String? _validatePassword(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String v = value ?? '';
    if (v.isEmpty) return l10n.roomPasswordRequiredError;
    if (v.length < 6 || v.length > 30) return l10n.roomPasswordLengthError;
    return null;
  }

  Future<void> _handleCreateRoom() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? currentUser = ref.read(authStateProvider).valueOrNull;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createRoomFailedMessage)),
      );
      return;
    }

    final bool formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final String videoUrl = _videoUrlController.text.trim();
    final bool isM3u8 = _m3u8Pattern.hasMatch(videoUrl);
    if (isM3u8 && !currentUser.isPremium) {
      final bool? wantsUpgrade = await PremiumRequiredDialog.show(context);
      if (wantsUpgrade == true && mounted) {
        context.push(RouteNames.premium);
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final roomRepository = ref.read(roomRepositoryProvider);
      final room = await roomRepository.createRoom(
        hostId: currentUser.uid,
        hostDisplayName: currentUser.displayName ?? '',
        hostPhotoUrl: currentUser.photoUrl,
        title: _titleController.text.trim(),
        videoUrl: videoUrl,
        videoSource: VideoSource.direct,
        isPrivate: _isPrivate,
        passcode: _isPrivate ? _passwordController.text : null,
        maxParticipants: _maxParticipants,
        allowVoiceChat: _allowVoiceChat,
        allowChat: _allowChat,
        allowScreenControl: _allowScreenControl,
        startWithMutedAudio: _startWithMutedAudio,
      );

      if (_selectedFriendIds.isNotEmpty) {
        final notificationRepository = ref.read(notificationRepositoryProvider);
        final userRepository = ref.read(userRepositoryProvider);
        final String hostName = currentUser.displayName ?? '';
        await Future.wait(
          _selectedFriendIds.map((friendId) async {
            // Respect the recipient's own "room invitations" preference
            // (My Profile > Notifications) — fail-open (still notify)
            // if their profile can't be read, so one bad fetch never
            // silently drops a real invite.
            final friend = await userRepository.getUser(friendId);
            if (friend != null && !friend.notifyRoomInvitations) return;

            await notificationRepository.createNotification(
              userId: friendId,
              type: NotificationType.roomInvite,
              title: l10n.roomInviteNotificationTitle(hostName),
              body: l10n.roomInviteNotificationBody(room.title),
              data: {
                'roomId': room.id,
                'inviterId': currentUser.uid,
                'inviterName': hostName,
                'roomTitle': room.title,
              },
            );
          }),
        );
      }

      if (!mounted) return;

      final host = ParticipantModel(
        id: ParticipantModel.buildId(roomId: room.id, userId: currentUser.uid),
        roomId: room.id,
        userId: currentUser.uid,
        displayName: currentUser.displayName ?? '',
        photoUrl: currentUser.photoUrl,
        role: ParticipantRole.host,
        joinedAt: DateTime.now(),
      );

      context.pushReplacement(
        RouteNames.roomDetailsPath(room.id),
        extra: RoomDetailsArgs(room: room, host: currentUser, participants: [host]),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Create Room: failed to create room for host ${currentUser.uid}', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createRoomFailedMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? currentUser = ref.watch(authStateProvider).valueOrNull;
    // The real source of truth for "is this user premium" — not the
    // `UserModel.isPremium` flag, which predates the real Premium/
    // subscription system and can drift from it. See `premium_providers.dart`.
    final bool isPremium = ref.watch(premiumStatusProvider).valueOrNull?.isActive ?? false;
    final int maxAllowed = ref.watch(maxRoomParticipantsProvider);

    // Free accounts can't exceed the free cap even if this value was
    // left over from a Premium session that just expired.
    if (!isPremium && _maxParticipants > 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _maxParticipants = 4);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.createRoomBackground,
      body: SafeArea(
        child: Column(
          children: [
            CreateRoomAppBar(
              onBackPressed: () => context.pop(),
              onInviteFriendsPressed: _handleInviteFriendsPressed,
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CreateRoomSectionCard(
                                number: 1,
                                title: l10n.sectionRoomType,
                                child: RoomTypeSection(
                                  isPrivate: _isPrivate,
                                  onChanged: _handleRoomTypeChanged,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CreateRoomSectionCard(
                                number: 2,
                                title: l10n.sectionMovieInfo,
                                child: MovieInfoSection(
                                  titleController: _titleController,
                                  videoUrlController: _videoUrlController,
                                  titleValidator: _validateTitle,
                                  videoUrlValidator: _validateVideoUrl,
                                  isPremium: isPremium,
                                  onChooseImagePressed: _handleChooseImagePressed,
                                  onConvertVideoPressed: _handleConvertVideoPressed,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CreateRoomSectionCard(
                                key: _friendsSectionKey,
                                number: 3,
                                title: l10n.sectionFriends,
                                child: FriendsSection(
                                  selectedFriendIds: _selectedFriendIds,
                                  onToggle: _handleToggleFriend,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CreateRoomSectionCard(
                                number: 4,
                                title: l10n.sectionRoomSettings,
                                trailing: _PlanBadge(isPremium: isPremium),
                                child: RoomSettingsSection(
                                  maxParticipants: _maxParticipants,
                                  isPremium: isPremium,
                                  maxAllowed: maxAllowed,
                                  onChanged: (value) => setState(() => _maxParticipants = value),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CreateRoomSectionCard(
                                      number: 5,
                                      title: l10n.sectionMoreSettings,
                                      child: MoreSettingsSection(
                                        allowVoiceChat: _allowVoiceChat,
                                        allowChat: _allowChat,
                                        allowScreenControl: _allowScreenControl,
                                        startWithMutedAudio: _startWithMutedAudio,
                                        onVoiceChatChanged: (v) =>
                                            setState(() => _allowVoiceChat = v),
                                        onChatChanged: (v) => setState(() => _allowChat = v),
                                        onScreenControlChanged: (v) =>
                                            setState(() => _allowScreenControl = v),
                                        onStartMutedChanged: (v) =>
                                            setState(() => _startWithMutedAudio = v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CreateRoomSectionCard(
                                      number: 6,
                                      title: l10n.sectionPassword,
                                      child: PasswordSection(
                                        controller: _passwordController,
                                        enabled: _isPrivate,
                                        validator: _validatePassword,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _CreateRoomButton(
                                label: l10n.createRoomButton,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _handleCreateRoom,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_outline_rounded,
                                      size: 13, color: AppColors.secondaryText),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.createRoomFooterNote,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Color color = isPremium ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPremium ? l10n.premiumPlanBadge : l10n.freePlanBadge,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _CreateRoomButton extends StatefulWidget {
  const _CreateRoomButton({required this.label, required this.isLoading, required this.onPressed});

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_CreateRoomButton> createState() => _CreateRoomButtonState();
}

class _CreateRoomButtonState extends State<_CreateRoomButton> {
  double _scale = 1;

  void _setPressed(bool pressed) {
    if (widget.onPressed == null) return;
    setState(() => _scale = pressed ? 0.98 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(18);
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 58,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  colors: isEnabled
                      ? [AppColors.createRoomPrimary, AppColors.createRoomPrimaryHover]
                      : [
                          AppColors.createRoomPrimary.withOpacity(0.4),
                          AppColors.createRoomPrimaryHover.withOpacity(0.4),
                        ],
                ),
              ),
              child: InkWell(
                borderRadius: borderRadius,
                onTap: widget.onPressed,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.label,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
