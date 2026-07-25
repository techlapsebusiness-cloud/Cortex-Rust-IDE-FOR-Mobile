import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

/// Phase 6 lands full GlobalSearch.
class SearchPlaceholder extends StatelessWidget {
  const SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'SEARCH',
          style: CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
        ),
      ),
      body: Center(
        child: Text(
          'GLOBAL SEARCH — PHASE 6',
          style: CortexTheme.mono(color: CortexColors.muted),
        ),
      ),
    );
  }
}
