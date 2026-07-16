import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../core/errors/app_exception.dart';
import '../../core/helpers/app_logger.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../models/join_request_model.dart';
import '../../models/message_model.dart';
import '../../models/participant_model.dart';
import '../../models/room_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/room_stream_providers.dart';
import 'widgets/ad_loading_overlay.dart';
import 'widgets/chat_panel.dart';
import 'widgets/participants_panel.dart';
import 'widgets/right_rail.dart';
import 'widgets/system_toast_overlay.dart';
import 'widgets/video_controls_overlay.dart';
import 'widgets/video_error_overlay.dart';
import 'widgets/video_player_app_bar.dart';

/// The in-room watch-party screen (Phase 3.8) — the actual "watching
/// together" experience `RoomDetailsScreen`'s preview card leads into.
///
/// Takes only [roomId]; everything else (room state, participants,
/// chat, join requests) is streamed live via `room_stream_providers.dart`
/// — the realtime plumbing Phase 2's `RoomService` already had, just
/// with its first real caller.
///
/// Real playback (Phase 4 P0 fix): [VideoPlayerController]
/// (`package:video_player`) decodes `RoomModel.videoUrl` directly — MP4
/// and HLS (.m3u8) both work through the same controller on Android, no
/// format branching needed on the Dart side. The controller's own
/// position is the source of truth once initialized; the previous
/// locally-ticking-clock placeholder is gone. [_durationMs] still falls
/// back to a generous placeholder only until the real controller reports
/// its actual duration.
class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

/// Why the room itself couldn't be loaded — kept distinct from a
/// genuinely-missing room (`RoomLoadFailure.notFound`) so a Firestore
/// rules/network problem doesn't render identically to "this room was
/// deleted", per the Phase 4 P0 audit.
enum _RoomLoadFailure { notFound, permissionDenied, network, unknown }

