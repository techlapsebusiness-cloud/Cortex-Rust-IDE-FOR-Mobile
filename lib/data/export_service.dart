import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'file_storage.dart';
import 'models/claim.dart';
import 'models/project.dart';
import 'models/research_enums.dart';
import 'models/research_item.dart';

/// JSON + files export bundle.
class ExportService {
  ExportService(this._isar);

  final Isar _isar;

  Future<File> exportBundle() async {
    final projects = await _isar.projects.where().anyId().findAll();
    final items = await _isar.researchItems.where().anyId().findAll();
    final claims = await _isar.claims.where().anyId().findAll();

    final projectJson = <Map<String, dynamic>>[];
    for (final proj in projects) {
      projectJson.add({
        'id': proj.id,
        'title': proj.title,
        'researchQuestion': proj.researchQuestion,
        'field': proj.field,
        'description': proj.description,
        'colorValue': proj.colorValue,
        'createdAt': proj.createdAt.toIso8601String(),
        'updatedAt': proj.updatedAt.toIso8601String(),
        'sortIndex': proj.sortIndex,
      });
    }

    final claimJson = <Map<String, dynamic>>[];
    for (final claim in claims) {
      await claim.project.load();
      claimJson.add({
        'id': claim.id,
        'projectId': claim.project.value?.id,
        'type': claim.type.name,
        'statement': claim.statement,
        'status': claim.status.name,
        'confidence': claim.confidence,
        'createdAt': claim.createdAt.toIso8601String(),
        'sortIndex': claim.sortIndex,
      });
    }

    final itemJson = <Map<String, dynamic>>[];
    final archive = Archive();

    for (final item in items) {
      await item.project.load();
      await item.claim.load();
      itemJson.add({
        'id': item.id,
        'projectId': item.project.value?.id,
        'claimId': item.claim.value?.id,
        'stage': item.stage.name,
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
        'citation': item.citation,
        'tags': item.tags,
        'stance': item.stance.name,
        'credibility': item.credibility.name,
        'createdAt': item.createdAt.toIso8601String(),
        'sortIndex': item.sortIndex,
      });

      for (final rel in [
        item.fileRelPath,
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
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'projects': projectJson,
        'claims': claimJson,
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

    final version = (manifest['version'] as num?)?.toInt() ?? 1;

    if (version >= 2) {
      await _importV2(manifest);
    } else {
      await _importLegacyTopics(manifest);
    }
  }

  Future<void> _importV2(Map<String, dynamic> manifest) async {
    final projectsRaw = (manifest['projects'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final claimsRaw = (manifest['claims'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final itemsRaw = (manifest['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final projectIdMap = <int, Project>{};
    final claimIdMap = <int, Claim>{};

    await _isar.writeTxn(() async {
      for (final raw in projectsRaw) {
        final project = Project()
          ..title = raw['title'] as String
          ..researchQuestion = raw['researchQuestion'] as String? ?? ''
          ..field = raw['field'] as String?
          ..description = raw['description'] as String?
          ..colorValue = (raw['colorValue'] as num?)?.toInt() ?? 0xFF22D3EE
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..updatedAt = DateTime.parse(raw['updatedAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0;
        await _isar.projects.put(project);
        projectIdMap[(raw['id'] as num).toInt()] = project;
      }

      for (final raw in claimsRaw) {
        final oldProjectId = (raw['projectId'] as num?)?.toInt();
        final project = oldProjectId == null ? null : projectIdMap[oldProjectId];
        if (project == null) continue;

        final typeName = raw['type'] as String? ?? 'hypothesis';
        final statusName = raw['status'] as String? ?? 'open';
        final claim = Claim()
          ..type = ClaimType.values.firstWhere(
            (e) => e.name == typeName,
            orElse: () => ClaimType.hypothesis,
          )
          ..statement = raw['statement'] as String
          ..status = ClaimStatus.values.firstWhere(
            (e) => e.name == statusName,
            orElse: () => ClaimStatus.open,
          )
          ..confidence = (raw['confidence'] as num?)?.toInt() ?? 50
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0;

        await _isar.claims.put(claim);
        claim.project.value = project;
        await claim.project.save();
        claimIdMap[(raw['id'] as num).toInt()] = claim;
      }

      for (final raw in itemsRaw) {
        final oldProjectId = (raw['projectId'] as num?)?.toInt();
        final project = oldProjectId == null ? null : projectIdMap[oldProjectId];
        if (project == null) continue;

        final typeName = raw['type'] as String? ?? 'text';
        final stageName = raw['stage'] as String? ?? 'evidence';
        final stanceName = raw['stance'] as String? ?? 'neutral';
        final credName = raw['credibility'] as String? ?? 'unknown';

        final item = ResearchItem()
          ..stage = ResearchStage.values.firstWhere(
            (e) => e.name == stageName,
            orElse: () => ResearchStage.evidence,
          )
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
          ..citation = raw['citation'] as String?
          ..tags = ((raw['tags'] as List<dynamic>?) ?? [])
              .map((e) => '$e')
              .toList()
          ..stance = Stance.values.firstWhere(
            (e) => e.name == stanceName,
            orElse: () => Stance.neutral,
          )
          ..credibility = Credibility.values.firstWhere(
            (e) => e.name == credName,
            orElse: () => Credibility.unknown,
          )
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0;

        await _isar.researchItems.put(item);
        item.project.value = project;
        await item.project.save();

        final oldClaimId = (raw['claimId'] as num?)?.toInt();
        final claim = oldClaimId == null ? null : claimIdMap[oldClaimId];
        if (claim != null) {
          item.claim.value = claim;
          await item.claim.save();
        }
      }
    });
  }

  /// Best-effort import of v1 topic-based exports into projects.
  Future<void> _importLegacyTopics(Map<String, dynamic> manifest) async {
    final topicsRaw = (manifest['topics'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final itemsRaw = (manifest['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final idMap = <int, Project>{};

    await _isar.writeTxn(() async {
      for (final raw in topicsRaw) {
        final project = Project()
          ..title = raw['title'] as String
          ..description = raw['description'] as String?
          ..colorValue = (raw['colorValue'] as num?)?.toInt() ?? 0xFF22D3EE
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..updatedAt = DateTime.parse(raw['updatedAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0;
        await _isar.projects.put(project);
        idMap[(raw['id'] as num).toInt()] = project;
      }

      for (final raw in itemsRaw) {
        final oldTopicId = (raw['topicId'] as num?)?.toInt();
        final project = oldTopicId == null ? null : idMap[oldTopicId];
        if (project == null) continue;

        final typeName = raw['type'] as String? ?? 'text';
        final item = ResearchItem()
          ..stage = ResearchStage.evidence
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
          ..tags = ((raw['tags'] as List<dynamic>?) ?? [])
              .map((e) => '$e')
              .toList()
          ..createdAt = DateTime.parse(raw['createdAt'] as String)
          ..sortIndex = (raw['sortIndex'] as num?)?.toInt() ?? 0;

        await _isar.researchItems.put(item);
        item.project.value = project;
        await item.project.save();
      }
    });
  }
}
