import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/topic.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../../widgets/hud_brackets.dart';

/// Phase 1 stub — full TopicFeed lands in Phase 2.
class TopicFeedPlaceholder extends ConsumerWidget {
  const TopicFeedPlaceholder({
    super.key,
    this.showBack = false,
  });

  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(selectedTopicProvider);

    return topicAsync.when(
      loading: () => const Scaffold(
        backgroundColor: CortexColors.background,
        body: Center(
          child: CircularProgressIndicator(color: CortexColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: CortexColors.background,
        body: Center(
          child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
        ),
      ),
      data: (topic) {
        if (topic == null) {
          return Scaffold(
            backgroundColor: CortexColors.background,
            appBar: showBack ? AppBar() : null,
            body: Center(
              child: Text(
                'SELECT A TOPIC',
                style: CortexTheme.orbitron(
                  fontSize: 14,
                  color: CortexColors.muted,
                ),
              ),
            ),
          );
        }
        return _FeedShell(topic: topic, showBack: showBack);
      },
    );
  }
}

class _FeedShell extends StatelessWidget {
  const _FeedShell({required this.topic, required this.showBack});

  final Topic topic;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final accent = Color(topic.colorValue);
    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: HudBrackets(
          color: accent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              topic.title.toUpperCase(),
              style: CortexTheme.orbitron(fontSize: 14, color: CortexColors.text),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                painter: _ScanGridPainter(),
                child: const SizedBox(width: 220, height: 120),
              ),
              const SizedBox(height: 20),
              Text(
                'FEED ONLINE — PHASE 2',
                style: CortexTheme.orbitron(
                  fontSize: 13,
                  color: CortexColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share or drag research here.',
                style: CortexTheme.body(color: CortexColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    const step = 16.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final border = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(8),
      ),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
