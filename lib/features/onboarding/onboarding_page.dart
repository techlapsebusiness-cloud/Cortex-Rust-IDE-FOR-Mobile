import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CortexColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CORTEX',
                style: CortexTheme.orbitron(
                  fontSize: 28,
                  color: CortexColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Research capture for the Fold',
                style: CortexTheme.body(color: CortexColors.muted),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: ListView(
                  children: [
                    _Step(
                      index: '01',
                      title: 'APP PAIR',
                      body:
                          'Open Chrome and CORTEX in split-screen on the inner display → tap the divider handle → tap the ⭐/App-Pair icon to save the pair to the Edge panel. After that, one tap opens Chrome + CORTEX side-by-side. Research on the left, drag or Share into CORTEX on the right.',
                    ),
                    const SizedBox(height: 24),
                    _Step(
                      index: '02',
                      title: 'CAPTURE',
                      body:
                          'Share text, links, images, or files from any app into CORTEX — or drag across the split-screen divider onto a project stage for instant quick-add.',
                    ),
                    const SizedBox(height: 24),
                    _Step(
                      index: '03',
                      title: 'ORGANIZE',
                      body:
                          'Everything lands in research projects with scientific-method stages. Add notes and tags, track claims and evidence, search offline, and keep the real browser where it belongs — Chrome.',
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () async {
                  final repo = ref.read(settingsRepositoryProvider).valueOrNull;
                  await repo?.setOnboardingDone(true);
                  ref.invalidate(sharedPrefsProvider);
                  onDone();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: CortexColors.accent,
                  foregroundColor: CortexColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'ENTER CORTEX',
                  style: CortexTheme.orbitron(
                    fontSize: 13,
                    color: CortexColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.title,
    required this.body,
  });

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$index  $title',
          style: CortexTheme.orbitron(fontSize: 13, color: CortexColors.accent),
        ),
        const SizedBox(height: 10),
        Text(body, style: CortexTheme.body(fontSize: 14)),
      ],
    );
  }
}
