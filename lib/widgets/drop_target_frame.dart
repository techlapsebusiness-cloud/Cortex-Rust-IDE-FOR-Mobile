import 'package:flutter/material.dart';

import '../theme/cortex_colors.dart';

/// Animated cyan pulse border while a drag hovers a drop target (§6).
class DropTargetFrame extends StatefulWidget {
  const DropTargetFrame({
    super.key,
    required this.active,
    required this.child,
    this.borderRadius = 0,
  });

  final bool active;
  final Widget child;
  final double borderRadius;

  @override
  State<DropTargetFrame> createState() => _DropTargetFrameState();
}

class _DropTargetFrameState extends State<DropTargetFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(begin: 0.25, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant DropTargetFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final alpha = widget.active ? _pulse.value : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius > 0
                ? BorderRadius.circular(widget.borderRadius)
                : null,
            // Keep a constant border width so hover pulse never relayouts
            // children (avoids `_debugDoingThisLayout` crashes mid-drop).
            border: Border.all(
              color: CortexColors.accent.withValues(alpha: alpha),
              width: 2,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: CortexColors.accent.withValues(alpha: alpha * 0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
