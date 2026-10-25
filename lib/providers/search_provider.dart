import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/models/project.dart';
import '../data/models/research_enums.dart';
import '../data/models/research_item.dart';
import 'isar_provider.dart';
import 'items_provider.dart';
import 'projects_provider.dart';

final globalSearchQueryProvider = StateProvider<String>((ref) => '');
final globalSearchTypeProvider =
    StateProvider<FeedFilter>((ref) => FeedFilter.all);
final globalSearchTagProvider = StateProvider<String?>((ref) => null);

class SearchHit {
  const SearchHit({required this.item, required this.project});

  final ResearchItem item;
  final Project project;
}

class SearchResults {
  const SearchResults({
    required this.projectHits,
    required this.groupedItems,
  });

  final List<Project> projectHits;

  /// Items grouped by project, newest first within each group.
  final Map<Project, List<ResearchItem>> groupedItems;
}

final tagsIndexProvider = StreamProvider<List<String>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.researchItems.watchLazy(fireImmediately: true).asyncMap((_) async {
    final items = await isar.researchItems.where().anyId().findAll();
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
  final projects = ref.watch(projectsProvider).valueOrNull ?? [];
  final isar = ref.watch(isarProvider);

  final emptyQuery = query.isEmpty;
  final emptyTag = tagFilter == null || tagFilter.isEmpty;
  if (emptyQuery && emptyTag && typeFilter == FeedFilter.all) {
    return const SearchResults(projectHits: [], groupedItems: {});
  }

  final projectHits = emptyQuery
      ? <Project>[]
      : projects.where((p) {
          final blob = [
            p.title,
            p.researchQuestion,
            p.field ?? '',
            p.description ?? '',
          ].join(' ').toLowerCase();
          return blob.contains(query);
        }).toList();

  final allItems = await isar.researchItems.where().anyId().findAll();
  final matched = <ResearchItem>[];
  for (final item in allItems) {
    final blob = [
      item.text ?? '',
      item.note ?? '',
      item.previewTitle ?? '',
      item.previewDescription ?? '',
      item.fileName ?? '',
      item.sourceUrl ?? '',
      item.citation ?? '',
      ...item.tags,
    ].join(' ').toLowerCase();
    if (!emptyQuery && !blob.contains(query)) continue;
    if (!emptyTag && !item.tags.any((t) => t.toLowerCase() == tagFilter)) {
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

  final grouped = <Project, List<ResearchItem>>{};
  for (final item in matched) {
    await item.project.load();
    final project = item.project.value;
    if (project == null) continue;
    grouped.putIfAbsent(project, () => []).add(item);
  }

  return SearchResults(projectHits: projectHits, groupedItems: grouped);
});
