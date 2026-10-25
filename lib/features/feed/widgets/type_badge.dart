import 'package:flutter/material.dart';

import '../../../data/models/research_enums.dart';
import '../../../theme/cortex_colors.dart';
import '../../../theme/cortex_theme.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final ItemType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: CortexColors.elevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: CortexColors.hairline),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: CortexTheme.mono(fontSize: 10, color: CortexColors.accent),
      ),
    );
  }
}
