import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.itemCount,
    required this.occupiedStages,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final Project project;
  final int itemCount;
  final Set<ResearchStage> occupiedStages;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = Color(widget.project.colorValue);
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
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
                          widget.project.title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CortexTheme.orbitron(
                            fontSize: 13,
                            color: CortexColors.text,
                          ),
                        ),
                        if (widget.project.researchQuestion.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.project.researchQuestion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CortexTheme.mono(
                              fontSize: 11,
                              color: CortexColors.muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _StageDots(
                          occupied: widget.occupiedStages,
                          accent: accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.itemCount} ITEM${widget.itemCount == 1 ? '' : 'S'}',
                          style: CortexTheme.mono(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatUpdated(widget.project.updatedAt),
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

class _StageDots extends StatelessWidget {
  const _StageDots({required this.occupied, required this.accent});

  final Set<ResearchStage> occupied;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final stage in ResearchStage.values)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: stage.label,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: occupied.contains(stage)
                      ? accent
                      : CortexColors.elevated,
                  border: Border.all(
                    color: occupied.contains(stage)
                        ? accent.withValues(alpha: 0.8)
                        : CortexColors.hairline,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
