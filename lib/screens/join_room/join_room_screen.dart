import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/repository_providers.dart';
import '../room_details/room_details_args.dart';

/// Join Room (Phase 4) — join an existing room by its unique room code
/// only, per spec ("Room Code فقط, لا تطلب اسم الغرفة"). A private
/// room's optional passcode (already modeled by [RoomModel.passcode])
/// is asked for inline, only once a matching room is found and turns
/// out to require one.
///
/// Uses [RoomRepository.joinRoom] directly (not the review-first
/// [RoomRepository.requestToJoin] the Home screen's Public Rooms list
/// uses) since arriving here with a code already implies the sharer's
/// consent — the same direct-join path invited friends use.
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  String? _errorText;
  RoomModel? _pendingPrivateRoom;

  @override
  void dispose() {
    _codeController.dispose();
    _passcodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = l10n.joinRoomCodeRequiredError);
      return;
    }

    final UserModel? currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final roomRepository = ref.read(roomRepositoryProvider);
      final RoomModel? room = _pendingPrivateRoom ?? await roomRepository.getRoom(code);

      if (room == null) {
        setState(() {
          _isLoading = false;
          _errorText = l10n.joinRoomNotFoundError;
        });
        return;
      }

      if (room.status == RoomStatus.ended) {
        setState(() {
          _isLoading = false;
          _errorText = l10n.joinRoomEndedError;
        });
        return;
      }

      if (room.isFull) {
        setState(() {
          _isLoading = false;
          _errorText = l10n.joinRoomFullError;
        });
        return;
      }

      final bool alreadyJoined = room.participantIds.contains(currentUser.uid);

      if (!alreadyJoined && room.isPrivate && (room.passcode ?? '').isNotEmpty) {
        if (_pendingPrivateRoom == null) {
          // First pass: we now know this room needs a passcode — reveal
          // the field and stop, rather than joining/erroring yet.
          setState(() {
            _isLoading = false;
            _pendingPrivateRoom = room;
          });
          return;
        }
        if (_passcodeController.text.trim() != room.passcode) {
          setState(() {
            _isLoading = false;
            _errorText = l10n.joinRoomWrongPasscodeError;
          });
          return;
        }
      }

      if (!alreadyJoined) {
        await roomRepository.joinRoom(
          roomId: room.id,
          userId: currentUser.uid,
          displayName: currentUser.displayName ?? currentUser.email,
          photoUrl: currentUser.photoUrl,
        );
      }

      final hostUser = await ref.read(userRepositoryProvider).getUser(room.hostId);
      if (!mounted) return;
      context.pushReplacement(
        RouteNames.roomDetailsPath(room.id),
        extra: RoomDetailsArgs(room: room, host: hostUser ?? currentUser, participants: const []),
      );
    } on AppException catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorText = l10n.somethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool needsPasscode = _pendingPrivateRoom != null;

    return Scaffold(
      backgroundColor: AppColors.createRoomBackground,
      appBar: AppBar(
        backgroundColor: AppColors.createRoomBackground,
        elevation: 0,
        title: Text(
          l10n.joinRoomTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.createRoomPrimary, AppColors.createRoomPrimaryHover],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.joinRoomSubtitle,
                style: GoogleFonts.poppins(fontSize: 15, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.joinRoomCodeLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                focusNode: _focusNode,
                enabled: !needsPasscode,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16),
                onChanged: (_) {
                  if (_pendingPrivateRoom != null || _errorText != null) {
                    setState(() {
                      _pendingPrivateRoom = null;
                      _errorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.joinRoomCodeHint,
                  hintStyle: GoogleFonts.poppins(color: AppColors.createRoomBorder),
                  filled: true,
                  fillColor: AppColors.createRoomCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.createRoomBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.createRoomBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.createRoomPrimary),
                  ),
                ),
              ),
              if (needsPasscode) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.joinRoomPasscodeLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passcodeController,
                  obscureText: true,
                  autofocus: true,
                  style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.joinRoomPasscodeHint,
                    hintStyle: GoogleFonts.poppins(color: AppColors.createRoomBorder),
                    filled: true,
                    fillColor: AppColors.createRoomCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.createRoomBorder),
                    ),
                  ),
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.createRoomPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          needsPasscode ? l10n.joinRoomUnlockButton : l10n.joinRoomJoinButton,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
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
