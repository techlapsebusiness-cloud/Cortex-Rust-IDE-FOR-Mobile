import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';

class TargetingReticlePainter extends CustomPainter {
  TargetingReticlePainter({
    required this.pointer,
    required this.rotation,
    required this.lockProgress,
    required this.visible,
  });

  final Offset pointer;
  final double rotation;
  final double lockProgress;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final c = pointer;

    const radius = 46.0;
    final cyan = CortexColors.accent;

    final glow = Paint()
      ..color = cyan.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final stroke = Paint()
      ..color = cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(c, radius, glow);
    canvas.drawCircle(c, radius, stroke);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2;
      final tick = i % 3 == 0 ? 8.0 : 4.0;
      final outer = Offset(math.cos(a) * radius, math.sin(a) * radius);
      final inner = Offset(
        math.cos(a) * (radius - tick),
        math.sin(a) * (radius - tick),
      );
      canvas.drawLine(inner, outer, stroke);
    }
    canvas.restore();

    const gap = 8.0;
    const arm = 18.0;
    canvas.drawLine(Offset(c.dx - arm, c.dy), Offset(c.dx - gap, c.dy), stroke);
    canvas.drawLine(Offset(c.dx + gap, c.dy), Offset(c.dx + arm, c.dy), stroke);
    canvas.drawLine(Offset(c.dx, c.dy - arm), Offset(c.dx, c.dy - gap), stroke);
    canvas.drawLine(Offset(c.dx, c.dy + gap), Offset(c.dx, c.dy + arm), stroke);

    final lock = Curves.easeOut.transform(lockProgress.clamp(0.0, 1.0));
    final half = lerpDouble(28, 10, lock)!;
    canvas.drawRect(
      Rect.fromCenter(center: c, width: half * 2, height: half * 2),
      stroke,
    );

    final heat = Paint()
      ..shader = RadialGradient(
        colors: [
          cyan.withValues(alpha: 0.22),
          cyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: 40));
    canvas.drawCircle(c, 40, heat);

    final range =
        'X ${c.dx.toStringAsFixed(0)}  Y ${c.dy.toStringAsFixed(0)}';
    final tp = TextPainter(
      text: TextSpan(
        text: range,
        style: TextStyle(
          color: cyan.withValues(alpha: 0.85),
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy + radius + 8));
  }

  @override
  bool shouldRepaint(covariant TargetingReticlePainter oldDelegate) =>
      oldDelegate.pointer != pointer ||
      oldDelegate.rotation != rotation ||
      oldDelegate.lockProgress != lockProgress ||
      oldDelegate.visible != visible;
}
