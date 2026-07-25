import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'file_storage.dart';
import 'models/item.dart';
import 'models/item_type.dart';
import 'models/topic.dart';

/// JSON + files export bundle (Phase 7 stretch).
class ExportService {
  ExportService(this._isar);

  final Isar _isar;

  /// Writes a zip under the app cache dir and returns its absolute path.
  Future<File> exportBundle() async {
    final topics = await _isar.topics.where().anyId().findAll();
    final items = await _isar.items.where().anyId().findAll();

    final topicJson = <Map<String, dynamic>>[];
    for (final t in topics) {
      topicJson.add({
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'colorValue': t.colorValue,
        'iconName': t.iconName,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
        'sortIndex': t.sortIndex,
      });
    }

    final itemJson = <Map<String, dynamic>>[];
    final archive = Archive();

    for (final item in items) {
      await item.topic.load();
      itemJson.add({
        'id': item.id,
        'topicId': item.topic.value?.id,
        'type': item.type.name,
        'text': item.text,
        'note': item.note,
        'sourceUrl': item.sourceUrl,
        'fileRelPath': item.fileRelPath,
        'fileName': item.fileName,
        'mimeType': item.mimeType,
        'fileSize': item.fileSize,
        'previewTitle': item.previewTitle,
        'previewDescription': item.previewDescription,
        'previewImageUrl': item.previewImageUrl,
        'thumbRelPath': item.thumbRelPath,
        'tags': item.tags,
        'createdAt': item.createdAt.toIso8601String(),
        'sortIndex': item.sortIndex,
      });

      for (final rel in [
        item.fileRelPath,
        item.thumbRelPath,
        if (item.previewImageUrl != null &&
            !item.previewImageUrl!.startsWith('http'))
          item.previewImageUrl,
      ]) {
        if (rel == null || rel.isEmpty) continue;
        try {
          final abs = await FileStorage.absoluteFromRelative(rel);
          final f = File(abs);
          if (await f.exists()) {
            final fileBytes = await f.readAsBytes();
            archive.addFile(
              ArchiveFile('files/$rel', fileBytes.length, fileBytes),
            );
          }
        } catch (_) {}
      }
    }

    final manifest = utf8.encode(
      const JsonEncoder.withIndent('  ').convert({
        'format': 'cortex-export',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'topics': topicJson,
        'items': itemJson,
      }),
    );
    archive.addFile(ArchiveFile('cortex.json', manifest.length, manifest));

    final encoded = ZipEncoder().encode(archive);

    final cache = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final out = File(p.join(cache.path, 'cortex-export-$stamp.zip'));
    await out.writeAsBytes(encoded, flush: true);
    return out;
  }

  /// Imports a previously exported zip (re-importable bundle).
  Future<void> importBundle(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final manifestFile = archive.findFile('cortex.json');
    if (manifestFile == null) {
      throw StateError('Missing cortex.json in bundle');
    }
    final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>))
        as Map<String, dynamic>;
    if (manifest['format'] != 'cortex-export') {
      throw StateError('Not a CORTEX export');
    }

    final docs = await FileStorage.docsDir();

    for (final file in archive.files) {
      if (!file.isFile || !file.name.startsWith('files/')) continue;
      final rel = file.name.substring('files/'.length);
      final dest = File(p.join(docs.path, rel));
      await dest.parent.create(recursive: true);
      await dest.writeAsBytes(file.content as List<int>, flush: true);
    }

    final topicsRaw = (manifest['topics'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final itemsRaw = (manifest['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final idMap = <int, Topic>{};

    await _isar.writeTxn(() async {
      for (final raw in topicsRaw) {
        final topic = Topic()
          ..title = raw['title'] as String
          ..description = raw['description'] as String?
          ..colorValue = (raw['colorValue'] as num?)?.toInt() ?? 0xFF22D3EE
          ..iconName = raw['iconName'] as String?
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..updatedAt = DateTime.parse(raw['updatedAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0
          ..rebuildSearchText();
        await _isar.topics.put(topic);
        final oldId = (raw['id'] as num).toInt();
        idMap[oldId] = topic;
      }

      for (final raw in itemsRaw) {
        final oldTopicId = (raw['topicId'] as num?)?.toInt();
        final topic = oldTopicId == null ? null : idMap[oldTopicId];
        if (topic == null) continue;

        final typeName = raw['type'] as String? ?? 'text';
        final item = Item()
          ..type = ItemType.values.firstWhere(
            (e) => e.name == typeName,
            orElse: () => ItemType.file,
          )
          ..text = raw['text'] as String?
          ..note = raw['note'] as String?
          ..sourceUrl = raw['sourceUrl'] as String?
          ..fileRelPath = raw['fileRelPath'] as String?
          ..fileName = raw['fileName'] as String?
          ..mimeType = raw['mimeType'] as String?
          ..fileSize = (raw['fileSize'] as num?)?.toInt()
          ..previewTitle = raw['previewTitle'] as String?
          ..previewDescription = raw['previewDescription'] as String?
          ..previewImageUrl = raw['previewImageUrl'] as String?
          ..thumbRelPath = raw['thumbRelPath'] as String?
          ..tags = ((raw['tags'] as List<dynamic>?) ?? [])
              .map((e) => '$e')
              .toList()
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0
          ..rebuildSearchText();

        await _isar.items.put(item);
        item.topic.value = topic;
        await item.topic.save();
      }
    });
  }
}
