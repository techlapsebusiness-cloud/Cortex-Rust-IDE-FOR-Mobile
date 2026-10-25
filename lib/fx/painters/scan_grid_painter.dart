import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';

/// Flat cyan grid + top→bottom sweep line.
class ScanGridPainter extends CustomPainter {
  ScanGridPainter({
    required this.opacity,
    required this.sweepT,
  });

  final double opacity;
  final double sweepT;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final grid = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.12 * opacity)
      ..strokeWidth = 1;

    const step = 24.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Faint hex-ish diagonals for depth without true perspective cost.
    final diag = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.04 * opacity)
      ..strokeWidth = 1;
    for (var i = -size.height; i < size.width; i += step * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        diag,
      );
    }

    final y = sweepT.clamp(0.0, 1.0) * size.height;
    final sweepGlow = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.35 * opacity)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..blendMode = BlendMode.plus;
    final sweep = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.85 * opacity)
      ..strokeWidth = 3
      ..blendMode = BlendMode.plus;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), sweepGlow);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), sweep);
  }

  @override
  bool shouldRepaint(covariant ScanGridPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.sweepT != sweepT;
}
