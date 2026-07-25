import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

/// Phase 7 lands full Settings.
class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('SYSTEM', style: CortexTheme.orbitron(fontSize: 12, color: CortexColors.muted)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Local-first', style: CortexTheme.body()),
            subtitle: Text(
              'All data stays on device. No cloud in v1.',
              style: CortexTheme.mono(fontSize: 11),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Target', style: CortexTheme.body()),
            subtitle: Text(
              'Samsung Galaxy Z Fold 6 · Android 13+',
              style: CortexTheme.mono(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}