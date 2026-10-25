import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../file_storage.dart';
import '../models/research_item.dart';

/// Generates a local thumbnail for captured video files (§5).
/// Stored on [ResearchItem.previewImageUrl] (schema has no separate thumb field).
class VideoThumbService {
  VideoThumbService._();

  static const _uuid = Uuid();

  static Future<void> generate(ResearchItem item, Isar isar) async {
    final rel = item.fileRelPath;
    if (rel == null || rel.isEmpty) return;

    try {
      final abs = await FileStorage.absoluteFromRelative(rel);
      if (!File(abs).existsSync()) return;

      final bytes = await VideoThumbnail.thumbnailData(
        video: abs,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );
      if (bytes == null || bytes.isEmpty) return;

      final docs = await FileStorage.docsDir();
      final thumbRel =
          p.join('cortex', 'thumbs', '${_uuid.v4()}.jpg').replaceAll('\\', '/');
      final dest = File(p.join(docs.path, thumbRel));
      await dest.parent.create(recursive: true);
      await dest.writeAsBytes(bytes, flush: true);

      final fresh = await isar.researchItems.get(item.id);
      if (fresh == null) return;
      fresh.previewImageUrl = thumbRel;

      await isar.writeTxn(() async {
        await isar.researchItems.put(fresh);
      });
    } catch (e, st) {
      debugPrint('CORTEX video thumb failed: $e\n$st');
    }
  }
}
