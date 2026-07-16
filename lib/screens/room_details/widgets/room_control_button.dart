import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// A 64×64dp circular control button (Voice Chat / Chat / Leave Room)
/// with its own label underneath and a 200ms scale-down-on-press
/// animation.
class RoomControlButton extends StatefulWidget {
  const RoomControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.roomCard,
    this.iconColor = AppColors.white,
    this.isActive = false,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  /// Highlights the button (e.g. voice chat currently enabled) with a
  /// primary-colored ring, without changing its base [backgroundColor].
  final bool isActive;

  final String? semanticLabel;

  static const double _size = 64;

  @override
  State<RoomControlButton> createState() => _RoomControlButtonState();
}

class _RoomControlButtonState extends State<RoomControlButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration, value: 1);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) => _controller.reverse();
  void _handleTapUp(TapUpDetails details) => _controller.forward();
  void _handleTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: widget.semanticLabel ?? widget.label,
          selected: widget.isActive,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: RoomControlButton._size,
                height: RoomControlButton._size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor,
                  border: Border.all(
                    color: widget.isActive ? AppColors.primary : AppColors.roomBorder,
                    width: widget.isActive ? 2 : 1,
                  ),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
