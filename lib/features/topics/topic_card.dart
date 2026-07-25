import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/topic.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.itemCount,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final Topic topic;
  final int itemCount;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = Color(widget.topic.colorValue);
    final glow = widget.selected || _pressed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: CortexColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glow ? accent.withValues(alpha: 0.55) : CortexColors.hairline,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Row(
            children: [
              Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CortexTheme.orbitron(
                          fontSize: 13,
                          color: CortexColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.itemCount} ITEM${widget.itemCount == 1 ? '' : 'S'}',
                        style: CortexTheme.mono(fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatUpdated(widget.topic.updatedAt),
                        style: CortexTheme.mono(
                          fontSize: 11,
                          color: CortexColors.muted.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'JUST NOW';
    if (diff.inHours < 1) return '${diff.inMinutes}M AGO';
    if (diff.inDays < 1) return '${diff.inHours}H AGO';
    if (diff.inDays < 7) return '${diff.inDays}D AGO';
    return DateFormat('MMM d').format(dt).toUpperCase();
  }
}
