import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/models/item.dart';
import '../data/models/item_type.dart';
import '../data/models/topic.dart';
import 'isar_provider.dart';
import 'items_provider.dart';
import 'topics_provider.dart';

final globalSearchQueryProvider = StateProvider<String>((ref) => '');
final globalSearchTypeProvider =
    StateProvider<FeedFilter>((ref) => FeedFilter.all);
final globalSearchTagProvider = StateProvider<String?>((ref) => null);

class SearchHit {
  const SearchHit({required this.item, required this.topic});

  final Item item;
  final Topic topic;
}

class SearchResults {
  const SearchResults({
    required this.topicHits,
    required this.groupedItems,
  });

  final List<Topic> topicHits;

  /// Items grouped by topic title, newest first within each group.
  final Map<Topic, List<Item>> groupedItems;
}

final tagsIndexProvider = StreamProvider<List<String>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.items.watchLazy(fireImmediately: true).asyncMap((_) async {
    final items = await isar.items.where().anyId().findAll();
    final tags = <String>{};
    for (final i in items) {
      tags.addAll(i.tags.map((t) => t.toLowerCase()));
    }
    final list = tags.toList()..sort();
    return list;
  });
});

final globalSearchProvider = FutureProvider<SearchResults>((ref) async {
  final query = ref.watch(globalSearchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(globalSearchTypeProvider);
  final tagFilter = ref.watch(globalSearchTagProvider)?.toLowerCase();
  final topics = await ref.watch(topicsProvider.future);
  final isar = await ref.watch(isarProvider.future);

  final emptyQuery = query.isEmpty;
  final emptyTag = tagFilter == null || tagFilter.isEmpty;
  if (emptyQuery && emptyTag && typeFilter == FeedFilter.all) {
    return const SearchResults(topicHits: [], groupedItems: {});
  }

  final topicHits = emptyQuery
      ? <Topic>[]
      : topics.where((t) => t.searchText.contains(query)).toList();

  final allItems = await isar.items.where().anyId().findAll();
  final matched = <Item>[];
  for (final item in allItems) {
    if (!emptyQuery && !item.searchText.contains(query)) continue;
    if (!emptyTag &&
        !item.tags.any((t) => t.toLowerCase() == tagFilter)) {
      continue;
    }
    final typeOk = switch (typeFilter) {
      FeedFilter.all => true,
      FeedFilter.text => item.type == ItemType.text,
      FeedFilter.links => item.type == ItemType.link,
      FeedFilter.images => item.type == ItemType.image,
      FeedFilter.videos => item.type == ItemType.video,
      FeedFilter.files => item.type == ItemType.file,
    };
    if (!typeOk) continue;
    matched.add(item);
  }

  matched.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final grouped = <Topic, List<Item>>{};
  for (final item in matched) {
    await item.topic.load();
    final topic = item.topic.value;
    if (topic == null) continue;
    grouped.putIfAbsent(topic, () => []).add(item);
  }

  return SearchResults(topicHits: topicHits, groupedItems: grouped);
});
