import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/enrichment/link_preview_service.dart';
import '../data/enrichment/video_thumb_service.dart';
import '../data/file_storage.dart';
import '../data/models/claim.dart';
import '../data/models/project.dart';
import '../data/models/research_enums.dart';
import '../data/models/research_item.dart';
import 'claims_provider.dart';
import 'isar_provider.dart';

enum FeedFilter { all, text, links, images, videos, files }

final feedFilterProvider =
    StateProvider.family<FeedFilter, int>((ref, projectId) => FeedFilter.all);

final feedQueryProvider =
    StateProvider.family<String, int>((ref, projectId) => '');

final feedTagFilterProvider =
    StateProvider.family<String?, int>((ref, projectId) => null);

/// Active stage in the project workspace (`null` = Overview).
final selectedStageProvider =
    StateProvider.family<ResearchStage?, int>((ref, projectId) => null);

final projectItemsProvider =
    StreamProvider.family<List<ResearchItem>, int>((ref, projectId) {
  final isar = ref.watch(isarProvider);
  return isar.researchItems
      .filter()
      .project((q) => q.idEqualTo(projectId))
      .watch(fireImmediately: true)
      .map((list) {
    final sorted = [...list];
    sorted.sort((a, b) {
      final byIndex = b.sortIndex.compareTo(a.sortIndex);
      if (byIndex != 0) return byIndex;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  });
});

final stageItemsProvider =
    Provider.family<AsyncValue<List<ResearchItem>>, (int, ResearchStage)>(
        (ref, key) {
  final (projectId, stage) = key;
  final items = ref.watch(projectItemsProvider(projectId));
  return items.whenData(
    (list) => list.where((i) => i.stage == stage).toList(),
  );
});

final filteredProjectItemsProvider =
    Provider.family<AsyncValue<List<ResearchItem>>, int>((ref, projectId) {
  final items = ref.watch(projectItemsProvider(projectId));
  final filter = ref.watch(feedFilterProvider(projectId));
  final query = ref.watch(feedQueryProvider(projectId)).trim().toLowerCase();
  final tag = ref.watch(feedTagFilterProvider(projectId));
  final stage = ref.watch(selectedStageProvider(projectId));

  return items.whenData((list) {
    return list.where((i) {
      if (stage != null && i.stage != stage) return false;
      if (tag != null &&
          !i.tags.map((t) => t.toLowerCase()).contains(tag.toLowerCase())) {
        return false;
      }
      final typeOk = switch (filter) {
        FeedFilter.all => true,
        FeedFilter.text => i.type == ItemType.text,
        FeedFilter.links => i.type == ItemType.link,
        FeedFilter.images => i.type == ItemType.image,
        FeedFilter.videos => i.type == ItemType.video,
        FeedFilter.files => i.type == ItemType.file,
      };
      if (!typeOk) return false;
      if (query.isEmpty) return true;
      final blob = [
        i.text ?? '',
        i.note ?? '',
        i.previewTitle ?? '',
        i.previewDescription ?? '',
        i.fileName ?? '',
        i.sourceUrl ?? '',
        i.citation ?? '',
        ...i.tags,
      ].join(' ').toLowerCase();
      return blob.contains(query);
    }).toList();
  });
});

/// Items with a sourceUrl or citation for the References stage view.
final projectReferencesProvider =
    Provider.family<AsyncValue<List<ResearchItem>>, int>((ref, projectId) {
  final items = ref.watch(projectItemsProvider(projectId));
  return items.whenData((list) {
    final refs = list.where((i) {
      final url = i.sourceUrl?.trim() ?? '';
      final cite = i.citation?.trim() ?? '';
      return url.isNotEmpty || cite.isNotEmpty;
    }).toList()
      ..sort((a, b) => (a.previewTitle ?? a.sourceUrl ?? '')
          .toLowerCase()
          .compareTo((b.previewTitle ?? b.sourceUrl ?? '').toLowerCase()));
    return refs;
  });
});

final itemByIdProvider =
    StreamProvider.family<ResearchItem?, int>((ref, id) {
  final isar = ref.watch(isarProvider);
  return isar.researchItems.watchObject(id, fireImmediately: true);
});

class ItemsRepository {
  ItemsRepository(this._isar);

  final Isar _isar;

  Future<ResearchItem> addText({
    required Project project,
    required String text,
    ResearchStage stage = ResearchStage.evidence,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
    Claim? claim,
    Stance stance = Stance.neutral,
    Credibility credibility = Credibility.unknown,
  }) {
    return _putItem(
      project: project,
      type: ItemType.text,
      stage: stage,
      text: text.trim(),
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
      claim: claim,
      stance: stance,
      credibility: credibility,
    );
  }

  Future<ResearchItem> addLink({
    required Project project,
    required String url,
    ResearchStage stage = ResearchStage.evidence,
    String? note,
    List<String> tags = const [],
    Claim? claim,
    Stance stance = Stance.neutral,
    Credibility credibility = Credibility.unknown,
  }) async {
    final cleaned = url.trim();
    final item = await _putItem(
      project: project,
      type: ItemType.link,
      stage: stage,
      sourceUrl: cleaned,
      previewTitle: cleaned,
      note: note,
      tags: tags,
      claim: claim,
      stance: stance,
      credibility: credibility,
      citation: cleaned,
    );
    unawaited(LinkPreviewService.enrich(item, _isar));
    return item;
  }

  Future<ResearchItem> addFileFromPath({
    required Project project,
    required String path,
    required ItemType type,
    ResearchStage stage = ResearchStage.evidence,
    String? fileName,
    String? mimeType,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
    Claim? claim,
    Stance stance = Stance.neutral,
    Credibility credibility = Credibility.unknown,
  }) async {
    final stored = await FileStorage.copyFile(
      source: File(path),
      projectId: project.id,
      preferredName: fileName,
      mimeType: mimeType,
    );
    final item = await _putItem(
      project: project,
      type: type,
      stage: stage,
      fileRelPath: stored.relativePath,
      fileName: stored.fileName,
      mimeType: stored.mimeType,
      fileSize: stored.fileSize,
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
      claim: claim,
      stance: stance,
      credibility: credibility,
    );
    if (type == ItemType.video) {
      unawaited(VideoThumbService.generate(item, _isar));
    }
    return item;
  }

  Future<ResearchItem> addFileFromBytes({
    required Project project,
    required List<int> bytes,
    required ItemType type,
    required String fileName,
    ResearchStage stage = ResearchStage.evidence,
    String? mimeType,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
    Claim? claim,
    Stance stance = Stance.neutral,
    Credibility credibility = Credibility.unknown,
  }) async {
    final stored = await FileStorage.writeBytes(
      bytes: bytes,
      projectId: project.id,
      fileName: fileName,
      mimeType: mimeType,
    );
    final item = await _putItem(
      project: project,
      type: type,
      stage: stage,
      fileRelPath: stored.relativePath,
      fileName: stored.fileName,
      mimeType: stored.mimeType,
      fileSize: stored.fileSize,
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
      claim: claim,
      stance: stance,
      credibility: credibility,
    );
    if (type == ItemType.video) {
      unawaited(VideoThumbService.generate(item, _isar));
    }
    return item;
  }

  Future<ResearchItem> _putItem({
    required Project project,
    required ItemType type,
    required ResearchStage stage,
    String? text,
    String? note,
    String? sourceUrl,
    String? fileRelPath,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? previewTitle,
    String? previewDescription,
    String? previewImageUrl,
    String? citation,
    List<String> tags = const [],
    Claim? claim,
    Stance stance = Stance.neutral,
    Credibility credibility = Credibility.unknown,
  }) async {
    await project.items.load();
    final count = project.items.length;

    final item = ResearchItem()
      ..type = type
      ..stage = stage
      ..text = text
      ..note = _emptyToNull(note)
      ..sourceUrl = _emptyToNull(sourceUrl)
      ..fileRelPath = fileRelPath
      ..fileName = fileName
      ..mimeType = mimeType
      ..fileSize = fileSize
      ..previewTitle = previewTitle
      ..previewDescription = previewDescription
      ..previewImageUrl = previewImageUrl
      ..citation = citation
      ..tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
      ..stance = stance
      ..credibility = credibility
      ..createdAt = DateTime.now()
      ..sortIndex = count;

    await _isar.writeTxn(() async {
      await _isar.researchItems.put(item);
      item.project.value = project;
      await item.project.save();
      if (claim != null) {
        item.claim.value = claim;
        await item.claim.save();
      }
      project.updatedAt = DateTime.now();
      await _isar.projects.put(project);
    });

    if (claim != null) {
      unawaited(ClaimsRepository(_isar).recompute(claim));
    }
    return item;
  }

  Future<void> updateMeta(
    ResearchItem item, {
    String? note,
    List<String>? tags,
    String? text,
    ResearchStage? stage,
    Claim? claim,
    bool clearClaim = false,
    Stance? stance,
    Credibility? credibility,
  }) async {
    if (note != null) item.note = _emptyToNull(note);
    if (tags != null) {
      item.tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    if (text != null) item.text = text.trim();
    if (stage != null) item.stage = stage;
    if (stance != null) item.stance = stance;
    if (credibility != null) item.credibility = credibility;

    Claim? oldClaim;
    await item.claim.load();
    oldClaim = item.claim.value;

    await _isar.writeTxn(() async {
      if (clearClaim) {
        item.claim.value = null;
        await item.claim.save();
        item.stance = Stance.neutral;
      } else if (claim != null) {
        item.claim.value = claim;
        await item.claim.save();
      }
      await _isar.researchItems.put(item);
      await item.project.load();
      final project = item.project.value;
      if (project != null) {
        project.updatedAt = DateTime.now();
        await _isar.projects.put(project);
      }
    });

    final claimsRepo = ClaimsRepository(_isar);
    if (oldClaim != null) unawaited(claimsRepo.recompute(oldClaim));
    final next = clearClaim ? null : (claim ?? oldClaim);
    if (next != null && next.id != oldClaim?.id) {
      unawaited(claimsRepo.recompute(next));
    } else if (next != null) {
      unawaited(claimsRepo.recompute(next));
    }
  }

  Future<void> moveToProject(ResearchItem item, Project target) async {
    await item.project.load();
    final old = item.project.value;

    if (item.fileRelPath != null) {
      final abs = await FileStorage.absoluteFromRelative(item.fileRelPath!);
      final source = File(abs);
      if (await source.exists()) {
        final stored = await FileStorage.copyFile(
          source: source,
          projectId: target.id,
          preferredName: item.fileName,
          mimeType: item.mimeType,
        );
        await FileStorage.deleteRelative(item.fileRelPath);
        item.fileRelPath = stored.relativePath;
      }
    }

    await _isar.writeTxn(() async {
      item.project.value = target;
      await item.project.save();
      await _isar.researchItems.put(item);
      target.updatedAt = DateTime.now();
      await _isar.projects.put(target);
      if (old != null && old.id != target.id) {
        old.updatedAt = DateTime.now();
        await _isar.projects.put(old);
      }
    });
  }

  Future<void> delete(ResearchItem item) async {
    await FileStorage.deleteRelative(item.fileRelPath);
    if (LinkPreviewService.isCachedLocalPath(item.previewImageUrl)) {
      await FileStorage.deleteRelative(item.previewImageUrl);
    }
    await item.project.load();
    await item.claim.load();
    final project = item.project.value;
    final claim = item.claim.value;
    await _isar.writeTxn(() async {
      await _isar.researchItems.delete(item.id);
      if (project != null) {
        project.updatedAt = DateTime.now();
        await _isar.projects.put(project);
      }
    });
    if (claim != null) {
      unawaited(ClaimsRepository(_isar).recompute(claim));
    }
  }

  static String? _emptyToNull(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  static ItemType typeFromMime(String? mime, {String? path}) {
    final m = (mime ?? '').toLowerCase();
    if (m.startsWith('image/')) return ItemType.image;
    if (m.startsWith('video/')) return ItemType.video;
    final name = (path ?? '').toLowerCase();
    if (name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        name.endsWith('.heic')) {
      return ItemType.image;
    }
    if (name.endsWith('.mp4') ||
        name.endsWith('.webm') ||
        name.endsWith('.mkv') ||
        name.endsWith('.mov')) {
      return ItemType.video;
    }
    return ItemType.file;
  }

  static bool looksLikeUrl(String value) {
    final t = value.trim();
    final uri = Uri.tryParse(t);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(ref.watch(isarProvider));
});
