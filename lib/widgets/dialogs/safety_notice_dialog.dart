import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/generated/app_localizations.dart';

/// The community safety notice shown exactly once, right before a user
/// reaches Home for the first time (see `core/utils/home_navigation.dart`
/// for the gate that decides when to show this).
///
/// Non-dismissible by design, per spec: no back button, no swipe, no
/// tap-outside — [show] uses `barrierDismissible: false` and wraps the
/// content in [PopScope] with `canPop: false`. The only way out is the
/// accept button, which pops `true`.
class SafetyNoticeDialog extends StatelessWidget {
  const SafetyNoticeDialog({super.key});

  static const Color _dialogBackground = Color(0xFF12121A);
  static const Color _borderColor = Color(0x408B5CF6); // #8B5CF6 @ 25%
  static const Color _bodyTextColor = Color(0xFFD1D5DB);
  static const Color _iconBackground = Color(0x26F59E0B); // orange @ 15%
  static const Color _iconColor = Color(0xFFF59E0B);
  static const double _maxWidth = 420;
  static const double _radius = 26;

  /// Shows the dialog and resolves to `true` once the user accepts.
  /// Never resolves to `false`/`null` through normal use, since there's
  /// no dismiss path other than accepting — callers can still treat any
  /// non-`true` result defensively.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xCC050507), // spec background, translucent
      builder: (context) => const PopScope(
        canPop: false,
        child: SafetyNoticeDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dialogWidth = (screenWidth * 0.9).clamp(0, _maxWidth).toDouble();

    return Semantics(
      label: l10n.safetyNoticeSemanticLabel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _dialogBackground,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x668B5CF6), // large soft purple glow
                blurRadius: 48,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WarningIcon(background: _iconBackground, color: _iconColor),
              const SizedBox(height: 20),
              Text(
                l10n.safetyNoticeTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.safetyNoticeBody,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _bodyTextColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              _AcceptButton(
                label: l10n.safetyNoticeAcceptButton,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon({required this.background, required this.color});

  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(Icons.gpp_maybe_rounded, size: 38, color: color),
    );
  }
}

/// The gradient accept button with a 120ms scale-down-on-press, per
/// spec — built as its own small widget rather than reusing
/// `PrimaryButton`, since that press-scale behavior is unique to this
/// dialog and not (yet) part of the shared button's API.
class _AcceptButton extends StatefulWidget {
  const _AcceptButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_AcceptButton> createState() => _AcceptButtonState();
}

class _AcceptButtonState extends State<_AcceptButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  static const Duration _duration = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration, value: 1);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(18));

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: Ink(
              decoration: const BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
              ),
              child: InkWell(
                borderRadius: borderRadius,
                onTap: widget.onPressed,
                child: Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
