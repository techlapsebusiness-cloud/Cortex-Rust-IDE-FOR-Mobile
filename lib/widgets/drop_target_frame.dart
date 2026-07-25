import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/cortex_colors.dart';

/// Cyan pulse overlay while a drag hovers a drop target (§6).
///
/// Drawn as an [IgnorePointer] overlay so hover animation never rebuilds or
/// re-parents [child] (avoids semantics/parentData asserts mid-drag).
class DropTargetFrame extends StatefulWidget {
  const DropTargetFrame({
    super.key,
    required this.activeListenable,
    required this.child,
    this.borderRadius = 0,
  });

  final ValueListenable<bool> activeListenable;
  final Widget child;
  final double borderRadius;

  @override
  State<DropTargetFrame> createState() => _DropTargetFrameState();
}

class _DropTargetFrameState extends State<DropTargetFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    widget.activeListenable.addListener(_syncAnimation);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant DropTargetFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeListenable != widget.activeListenable) {
      oldWidget.activeListenable.removeListener(_syncAnimation);
      widget.activeListenable.addListener(_syncAnimation);
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    widget.activeListenable.removeListener(_syncAnimation);
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final active = widget.activeListenable.value;
    if (active) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (_controller.isAnimating || _controller.value != 0) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _controller,
                  widget.activeListenable,
                ]),
                builder: (context, _) {
                  if (!widget.activeListenable.value) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: _PulseBorderPainter(
                      progress: _controller.value,
                      borderRadius: widget.borderRadius,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseBorderPainter extends CustomPainter {
  _PulseBorderPainter({
    required this.progress,
    required this.borderRadius,
  });

  final double progress;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOut.transform(progress);
    final alpha = 0.25 + (0.7 * t);
    final rect = Offset.zero & size;
    final rrect = borderRadius > 0
        ? RRect.fromRectAndRadius(
            rect.deflate(1),
            Radius.circular(borderRadius),
          )
        : RRect.fromRectAndRadius(rect.deflate(1), Radius.zero);

    final glow = Paint()
      ..color = CortexColors.accent.withValues(alpha: alpha * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(rrect, glow);

    final border = Paint()
      ..color = CortexColors.accent.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, border);
  }

  @override
  bool shouldRepaint(covariant _PulseBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.borderRadius != borderRadius;
}
