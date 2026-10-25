import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/cortex_colors.dart';

/// Assembles a freshly captured card: border trace → wipe → glitch settle.
class MaterializeCard extends StatelessWidget {
  const MaterializeCard({
    super.key,
    required this.child,
    this.enabled = true,
    this.onComplete,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return ClipRect(
      child: child
          .animate(
            onComplete: (controller) => onComplete?.call(),
          )
          .custom(
            duration: 260.ms,
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return BorderTracer(progress: value, child: child);
            },
          )
          .then()
          .fadeIn(duration: 120.ms)
          .shimmer(
            duration: 500.ms,
            color: CortexColors.accent.withValues(alpha: 0.6),
          )
          .then()
          .shake(hz: 6, duration: 120.ms, offset: const Offset(1.5, 0)),
    );
  }
}

class BorderTracer extends StatelessWidget {
  const BorderTracer({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BorderTracePainter(progress: progress),
      child: child,
    );
  }
}

class _BorderTracePainter extends CustomPainter {
  _BorderTracePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final len = metric.length * t;
    final extract = metric.extractPath(0, len);

    final glow = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final stroke = Paint()
      ..color = CortexColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(extract, glow);
    canvas.drawPath(extract, stroke);

    // Cyan wipe fill while tracing.
    if (t > 0.15) {
      final wipe = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
      final clipH = size.height * wipe;
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, clipH));
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = CortexColors.accent.withValues(alpha: 0.08)
          ..blendMode = BlendMode.plus,
      );
      // Scanline band at wipe edge.
      canvas.drawRect(
        Rect.fromLTWH(0, math.max(0, clipH - 3), size.width, 3),
        Paint()
          ..color = CortexColors.accent.withValues(alpha: 0.55)
          ..blendMode = BlendMode.plus,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BorderTracePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