enum _VideoLoadStatus { initializing, ready, buffering, invalidUrl, error }

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> with WidgetsBindingObserver {
  static const Duration _adDuration = Duration(seconds: 4);
  static const Duration _hideControlsDelay = Duration(seconds: 3);
  static const int _minPlaceholderDurationMs = 7200000; // 2h, see class doc.

  /// The Chat panel's fixed slide-in width (Participants moved to a
  /// bottom sheet — see `showParticipantsPanel` — so this is now the
  /// only consumer of the old shared panel width).
  static const double _sidePanelWidth = 320;

  Timer? _adTimer;
  Timer? _hideControlsTimer;
  Timer? _tickTimer;
  final List<Timer> _toastTimers = [];

  bool _isAdShowing = true;
  bool _isPlaying = false;
  bool _isLocked = false;
  bool _isFullscreen = false;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;
  bool _controlsVisible = true;
  bool _chatOpen = false;
  bool _isLeaving = false;
  bool _micSeeded = false;
  bool _hasInitializedPosition = false;

  int _positionMs = 0;
  int _durationMs = _minPlaceholderDurationMs;
  int _unreadChatCount = 0;
  String? _myParticipantId;

  VideoPlayerController? _videoController;
  _VideoLoadStatus _videoStatus = _VideoLoadStatus.initializing;
  String? _initializedVideoUrl;

  /// Ticks once per second alongside [_tickTimer]; watch-history
  /// progress is saved every 12 of these (~12s) rather than every tick —
  /// see `WatchHistoryRepository.upsertProgress` doc.
  int _secondsSinceLastHistorySave = 0;
  static const int _historySaveIntervalSeconds = 12;

  final DateTime _enteredAt = DateTime.now();
  final Set<String> _seenSystemMessageIds = {};
  final List<({String id, String displayName, bool joined})> _toasts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _adTimer = Timer(_adDuration, _handleAdFinished);
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final VideoPlayerController? controller = _videoController;
      if (controller == null || !controller.value.isInitialized || _isAdShowing) return;

      final int realPositionMs = controller.value.position.inMilliseconds;
      if (realPositionMs != _positionMs) {
        setState(() => _positionMs = realPositionMs);
      }
      if (_isPlaying) {
        _secondsSinceLastHistorySave++;
        if (_secondsSinceLastHistorySave >= _historySaveIntervalSeconds) {
          _secondsSinceLastHistorySave = 0;
          _saveWatchProgress();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adTimer?.cancel();
    _hideControlsTimer?.cancel();
    _tickTimer?.cancel();
    for (final t in _toastTimers) {
      t.cancel();
    }
    _videoController?.removeListener(_onVideoControllerUpdate);
    _videoController?.dispose();
    // Best-effort: the widget tree is already coming down, so this fires
    // without an await, same as any other "flush on the way out" write.
    // Guarded — `ref` may already be torn down by the time dispose runs.
    try {
      _saveWatchProgress();
    } catch (_) {}
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveWatchProgress();
    }
  }

  /// Persists the current playback position as real watch-history
  /// progress — see rule set in `WatchHistoryRepository`. A no-op
  /// before real playback has started (`_isAdShowing`) or once
  /// [_positionMs] is still `0`, so opening a room/watching the
  /// pre-roll ad never creates a history record.
  void _saveWatchProgress() {
    if (_isAdShowing || _positionMs <= 0) return;
    final currentUser = ref.read(authStateProvider).valueOrNull;
    final RoomModel? room = ref.read(roomStreamProvider(widget.roomId)).valueOrNull;
    if (currentUser == null || room == null) return;

    unawaited(
      ref.read(watchHistoryRepositoryProvider).upsertProgress(
            userId: currentUser.uid,
            roomId: room.id,
            videoTitle: room.title,
            videoUrl: room.videoUrl,
            backgroundImageUrl: room.coverImageUrl,
            lastPositionMs: _positionMs,
            durationMs: _durationMs,
          ),
    );
  }

  void _handleAdFinished() {
    if (!mounted) return;
    setState(() {
      _isAdShowing = false;
      _isPlaying = true;
    });
    final VideoPlayerController? controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.play();
    }
    _pushPlaybackState();
    _resetHideControlsTimer();
  }

  // --- Controls visibility / lock -------------------------------------

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isLocked) return;
    _hideControlsTimer = Timer(_hideControlsDelay, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _handleVideoAreaTap() {
    if (_isLocked) return;
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _resetHideControlsTimer();
  }

  void _handleToggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      _controlsVisible = true;
    });
    if (!_isLocked) _resetHideControlsTimer();
  }

  // --- Playback ---------------------------------------------------------

  void _pushPlaybackState() {
    final RoomModel? room = ref.read(roomStreamProvider(widget.roomId)).valueOrNull;
    if (room == null) return;
    ref.read(roomRepositoryProvider).updatePlaybackState(
          roomId: room.id,
          currentPositionMs: _positionMs,
          isPlaying: _isPlaying,
        );
  }

  void _handlePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    final VideoPlayerController? controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      _isPlaying ? controller.play() : controller.pause();
    }
    _pushPlaybackState();
    _resetHideControlsTimer();
    if (!_isPlaying) _saveWatchProgress();
  }

  void _handleSeekBy(int deltaMs) {
    final int target = (_positionMs + deltaMs).clamp(0, _durationMs).toInt();
    setState(() => _positionMs = target);
    _videoController?.seekTo(Duration(milliseconds: target));
    _pushPlaybackState();
    _resetHideControlsTimer();
  }

  void _handleSeekTo(int ms) {
    final int target = ms.clamp(0, _durationMs).toInt();
    setState(() => _positionMs = target);
    _videoController?.seekTo(Duration(milliseconds: target));
    _pushPlaybackState();
    _resetHideControlsTimer();
  }

  // --- Real video engine (Phase 4 P0 fix) --------------------------------

  /// Initializes a real [VideoPlayerController] against [url] — the
  /// engine that replaced the old locally-ticking-clock placeholder.
  /// Guards against re-initializing the same URL twice (the room stream
  /// can re-emit for unrelated field changes) and against a stale
  /// `RoomModel.videoUrl` edit while a session is already underway by
  /// tearing down the previous controller first.
  Future<void> _initializeVideo(String url) async {
    if (url == _initializedVideoUrl && _videoController != null) return;
    _initializedVideoUrl = url;

    final VideoPlayerController? previous = _videoController;
    previous?.removeListener(_onVideoControllerUpdate);
    if (mounted) {
      setState(() {
        _videoController = null;
        _videoStatus = _VideoLoadStatus.initializing;
      });
    }
    await previous?.dispose();

    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        url.isEmpty ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      AppLogger.warning(
        'Video Player: invalid/unsupported video URL for room ${widget.roomId}: "$url"',
      );
      if (mounted) setState(() => _videoStatus = _VideoLoadStatus.invalidUrl);
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onVideoControllerUpdate);

      final int realDurationMs = controller.value.duration.inMilliseconds;
      setState(() {
        _videoController = controller;
        _videoStatus = _VideoLoadStatus.ready;
        if (realDurationMs > 0) _durationMs = realDurationMs;
      });

      await controller.seekTo(Duration(milliseconds: _positionMs));
      if (_isPlaying && !_isAdShowing) {
        await controller.play();
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Video Player: failed to initialize video for room ${widget.roomId}: $url',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _videoStatus = _VideoLoadStatus.error);
    }
  }

  void _onVideoControllerUpdate() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !mounted) return;
    final value = controller.value;

    if (value.hasError) {
      AppLogger.error(
        'Video Player: playback error for room ${widget.roomId}: ${value.errorDescription}',
      );
      if (_videoStatus != _VideoLoadStatus.error) {
        setState(() => _videoStatus = _VideoLoadStatus.error);
      }
      return;
    }

    final _VideoLoadStatus next = value.isBuffering ? _VideoLoadStatus.buffering : _VideoLoadStatus.ready;
    if (next != _videoStatus) {
      setState(() => _videoStatus = next);
    }
  }

  void _retryVideo() {
    final RoomModel? room = ref.read(roomStreamProvider(widget.roomId)).valueOrNull;
    if (room == null) return;
    _initializedVideoUrl = null; // force re-attempt even for the same URL
    _initializeVideo(room.videoUrl);
  }

  void _handleUnauthorizedControlTap() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.onlyOwnerCanControlPlaybackMessage)),
    );
  }

  void _handleComingSoon() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoonMessage)),
    );
  }

  void _handleToggleFullscreen() {
    final bool next = !_isFullscreen;
    setState(() => _isFullscreen = next);
    SystemChrome.setEnabledSystemUIMode(
      next ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  // --- Mic / speaker / panels -------------------------------------------

  void _handleToggleMic() {
    final String? participantId = _myParticipantId;
    final bool next = !_isMicOn;
    setState(() => _isMicOn = next);
    if (participantId != null) {
      ref
          .read(roomRepositoryProvider)
          .updateParticipantMuted(participantId: participantId, isMuted: !next);
    }
  }

  void _handleToggleSpeaker() => setState(() => _isSpeakerOn = !_isSpeakerOn);

  void _handleOpenChat() {
    setState(() {
      _chatOpen = true;
      _unreadChatCount = 0;
    });
  }

  Future<void> _handleOpenParticipants() async {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    final RoomModel? room = ref.read(roomStreamProvider(widget.roomId)).valueOrNull;
    if (currentUser == null || room == null) return;

    setState(() => _chatOpen = false);
    await showParticipantsPanel(
      context,
      room: room,
      currentUserId: currentUser.uid,
      currentUserName: currentUser.displayName ?? '',
      isHost: room.hostId == currentUser.uid,
      onAcceptRequest: _handleAcceptJoinRequest,
      onRejectRequest: _handleRejectJoinRequest,
    );
  }

  // --- Stream reactions ---------------------------------------------------

  void _handleRoomUpdate(AsyncValue<RoomModel?>? previous, AsyncValue<RoomModel?> next) {
    if (next.hasError && !(previous?.hasError ?? false)) {
      AppLogger.error(
        'Video Player: room ${widget.roomId} stream error (${_classifyRoomLoadFailure(next).name})',
        error: next.error,
        stackTrace: next.stackTrace,
      );
    }

    final RoomModel? room = next.valueOrNull;
    if (room == null) return;

    if (!_hasInitializedPosition) {
      _hasInitializedPosition = true;
      if (mounted) {
        setState(() {
          _positionMs = room.currentPositionMs;
          _durationMs = math.max(_minPlaceholderDurationMs, room.currentPositionMs + 1800000);
        });
      }
      _announceJoin(room);
      _initializeVideo(room.videoUrl);
    } else if (mounted) {
      // A remote play/pause/seek — resync (small corrections are
      // expected here, same as any "watch party" sync scheme).
      final int resyncedPositionMs = room.currentPositionMs.clamp(0, _durationMs).toInt();
      setState(() {
        _positionMs = resyncedPositionMs;
        if (!_isAdShowing) _isPlaying = room.isPlaying;
      });

      if (room.videoUrl != _initializedVideoUrl) {
        // The host changed the video mid-session — re-initialize
        // against the new real URL rather than silently keep playing
        // the old one.
        _initializeVideo(room.videoUrl);
        return;
      }

      final VideoPlayerController? controller = _videoController;
      if (controller != null && controller.value.isInitialized) {
        final Duration target = Duration(milliseconds: resyncedPositionMs);
        if ((controller.value.position - target).abs() > const Duration(seconds: 2)) {
          controller.seekTo(target);
        }
        if (!_isAdShowing) {
          _isPlaying ? controller.play() : controller.pause();
        }
      }
    }
  }

  Future<void> _announceJoin(RoomModel room) async {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser == null) return;
    try {
      await ref.read(messageRepositoryProvider).sendMessage(
            roomId: room.id,
            senderId: currentUser.uid,
            senderName: currentUser.displayName ?? '',
            senderPhotoUrl: currentUser.photoUrl,
            content: 'joined',
            type: MessageType.system,
          );
    } catch (_) {
      // Best-effort — a failed system message shouldn't block watching.
    }
  }

  void _handleMessagesUpdate(
    AsyncValue<List<MessageModel>>? previous,
    AsyncValue<List<MessageModel>> next,
  ) {
    final List<MessageModel>? messages = next.valueOrNull;
    if (messages == null || !mounted) return;
    final String? myId = ref.read(authStateProvider).valueOrNull?.uid;

    for (final message in messages) {
      if (!message.createdAt.isAfter(_enteredAt)) continue;
      if (_seenSystemMessageIds.contains(message.id)) continue;

      if (message.type == MessageType.system) {
        _seenSystemMessageIds.add(message.id);
        final bool joined = message.content == 'joined';
        setState(() {
          _toasts.add((id: message.id, displayName: message.senderName, joined: joined));
        });
        _toastTimers.add(Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _toasts.removeWhere((t) => t.id == message.id));
        }));
      } else if (!_chatOpen && message.senderId != myId) {
        _seenSystemMessageIds.add(message.id);
        setState(() => _unreadChatCount++);
      }
    }
  }

  // --- Leave --------------------------------------------------------------

  Future<void> _handleLeavePressed() async {
    if (_isLeaving) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.videoPlayerCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.leaveRoomConfirmTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        content: Text(
          l10n.leaveRoomConfirmMessage,
          style: GoogleFonts.poppins(color: AppColors.videoPlayerSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel,
                style: GoogleFonts.poppins(color: AppColors.videoPlayerSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.leaveRoom,
              style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _performLeave();
  }

  Future<void> _performLeave() async {
    setState(() => _isLeaving = true);

    final currentUser = ref.read(authStateProvider).valueOrNull;
    final RoomModel? room = ref.read(roomStreamProvider(widget.roomId)).valueOrNull;
    final List<ParticipantModel> participants =
        ref.read(participantsStreamProvider(widget.roomId)).valueOrNull ?? const [];

    if (currentUser != null && room != null) {
      try {
        await ref.read(messageRepositoryProvider).sendMessage(
              roomId: room.id,
              senderId: currentUser.uid,
              senderName: currentUser.displayName ?? '',
              senderPhotoUrl: currentUser.photoUrl,
              content: 'left',
              type: MessageType.system,
            );
      } catch (_) {}

      try {
        if (!_isAdShowing && _positionMs > 0) {
          await ref.read(watchHistoryRepositoryProvider).upsertProgress(
                userId: currentUser.uid,
                roomId: room.id,
                videoTitle: room.title,
                videoUrl: room.videoUrl,
                backgroundImageUrl: room.coverImageUrl,
                lastPositionMs: _positionMs,
                durationMs: _durationMs,
              );
        }
      } catch (_) {}

      try {
        await ref.read(roomRepositoryProvider).leaveRoomAndTransferHostIfNeeded(
              room: room,
              participants: participants,
              leavingUserId: currentUser.uid,
            );
      } catch (_) {}
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _handleAcceptJoinRequest(JoinRequestModel request) =>
      ref.read(roomRepositoryProvider).acceptJoinRequest(request);

  Future<void> _handleRejectJoinRequest(JoinRequestModel request) =>
      ref.read(roomRepositoryProvider).rejectJoinRequest(request);

  /// Turns a null-room [AsyncValue] into a concrete [_RoomLoadFailure] —
  /// the Phase 4 P0 fix for every load failure previously rendering as
  /// the same generic "Room Unavailable" regardless of cause.
  /// [FirestoreException.code] (set by `FirebaseErrorMapper`) already
  /// distinguishes these at the error-mapping layer; this just reads it.
  _RoomLoadFailure _classifyRoomLoadFailure(AsyncValue<RoomModel?> roomAsync) {
    if (!roomAsync.hasError) return _RoomLoadFailure.notFound;

    final Object? error = roomAsync.error;
    if (error is FirestoreException) {
      switch (error.code) {
        case 'permission-denied':
          return _RoomLoadFailure.permissionDenied;
        case 'unavailable':
        case 'deadline-exceeded':
        case 'cancelled':
          return _RoomLoadFailure.network;
        default:
          return _RoomLoadFailure.unknown;
      }
    }
    if (error is NetworkException) return _RoomLoadFailure.network;
    return _RoomLoadFailure.unknown;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final AsyncValue<RoomModel?> roomAsync = ref.watch(roomStreamProvider(widget.roomId));
    final AsyncValue<List<ParticipantModel>> participantsAsync =
        ref.watch(participantsStreamProvider(widget.roomId));

    ref.listen<AsyncValue<RoomModel?>>(roomStreamProvider(widget.roomId), _handleRoomUpdate);
    ref.listen<AsyncValue<List<MessageModel>>>(
      messagesStreamProvider(widget.roomId),
      _handleMessagesUpdate,
    );

    if (currentUser == null || (roomAsync.isLoading && !roomAsync.hasValue)) {
      return const Scaffold(
        backgroundColor: AppColors.videoPlayerBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.videoPlayerPrimary)),
      );
    }

    final RoomModel? room = roomAsync.valueOrNull;
    if (room == null) {
      final _RoomLoadFailure failure = _classifyRoomLoadFailure(roomAsync);

      final String title = switch (failure) {
        _RoomLoadFailure.notFound => l10n.roomUnavailableTitle,
        _RoomLoadFailure.permissionDenied => l10n.roomPermissionDeniedTitle,
        _RoomLoadFailure.network => l10n.roomNetworkErrorTitle,
        _RoomLoadFailure.unknown => l10n.roomUnknownErrorTitle,
      };
      final String message = switch (failure) {
        _RoomLoadFailure.notFound => l10n.roomUnavailableMessage,
        _RoomLoadFailure.permissionDenied => l10n.roomPermissionDeniedMessage,
        _RoomLoadFailure.network => l10n.roomNetworkErrorMessage,
        _RoomLoadFailure.unknown => l10n.roomUnknownErrorMessage,
      };
      final bool canRetry = failure != _RoomLoadFailure.notFound;

      return Scaffold(
        backgroundColor: AppColors.videoPlayerBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.back,
                          style: GoogleFonts.poppins(color: AppColors.videoPlayerSecondaryText)),
                    ),
                    if (canRetry) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(roomStreamProvider(widget.roomId)),
                        child: Text(l10n.retry,
                            style: GoogleFonts.poppins(
                                color: AppColors.videoPlayerPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<ParticipantModel> participants = participantsAsync.valueOrNull ?? const [];
    final List<ParticipantModel> mine =
        participants.where((p) => p.userId == currentUser.uid).toList();
    _myParticipantId = mine.isNotEmpty ? mine.first.id : null;
    if (!_micSeeded && mine.isNotEmpty) {
      _micSeeded = true;
      _isMicOn = !mine.first.isMuted;
    }

    final bool isHost = room.hostId == currentUser.uid;
    final bool canControl = isHost || room.allowScreenControl;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
  if (didPop) return;
  _handleLeavePressed();
},
      },
      child: Scaffold(
        backgroundColor: AppColors.videoPlayerBackground,
        body: SafeArea(
          child: Column(
            children: [
              VideoPlayerAppBar(
                title: room.title,
                isAdmin: isHost,
                memberCount: participants.length,
                maxParticipants: room.maxParticipants,
                onBackPressed: _handleLeavePressed,
                onLeavePressed: _handleLeavePressed,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleVideoAreaTap,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColors.videoPlayerBackground),
                      if (_videoStatus != _VideoLoadStatus.invalidUrl &&
                          _videoStatus != _VideoLoadStatus.error &&
                          _videoController != null &&
                          _videoController!.value.isInitialized)
                        Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      if (!_isAdShowing &&
                          (_videoStatus == _VideoLoadStatus.initializing ||
                              _videoStatus == _VideoLoadStatus.buffering))
                        const Center(
                          child: CircularProgressIndicator(color: AppColors.videoPlayerPrimary),
                        ),
                      if (!_isAdShowing &&
                          (_videoStatus == _VideoLoadStatus.invalidUrl ||
                              _videoStatus == _VideoLoadStatus.error))
                        VideoErrorOverlay(
                          kind: _videoStatus == _VideoLoadStatus.invalidUrl
                              ? VideoErrorKind.invalidUrl
                              : VideoErrorKind.playbackError,
                          onRetry: _retryVideo,
                        ),
                      SystemToastOverlay(toasts: _toasts),
                      if (_isAdShowing) const AdLoadingOverlay(),
                      if (!_isAdShowing && (_controlsVisible || _isLocked))
                        VideoControlsOverlay(
                          isPlaying: _isPlaying,
                          isLocked: _isLocked,
                          isFullscreen: _isFullscreen,
                          positionMs: _positionMs,
                          durationMs: _durationMs,
                          canControl: canControl,
                          onPlayPause: _handlePlayPause,
                          onReplay10: () => _handleSeekBy(-10000),
                          onForward10: () => _handleSeekBy(10000),
                          onPrevious: _handleComingSoon,
                          onNext: _handleComingSoon,
                          onSeek: _handleSeekTo,
                          onToggleLock: _handleToggleLock,
                          onToggleFullscreen: _handleToggleFullscreen,
                          onUnauthorizedTap: _handleUnauthorizedControlTap,
                        ),
                      if (!_isAdShowing && !_isLocked)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: VideoPlayerRightRail(
                            isMicOn: _isMicOn,
                            isSpeakerOn: _isSpeakerOn,
                            unreadChatCount: _unreadChatCount,
                            onToggleMic: _handleToggleMic,
                            onToggleSpeaker: _handleToggleSpeaker,
                            onOpenChat: _handleOpenChat,
                            onOpenParticipants: _handleOpenParticipants,
                          ),
                        ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        top: 0,
                        bottom: 0,
                        right: _chatOpen ? 0 : -_sidePanelWidth,
                        width: _sidePanelWidth,
                        child: IgnorePointer(
                          ignoring: !_chatOpen,
                          child: ChatPanel(
                            roomId: widget.roomId,
                            currentUserId: currentUser.uid,
                            currentUserName: currentUser.displayName ?? '',
                            currentUserPhotoUrl: currentUser.photoUrl,
                            onClose: () => setState(() => _chatOpen = false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
