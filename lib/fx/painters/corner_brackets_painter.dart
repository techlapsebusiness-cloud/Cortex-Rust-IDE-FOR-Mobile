import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';

/// Four L-brackets that snap inward from the edges (`progress` 0→1).
class CornerBracketsPainter extends CustomPainter {
  CornerBracketsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutExpo.transform(progress.clamp(0.0, 1.0));
    const arm = 28.0;
    const stroke = 1.5;
    // Start further inset-out; ease to a stable margin.
    final inset = lerpDouble(48, 10, t)!;

    final paint = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.25 + 0.75 * t)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;

    final glow = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.35 * t)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    void bracket(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * arm, origin.dy)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx, origin.dy + dy * arm);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);
    }

    bracket(Offset(inset, inset), 1, 1);
    bracket(Offset(size.width - inset, inset), -1, 1);
    bracket(Offset(inset, size.height - inset), 1, -1);
    bracket(Offset(size.width - inset, size.height - inset), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CornerBracketsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
