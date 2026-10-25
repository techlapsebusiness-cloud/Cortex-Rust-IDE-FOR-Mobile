import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

/// Single Isar instance — overridden in [main] after [IsarService.open].
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden in main() with a single Isar instance',
  );
});
