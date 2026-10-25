import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/claim.dart';
import 'models/project.dart';
import 'models/research_item.dart';

class IsarService {
  IsarService._();

  static const _name = 'cortex';

  /// Open the single CORTEX database. Call once from [main].
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await Isar.open(
        [ProjectSchema, ClaimSchema, ResearchItemSchema],
        directory: dir.path,
        name: _name,
      );
    } catch (e) {
      // Local-dev schema rename Topic→Project: wipe and reopen.
      await _wipeDb(dir.path);
      return Isar.open(
        [ProjectSchema, ClaimSchema, ResearchItemSchema],
        directory: dir.path,
        name: _name,
      );
    }
  }

  static Future<void> _wipeDb(String directory) async {
    try {
      await Isar.getInstance(_name)?.close(deleteFromDisk: true);
    } catch (_) {}
    for (final f in [
      File(p.join(directory, '$_name.isar')),
      File(p.join(directory, '$_name.isar.lock')),
    ]) {
      if (await f.exists()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }
  }
}
