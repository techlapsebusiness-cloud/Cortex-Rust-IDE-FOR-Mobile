import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drag_fx_controller.dart';
import 'hud_status_text.dart';
import 'painters/corner_brackets_painter.dart';
import 'painters/scan_grid_painter.dart';
import 'painters/targeting_reticle_painter.dart';
import 'particle_field.dart';
import '../theme/cortex_colors.dart';

/// Full-bleed JARVIS HUD over the drop surface. Never intercepts pointers.
class HudDropOverlay extends ConsumerStatefulWidget {
  const HudDropOverlay({super.key});

  @override
  ConsumerState<HudDropOverlay> createState() => _HudDropOverlayState();
}

class _HudDropOverlayState extends ConsumerState<HudDropOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _leave;
  late final AnimationController _rotation;
  late final AnimationController _sweep;
  late final AnimationController _shockwave;
  var _burstToken = 0;
  DragFxPhase _lastPhase = DragFxPhase.idle;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _leave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _shockwave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _leave.dispose();
    _rotation.dispose();
    _sweep.dispose();
    _shockwave.dispose();
    super.dispose();
  }

  void _syncPhase(DragFxPhase phase) {
    if (phase == _lastPhase) return;
    final previous = _lastPhase;
    _lastPhase = phase;

    void apply() {
      if (!mounted) return;
      switch (phase) {
        case DragFxPhase.idle:
          _enter.value = 0;
          _leave.value = 0;
          _shockwave.value = 0;
          _rotation.stop();
          _sweep.stop();
        case DragFxPhase.entering:
          _leave.value = 0;
          _enter.forward(from: 0);
          _rotation.repeat();
          _sweep.repeat();
        case DragFxPhase.tracking:
          if (_enter.value < 1) _enter.forward();
          if (!_rotation.isAnimating) _rotation.repeat();
          if (!_sweep.isAnimating) _sweep.repeat();
        case DragFxPhase.dropping:
          if (previous != DragFxPhase.dropping) {
            setState(() => _burstToken++);
          }
          _shockwave.forward(from: 0);
        case DragFxPhase.leaving:
          _leave.forward(from: 0);
          _rotation.stop();
          _sweep.stop();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => apply());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dragFxProvider);
    _syncPhase(state.phase);

    if (state.phase == DragFxPhase.idle) {
      return const SizedBox.shrink();
    }

    final leaveT = _leave.value;
    final enterT = _enter.value;
    final visibility = state.phase == DragFxPhase.leaving
        ? (1 - leaveT)
        : enterT.clamp(0.0, 1.0);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _enter,
              _leave,
              _rotation,
              _sweep,
              _shockwave,
              dragFxPointer,
            ]),
            builder: (context, _) {
              final v = state.phase == DragFxPhase.leaving
                  ? (1 - _leave.value)
                  : (state.phase == DragFxPhase.entering
                      ? _enter.value
                      : visibility.clamp(0.05, 1.0));
              final pointer = dragFxPointer.value;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Border bloom + scanline shimmer.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CortexColors.accent.withValues(alpha: 0.55 * v),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CortexColors.accent.withValues(alpha: 0.18 * v),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    painter: ScanGridPainter(
                      opacity: v,
                      sweepT: _sweep.value,
                    ),
                  ),
                  CustomPaint(
                    painter: CornerBracketsPainter(
                      progress: state.phase == DragFxPhase.leaving
                          ? (1 - _leave.value)
                          : _enter.value,
                    ),
                  ),
                  Positioned.fill(
                    child: ParticleField(
                      active: state.phase == DragFxPhase.tracking ||
                          state.phase == DragFxPhase.entering ||
                          state.phase == DragFxPhase.dropping,
                      pointer: pointer,
                      emitTrail: state.phase == DragFxPhase.tracking ||
                          state.phase == DragFxPhase.entering,
                      burstAt: state.dropPoint,
                      burstToken: _burstToken,
                    ),
                  ),
                  CustomPaint(
                    painter: TargetingReticlePainter(
                      pointer: pointer,
                      rotation: _rotation.value * 6.28318530718,
                      lockProgress: state.validTarget ? 1 : 0.35,
                      visible: state.phase != DragFxPhase.idle &&
                          state.phase != DragFxPhase.leaving,
                    ),
                  ),
                  if (state.phase == DragFxPhase.dropping)
                    CustomPaint(
                      painter: _ShockwavePainter(
                        center: state.dropPoint,
                        progress: _shockwave.value,
                      ),
                    ),
                  Align(
                    alignment: const Alignment(0, -0.82),
                    child: HudStatusText(
                      phase: state.phase,
                      validTarget: state.validTarget,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  _ShockwavePainter({required this.center, required this.progress});

  final Offset center;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final radius = 20 + 220 * t;
    final paint = Paint()
      ..color = CortexColors.accent.withValues(alpha: (1 - t) * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      center,
      radius * 0.65,
      paint..strokeWidth = 1.5 * (1 - t),
    );
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.progress != progress;
}
