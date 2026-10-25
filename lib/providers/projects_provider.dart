import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/models/claim.dart';
import '../data/models/project.dart';
import '../data/models/research_item.dart';
import 'isar_provider.dart';

enum ProjectSort { recent, alpha, mostItems }

final projectSortProvider = StateProvider<ProjectSort>((ref) => ProjectSort.recent);

final projectQueryProvider = StateProvider<String>((ref) => '');

final projectFieldFilterProvider = StateProvider<String?>((ref) => null);

/// Live projects list — rebuilds on every Isar change (§4).
final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final isar = ref.watch(isarProvider);
  // Also watch items so "most items" sort / counts stay fresh.
  return isar.projects.where().watch(fireImmediately: true);
});

final projectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final raw = ref.watch(projectsStreamProvider);
  final sort = ref.watch(projectSortProvider);
  final query = ref.watch(projectQueryProvider).trim().toLowerCase();
  final field = ref.watch(projectFieldFilterProvider);
  final isar = ref.watch(isarProvider);

  return raw.whenData((list) {
    var filtered = list.where((p) {
      if (field != null && field.isNotEmpty) {
        if ((p.field ?? '').toLowerCase() != field.toLowerCase()) return false;
      }
      if (query.isEmpty) return true;
      final blob = [
        p.title,
        p.researchQuestion,
        p.field ?? '',
        p.description ?? '',
      ].join(' ').toLowerCase();
      return blob.contains(query);
    }).toList();

    switch (sort) {
      case ProjectSort.recent:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case ProjectSort.alpha:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case ProjectSort.mostItems:
        final counts = <int, int>{};
        for (final p in filtered) {
          // Synchronous backlink length after load is async; use filter count.
          counts[p.id] = isar.researchItems
              .filter()
              .project((q) => q.idEqualTo(p.id))
              .countSync();
        }
        filtered.sort((a, b) {
          final byCount = (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
          if (byCount != 0) return byCount;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }
    return filtered;
  });
});

final selectedProjectIdProvider = StateProvider<int?>((ref) => null);

final selectedProjectProvider = Provider<AsyncValue<Project?>>((ref) {
  final id = ref.watch(selectedProjectIdProvider);
  final projects = ref.watch(projectsProvider);
  return projects.whenData((list) {
    if (list.isEmpty) return null;
    if (id == null) return list.first;
    for (final p in list) {
      if (p.id == id) return p;
    }
    return list.first;
  });
});

class ProjectsRepository {
  ProjectsRepository(this._isar);

  final Isar _isar;

  Future<Project> create({
    required String title,
    String researchQuestion = '',
    String? field,
    String? description,
    int colorValue = 0xFF22D3EE,
  }) async {
    final now = DateTime.now();
    final count = await _isar.projects.count();
    final project = Project()
      ..title = title.trim()
      ..researchQuestion = researchQuestion.trim()
      ..field = _emptyToNull(field)
      ..description = _emptyToNull(description)
      ..colorValue = colorValue
      ..createdAt = now
      ..updatedAt = now
      ..sortIndex = count;

    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
    return project;
  }

  Future<void> update(
    Project project, {
    String? title,
    String? researchQuestion,
    String? field,
    String? description,
    int? colorValue,
  }) async {
    if (title != null) project.title = title.trim();
    if (researchQuestion != null) {
      project.researchQuestion = researchQuestion.trim();
    }
    if (field != null) project.field = _emptyToNull(field);
    if (description != null) project.description = _emptyToNull(description);
    if (colorValue != null) project.colorValue = colorValue;
    project.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
  }

  Future<void> touch(Project project) async {
    project.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
  }

  Future<void> delete(Project project) async {
    await _isar.writeTxn(() async {
      await project.items.load();
      await project.claims.load();
      final itemIds = project.items.map((e) => e.id).toList();
      final claimIds = project.claims.map((e) => e.id).toList();
      if (itemIds.isNotEmpty) await _isar.researchItems.deleteAll(itemIds);
      if (claimIds.isNotEmpty) await _isar.claims.deleteAll(claimIds);
      await _isar.projects.delete(project.id);
    });
  }

  Future<void> reorder(int projectId, int newIndex) async {
    final projects = await _isar.projects.where().sortBySortIndex().findAll();
    final from = projects.indexWhere((p) => p.id == projectId);
    if (from < 0) return;
    final moved = projects.removeAt(from);
    projects.insert(newIndex.clamp(0, projects.length), moved);
    await _isar.writeTxn(() async {
      for (var i = 0; i < projects.length; i++) {
        projects[i].sortIndex = i;
        projects[i].updatedAt = DateTime.now();
        await _isar.projects.put(projects[i]);
      }
    });
  }

  Future<int> itemCount(Project project) async {
    await project.items.load();
    return project.items.length;
  }

  Future<Set<int>> occupiedStageOrdinals(Project project) async {
    await project.items.load();
    return {
      for (final i in project.items) i.stage.index,
    };
  }

  static String? _emptyToNull(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository(ref.watch(isarProvider));
});
