import 'package:flutter/material.dart';

/// Cross-fades [child] whenever [switchKey] changes.
///
/// A thin, named wrapper around [AnimatedSwitcher] so call sites read as
/// intent ("fade this when the language changes") rather than
/// `AnimatedSwitcher` boilerplate repeated at every text widget. First
/// used to satisfy the 150ms fade the language selector requires when
/// switching locale, without touching PageView/animation state elsewhere
/// on the screen — reusable anywhere else a keyed value should cross-fade
/// its display.
class FadeSwitcher extends StatelessWidget {
  const FadeSwitcher({
    super.key,
    required this.switchKey,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
  });

  final Object switchKey;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(key: ValueKey(switchKey), child: child),
    );
  }
}
