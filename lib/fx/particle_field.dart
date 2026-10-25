import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/cortex_colors.dart';

class _Particle {
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double life = 0;
  double maxLife = 0.5;
  double size = 2;

  bool get alive => life > 0;

  void resetTrail(Offset at, math.Random rng) {
    pos = at;
    vel = Offset(
      (rng.nextDouble() - 0.5) * 40,
      (rng.nextDouble() - 0.5) * 40 - 20,
    );
    maxLife = 0.35 + rng.nextDouble() * 0.25;
    life = maxLife;
    size = 1.5 + rng.nextDouble() * 2;
  }

  void resetBurst(Offset at, math.Random rng) {
    pos = at;
    final a = rng.nextDouble() * math.pi * 2;
    final speed = 80 + rng.nextDouble() * 160;
    vel = Offset(math.cos(a) * speed, math.sin(a) * speed);
    maxLife = 0.35 + rng.nextDouble() * 0.25;
    life = maxLife;
    size = 2 + rng.nextDouble() * 2.5;
  }

  void tick(double dt) {
    if (!alive) return;
    life -= dt;
    pos += vel * dt;
    vel *= 0.92;
  }
}

/// Cap-pooled particle trail + burst. Ticker stops when idle.
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    required this.active,
    required this.pointer,
    required this.emitTrail,
    required this.burstAt,
    this.burstToken = 0,
  });

  final bool active;
  final Offset pointer;
  final bool emitTrail;
  final Offset burstAt;
  final int burstToken;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  static const _cap = 120;
  final _pool = List.generate(_cap, (_) => _Particle());
  final _rng = math.Random();
  Ticker? _ticker;
  Duration _last = Duration.zero;
  var _emitAcc = 0.0;
  var _lastBurstToken = 0;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ParticleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.burstToken != _lastBurstToken && widget.burstToken != 0) {
      _lastBurstToken = widget.burstToken;
      _burst(widget.burstAt);
    }
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }

  void _syncTicker() {
    final need = widget.active || _anyAlive();
    if (need) {
      _ticker ??= createTicker(_onTick)..start();
      if (!(_ticker!.isActive)) _ticker!.start();
    } else {
      _ticker?.stop();
      _last = Duration.zero;
    }
  }

  bool _anyAlive() {
    for (final p in _pool) {
      if (p.alive) return true;
    }
    return false;
  }

  _Particle? _acquire() {
    for (final p in _pool) {
      if (!p.alive) return p;
    }
    return null;
  }

  void _burst(Offset at) {
    for (var i = 0; i < 24; i++) {
      _acquire()?.resetBurst(at, _rng);
    }
    _syncTicker();
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final clamped = dt.clamp(0.0, 0.033);

    if (widget.active && widget.emitTrail) {
      _emitAcc += clamped;
      while (_emitAcc >= 1 / 90) {
        _emitAcc -= 1 / 90;
        _acquire()?.resetTrail(widget.pointer, _rng);
        _acquire()?.resetTrail(widget.pointer, _rng);
      }
    }

    for (final p in _pool) {
      p.tick(clamped);
    }

    if (mounted) setState(() {});
    if (!widget.active && !_anyAlive()) {
      _ticker?.stop();
      _last = Duration.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(particles: _pool),
      size: Size.infinite,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles});

  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;
    for (final p in particles) {
      if (!p.alive) continue;
      final t = (p.life / p.maxLife).clamp(0.0, 1.0);
      paint.color = Color.lerp(
        Colors.white,
        CortexColors.accent,
        1 - t,
      )!.withValues(alpha: 0.15 + 0.7 * t);
      canvas.drawCircle(p.pos, p.size * t, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
