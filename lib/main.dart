import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/isar_service.dart';
import 'providers/isar_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // High refresh rate on Fold panel (§9). Best-effort; ignore failures on emulators.
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {}

  final isar = await IsarService.open();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const CortexApp(),
    ),
  );
}
