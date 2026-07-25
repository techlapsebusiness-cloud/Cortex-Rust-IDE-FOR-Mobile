import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/models/item.dart';
import '../data/models/topic.dart';
import 'isar_provider.dart';

final topicsProvider = StreamProvider<List<Topic>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.topics
      .where()
      .sortBySortIndex()
      .thenByTitle()
      .watch(fireImmediately: true);
});

final selectedTopicIdProvider = StateProvider<int?>((ref) => null);

final selectedTopicProvider = Provider<AsyncValue<Topic?>>((ref) {
  final id = ref.watch(selectedTopicIdProvider);
  final topics = ref.watch(topicsProvider);
  return topics.whenData((list) {
    if (id == null) return list.isEmpty ? null : list.first;
    for (final t in list) {
      if (t.id == id) return t;
    }
    return list.isEmpty ? null : list.first;
  });
});

class TopicsRepository {
  TopicsRepository(this._isar);

  final Isar _isar;

  Future<Topic> create({
    required String title,
    String? description,
    int colorValue = 0xFF22D3EE,
  }) async {
    final now = DateTime.now();
    final count = await _isar.topics.count();
    final topic = Topic()
      ..title = title.trim()
      ..description = description?.trim().isEmpty == true
          ? null
          : description?.trim()
      ..colorValue = colorValue
      ..createdAt = now
      ..updatedAt = now
      ..sortIndex = count
      ..rebuildSearchText();

    await _isar.writeTxn(() async {
      await _isar.topics.put(topic);
    });
    return topic;
  }

  Future<void> rename(Topic topic, String title) async {
    topic
      ..title = title.trim()
      ..updatedAt = DateTime.now()
      ..rebuildSearchText();
    await _isar.writeTxn(() async {
      await _isar.topics.put(topic);
    });
  }

  Future<void> updateDescription(Topic topic, String? description) async {
    topic
      ..description = description?.trim().isEmpty == true
          ? null
          : description?.trim()
      ..updatedAt = DateTime.now()
      ..rebuildSearchText();
    await _isar.writeTxn(() async {
      await _isar.topics.put(topic);
    });
  }

  Future<void> setColor(Topic topic, int colorValue) async {
    topic
      ..colorValue = colorValue
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.topics.put(topic);
    });
  }

  Future<void> delete(Topic topic) async {
    await _isar.writeTxn(() async {
      await topic.items.load();
      final itemIds = topic.items.map((e) => e.id).toList();
      if (itemIds.isNotEmpty) {
        await _isar.items.deleteAll(itemIds);
      }
      await _isar.topics.delete(topic.id);
    });
  }

  /// Reorder by moving [topicId] to [newIndex] among current sorted topics.
  Future<void> reorder(int topicId, int newIndex) async {
    final topics = await _isar.topics.where().sortBySortIndex().findAll();
    final from = topics.indexWhere((t) => t.id == topicId);
    if (from < 0) return;

    final moved = topics.removeAt(from);
    final clamped = newIndex.clamp(0, topics.length);
    topics.insert(clamped, moved);

    await _isar.writeTxn(() async {
      for (var i = 0; i < topics.length; i++) {
        topics[i].sortIndex = i;
        topics[i].updatedAt = DateTime.now();
        await _isar.topics.put(topics[i]);
      }
    });
  }

  Future<int> itemCount(Topic topic) async {
    await topic.items.load();
    return topic.items.length;
  }
}

final topicsRepositoryProvider = Provider<AsyncValue<TopicsRepository>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.whenData(TopicsRepository.new);
});
