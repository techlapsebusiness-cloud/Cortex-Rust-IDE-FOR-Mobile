import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/enrichment/link_preview_service.dart';
import '../data/enrichment/video_thumb_service.dart';
import '../data/file_storage.dart';
import '../data/models/item.dart';
import '../data/models/item_type.dart';
import '../data/models/topic.dart';
import 'isar_provider.dart';

enum FeedFilter { all, text, links, images, videos, files }

final feedFilterProvider = StateProvider.family<FeedFilter, int>((ref, topicId) {
  return FeedFilter.all;
});

final feedQueryProvider = StateProvider.family<String, int>((ref, topicId) {
  return '';
});

final topicItemsProvider =
    StreamProvider.family<List<Item>, int>((ref, topicId) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.items
      .filter()
      .topic((q) => q.idEqualTo(topicId))
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

final filteredTopicItemsProvider =
    Provider.family<AsyncValue<List<Item>>, int>((ref, topicId) {
  final items = ref.watch(topicItemsProvider(topicId));
  final filter = ref.watch(feedFilterProvider(topicId));
  final query = ref.watch(feedQueryProvider(topicId)).trim().toLowerCase();

  return items.whenData((list) {
    Iterable<Item> out = list;
    switch (filter) {
      case FeedFilter.all:
        break;
      case FeedFilter.text:
        out = out.where((i) => i.type == ItemType.text);
      case FeedFilter.links:
        out = out.where((i) => i.type == ItemType.link);
      case FeedFilter.images:
        out = out.where((i) => i.type == ItemType.image);
      case FeedFilter.videos:
        out = out.where((i) => i.type == ItemType.video);
      case FeedFilter.files:
        out = out.where((i) => i.type == ItemType.file);
    }
    if (query.isNotEmpty) {
      out = out.where((i) => i.searchText.contains(query));
    }
    return out.toList();
  });
});

final itemByIdProvider =
    StreamProvider.family<Item?, int>((ref, itemId) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.items.watchObject(itemId, fireImmediately: true);
});

class ItemsRepository {
  ItemsRepository(this._isar);

  final Isar _isar;

  Future<Item> addText({
    required Topic topic,
    required String text,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
  }) {
    return _putItem(
      topic: topic,
      type: ItemType.text,
      text: text.trim(),
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
    );
  }

  Future<Item> addLink({
    required Topic topic,
    required String url,
    String? note,
    List<String> tags = const [],
  }) async {
    final cleaned = url.trim();
    final item = await _putItem(
      topic: topic,
      type: ItemType.link,
      sourceUrl: cleaned,
      previewTitle: cleaned,
      note: note,
      tags: tags,
    );
    // Non-blocking: skeleton card shows until cache lands (§11).
    unawaited(LinkPreviewService.enrich(item, _isar));
    return item;
  }

  Future<Item> addFileFromPath({
    required Topic topic,
    required String path,
    required ItemType type,
    String? fileName,
    String? mimeType,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
  }) async {
    final stored = await FileStorage.copyFile(
      source: File(path),
      topicId: topic.id,
      preferredName: fileName,
      mimeType: mimeType,
    );
    final item = await _putItem(
      topic: topic,
      type: type,
      fileRelPath: stored.relativePath,
      fileName: stored.fileName,
      mimeType: stored.mimeType,
      fileSize: stored.fileSize,
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
    );
    if (type == ItemType.video) {
      unawaited(VideoThumbService.generate(item, _isar));
    }
    return item;
  }

  Future<Item> addFileFromBytes({
    required Topic topic,
    required List<int> bytes,
    required ItemType type,
    required String fileName,
    String? mimeType,
    String? note,
    List<String> tags = const [],
    String? sourceUrl,
  }) async {
    final stored = await FileStorage.writeBytes(
      bytes: bytes,
      topicId: topic.id,
      fileName: fileName,
      mimeType: mimeType,
    );
    final item = await _putItem(
      topic: topic,
      type: type,
      fileRelPath: stored.relativePath,
      fileName: stored.fileName,
      mimeType: stored.mimeType,
      fileSize: stored.fileSize,
      note: note,
      tags: tags,
      sourceUrl: sourceUrl,
    );
    if (type == ItemType.video) {
      unawaited(VideoThumbService.generate(item, _isar));
    }
    return item;
  }

  Future<Item> _putItem({
    required Topic topic,
    required ItemType type,
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
    List<String> tags = const [],
  }) async {
    await topic.items.load();
    final count = topic.items.length;

    final item = Item()
      ..type = type
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
      ..tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
      ..createdAt = DateTime.now()
      ..sortIndex = count
      ..rebuildSearchText();

    await _isar.writeTxn(() async {
      await _isar.items.put(item);
      item.topic.value = topic;
      await item.topic.save();
      topic.updatedAt = DateTime.now();
      await _isar.topics.put(topic);
    });
    return item;
  }

  Future<void> updateMeta(
    Item item, {
    String? note,
    List<String>? tags,
    String? text,
  }) async {
    if (note != null) item.note = _emptyToNull(note);
    if (tags != null) {
      item.tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    if (text != null) item.text = text.trim();
    item.rebuildSearchText();

    await _isar.writeTxn(() async {
      await _isar.items.put(item);
      await item.topic.load();
      final topic = item.topic.value;
      if (topic != null) {
        topic.updatedAt = DateTime.now();
        await _isar.topics.put(topic);
      }
    });
  }

  Future<void> moveToTopic(Item item, Topic target) async {
    await item.topic.load();
    final old = item.topic.value;

    // Relocate file under new topic folder if present.
    if (item.fileRelPath != null) {
      final abs = await FileStorage.absoluteFromRelative(item.fileRelPath!);
      final source = File(abs);
      if (await source.exists()) {
        final stored = await FileStorage.copyFile(
          source: source,
          topicId: target.id,
          preferredName: item.fileName,
          mimeType: item.mimeType,
        );
        await FileStorage.deleteRelative(item.fileRelPath);
        item.fileRelPath = stored.relativePath;
      }
    }

    await _isar.writeTxn(() async {
      item.topic.value = target;
      await item.topic.save();
      await _isar.items.put(item);
      target.updatedAt = DateTime.now();
      await _isar.topics.put(target);
      if (old != null && old.id != target.id) {
        old.updatedAt = DateTime.now();
        await _isar.topics.put(old);
      }
    });
  }

  Future<void> delete(Item item) async {
    await FileStorage.deleteRelative(item.fileRelPath);
    await FileStorage.deleteRelative(item.thumbRelPath);
    if (LinkPreviewService.isCachedLocalPath(item.previewImageUrl)) {
      await FileStorage.deleteRelative(item.previewImageUrl);
    }
    await item.topic.load();
    final topic = item.topic.value;
    await _isar.writeTxn(() async {
      await _isar.items.delete(item.id);
      if (topic != null) {
        topic.updatedAt = DateTime.now();
        await _isar.topics.put(topic);
      }
    });
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

final itemsRepositoryProvider = Provider<AsyncValue<ItemsRepository>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.whenData(ItemsRepository.new);
});
