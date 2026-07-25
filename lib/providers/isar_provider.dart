import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/isar_service.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  return IsarService.open();
});
