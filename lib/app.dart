import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/capture/share_intent_listener.dart';
import 'features/home/home_shell.dart';
import 'providers/isar_provider.dart';
import 'theme/cortex_colors.dart';
import 'theme/cortex_theme.dart';

final cortexNavigatorKey = GlobalKey<NavigatorState>();

class CortexApp extends ConsumerWidget {
  const CortexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);

    return ShareIntentListener(
      navigatorKey: cortexNavigatorKey,
      child: MaterialApp(
        title: 'CORTEX',
        debugShowCheckedModeBanner: false,
        theme: CortexTheme.dark(),
        navigatorKey: cortexNavigatorKey,
        home: isar.when(
          loading: () => const _BootScreen(),
          error: (e, _) => _BootScreen(error: '$e'),
          data: (_) => const HomeShell(),
        ),
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CortexColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CORTEX',
              style: CortexTheme.orbitron(
                fontSize: 28,
                color: CortexColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: CortexTheme.mono(color: CortexColors.danger),
                ),
              )
            else
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CortexColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
