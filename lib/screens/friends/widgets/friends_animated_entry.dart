import 'package:flutter/material.dart';

/// Wraps [child] in the spec's card entrance animation — fade + slide up,
/// 250ms — with an optional per-index stagger so a list of cards cascades
/// in rather than popping together.
class FriendsAnimatedEntry extends StatefulWidget {
  const FriendsAnimatedEntry({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<FriendsAnimatedEntry> createState() => _FriendsAnimatedEntryState();
}

class _FriendsAnimatedEntryState extends State<FriendsAnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final int clampedIndex = widget.index.clamp(0, 12);
    Future.delayed(Duration(milliseconds: 30 * clampedIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// A tap target that scales to 0.96 over 120ms while pressed — the
/// spec's standard button-press feedback, reused for every tappable
/// affordance on this screen (chips, buttons, cards).
class FriendsPressableScale extends StatefulWidget {
  const FriendsPressableScale({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<FriendsPressableScale> createState() => _FriendsPressableScaleState();
}

class _FriendsPressableScaleState extends State<FriendsPressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
