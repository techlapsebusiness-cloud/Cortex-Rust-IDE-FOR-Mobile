import 'package:flutter/material.dart';

import '../theme/cortex_colors.dart';
import '../theme/cortex_theme.dart';
import 'drag_fx_controller.dart';

class HudStatusText extends StatelessWidget {
  const HudStatusText({
    super.key,
    required this.phase,
    required this.validTarget,
  });

  final DragFxPhase phase;
  final bool validTarget;

  String get _label => switch (phase) {
        DragFxPhase.idle => '',
        DragFxPhase.entering => 'ACQUIRING TARGET',
        DragFxPhase.tracking =>
          validTarget ? 'DROP TO CAPTURE' : 'ACQUIRING TARGET',
        DragFxPhase.dropping => 'TARGET ACQUIRED',
        DragFxPhase.leaving => 'SIGNAL LOST',
      };

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label.isEmpty) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: phase == DragFxPhase.leaving ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: CortexTheme.orbitron(
          fontSize: 11,
          color: CortexColors.accent,
          letterSpacing: 2.4,
        ),
      ),
    );
  }
}
