import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/message_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/room_stream_providers.dart';

/// The single in-room chat panel (per spec, there's only ever one —
/// no separate DM/second chat surface). Real send/receive via
/// [MessageRepository]; "system" messages (join/leave) are filtered out
/// here since those are the toast overlay's job, not the chat log's.
class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserPhotoUrl,
    required this.onClose,
  });

  final String roomId;
  final String currentUserId;
  final String currentUserName;
  final String? currentUserPhotoUrl;
  final VoidCallback onClose;

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _inputController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final String text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _inputController.clear();
    try {
      await ref.read(messageRepositoryProvider).sendMessage(
            roomId: widget.roomId,
            senderId: widget.currentUserId,
            senderName: widget.currentUserName,
            senderPhotoUrl: widget.currentUserPhotoUrl,
            content: text,
          );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _insertEmoji(String emoji) {
    final int cursor = _inputController.selection.baseOffset;
    final String current = _inputController.text;
    final int insertAt = cursor >= 0 ? cursor : current.length;
    final String updated = current.replaceRange(insertAt, insertAt, emoji);
    _inputController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: insertAt + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<MessageModel>> messagesAsync =
        ref.watch(messagesStreamProvider(widget.roomId));

    return Material(
      color: AppColors.videoPlayerCard,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Text(
                    l10n.chatLabel,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded, color: AppColors.videoPlayerSecondaryText),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.videoPlayerBorder, height: 1),
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.videoPlayerPrimary),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    l10n.chatEmptyMessage,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                  ),
                ),
                data: (messages) {
                  final List<MessageModel> visible = messages
                      .where((m) => !m.isDeleted && m.type != MessageType.system)
                      .toList();

                  if (visible.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.chatEmptyMessage,
                        style:
                            GoogleFonts.poppins(fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final message = visible[index];
                      final bool isMine = message.senderId == widget.currentUserId;
                      return _MessageBubble(message: message, isMine: isMine);
                    },
                  );
                },
              ),
            ),
            const Divider(color: AppColors.videoPlayerBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _insertEmoji('😀'),
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: AppColors.videoPlayerSecondaryText),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: l10n.chatInputHint,
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.videoPlayerSecondaryText),
                        filled: true,
                        fillColor: AppColors.videoPlayerBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.videoPlayerBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.videoPlayerBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.videoPlayerPrimary),
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: l10n.chatSendSemanticLabel,
                    child: IconButton(
                      onPressed: _sending ? null : _handleSend,
                      icon: const Icon(Icons.send_rounded, color: AppColors.videoPlayerPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final MessageModel message;
  final bool isMine;

  String get _time {
    final DateTime t = message.createdAt;
    final String hh = t.hour.toString().padLeft(2, '0');
    final String mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 240),
        decoration: BoxDecoration(
          color: isMine ? AppColors.videoPlayerPrimary : AppColors.videoPlayerBackground,
          borderRadius: BorderRadius.circular(14),
          border: isMine ? null : Border.all(color: AppColors.videoPlayerBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.videoPlayerPrimary,
                  ),
                ),
              ),
            Text(
              message.content,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.white),
            ),
            const SizedBox(height: 2),
            Text(
              _time,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: isMine ? AppColors.white.withOpacity(0.7) : AppColors.videoPlayerSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
