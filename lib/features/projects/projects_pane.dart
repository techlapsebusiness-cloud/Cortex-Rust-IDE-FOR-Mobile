import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../providers/projects_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../capture/cortex_drop_region.dart';
import '../capture/quick_capture.dart';
import 'project_card.dart';
import 'project_editor_sheet.dart';

class ProjectsPane extends ConsumerWidget {
  const ProjectsPane({
    super.key,
    this.embedded = false,
    this.onProjectSelected,
  });

  /// When true (two-pane), selection stays in-shell instead of pushing a route.
  final bool embedded;
  final ValueChanged<Project>? onProjectSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final selectedId = ref.watch(selectedProjectIdProvider);
    final sort = ref.watch(projectSortProvider);
    final queryController = ref.watch(_searchControllerProvider);

    return CortexDropRegion(
      onPayloads: (payloads) => openCaptureForDrop(
        context,
        ref,
        payloads: payloads,
        targetProjectId: selectedId,
      ),
      child: Scaffold(
        backgroundColor: CortexColors.background,
        appBar: AppBar(
          title: Text(
            'PROJECTS',
            style:
                CortexTheme.orbitron(fontSize: 18, color: CortexColors.accent),
          ),
          actions: [
            PopupMenuButton<ProjectSort>(
              icon: const Icon(Icons.sort, color: CortexColors.muted),
              color: CortexColors.elevated,
              initialValue: sort,
              onSelected: (v) {
                ref.read(projectSortProvider.notifier).state = v;
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: ProjectSort.recent,
                  child: Text('Recent', style: CortexTheme.body()),
                ),
                PopupMenuItem(
                  value: ProjectSort.alpha,
                  child: Text('A–Z', style: CortexTheme.body()),
                ),
                PopupMenuItem(
                  value: ProjectSort.mostItems,
                  child: Text('Most items', style: CortexTheme.body()),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createProject(context, ref),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: queryController,
                style: CortexTheme.mono(fontSize: 13, color: CortexColors.text),
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search projects…',
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: CortexColors.muted,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (v) {
                  ref.read(projectQueryProvider.notifier).state = v;
                },
              ),
            ),
            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: CortexColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'DB ERROR: $e',
                    style: CortexTheme.mono(color: CortexColors.danger),
                  ),
                ),
                data: (projects) {
                  if (projects.isEmpty) {
                    return _EmptyProjects(
                      onCreate: () => _createProject(context, ref),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth >= 520
                          ? 3
                          : constraints.maxWidth >= 340
                              ? 2
                              : 1;
                      if (cols == 1) {
                        return ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: child,
                            );
                          },
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final repo = ref.read(projectsRepositoryProvider);
                            await repo.reorder(
                              projects[oldIndex].id,
                              newIndex,
                            );
                          },
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return Padding(
                              key: ValueKey(project.id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProjectCardSlot(
                                project: project,
                                selected: embedded && selectedId == project.id,
                                onTap: () {
                                  ref
                                      .read(selectedProjectIdProvider.notifier)
                                      .state = project.id;
                                  onProjectSelected?.call(project);
                                },
                                onLongPress: () => _showProjectActions(
                                  context,
                                  ref,
                                  project,
                                  projects,
                                ),
                                onDrop: (payloads) => openCaptureForDrop(
                                  context,
                                  ref,
                                  payloads: payloads,
                                  targetProjectId: project.id,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return MasonryGridView.count(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        crossAxisCount: cols,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return _ProjectCardSlot(
                            project: project,
                            selected: embedded && selectedId == project.id,
                            onTap: () {
                              ref
                                  .read(selectedProjectIdProvider.notifier)
                                  .state = project.id;
                              onProjectSelected?.call(project);
                            },
                            onLongPress: () => _showProjectActions(
                              context,
                              ref,
                              project,
                              projects,
                            ),
                            onDrop: (payloads) => openCaptureForDrop(
                              context,
                              ref,
                              payloads: payloads,
                              targetProjectId: project.id,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final draft = await showProjectEditorSheet(context);
    if (draft == null) return;
    final repo = ref.read(projectsRepositoryProvider);
    final project = await repo.create(
      title: draft.title,
      researchQuestion: draft.researchQuestion,
      field: draft.field,
      description: draft.description,
      colorValue: draft.colorValue,
    );
    ref.read(selectedProjectIdProvider.notifier).state = project.id;
    onProjectSelected?.call(project);
  }

  Future<void> _showProjectActions(
    BuildContext context,
    WidgetRef ref,
    Project project,
    List<Project> all,
  ) async {
    final index = all.indexWhere((p) => p.id == project.id);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: CortexColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: CortexColors.hairline),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: CortexColors.accent),
              title: Text('Edit project', style: CortexTheme.body()),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            if (index > 0)
              ListTile(
                leading:
                    const Icon(Icons.arrow_upward, color: CortexColors.muted),
                title: Text('Move up', style: CortexTheme.body()),
                onTap: () => Navigator.pop(ctx, 'up'),
              ),
            if (index >= 0 && index < all.length - 1)
              ListTile(
                leading:
                    const Icon(Icons.arrow_downward, color: CortexColors.muted),
                title: Text('Move down', style: CortexTheme.body()),
                onTap: () => Navigator.pop(ctx, 'down'),
              ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: CortexColors.danger),
              title: Text(
                'Delete project',
                style: CortexTheme.body(color: CortexColors.danger),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    final repo = ref.read(projectsRepositoryProvider);
    if (!context.mounted) return;

    if (action == 'edit') {
      final draft = await showProjectEditorSheet(
        context,
        initialTitle: project.title,
        initialResearchQuestion: project.researchQuestion,
        initialField: project.field,
        initialDescription: project.description,
        initialColor: project.colorValue,
        confirmLabel: 'SAVE',
      );
      if (draft == null) return;
      await repo.update(
        project,
        title: draft.title,
        researchQuestion: draft.researchQuestion,
        field: draft.field,
        description: draft.description,
        colorValue: draft.colorValue,
      );
    } else if (action == 'up' && index > 0) {
      await repo.reorder(project.id, index - 1);
    } else if (action == 'down' && index >= 0 && index < all.length - 1) {
      await repo.reorder(project.id, index + 1);
    } else if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('DELETE PROJECT'),
          content: Text(
            'Delete "${project.title}" and all of its items and claims? This cannot be undone.',
            style: CortexTheme.body(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('CANCEL', style: CortexTheme.mono()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'DELETE',
                style: CortexTheme.mono(color: CortexColors.danger),
              ),
            ),
          ],
        ),
      );
      if (ok == true) {
        final selected = ref.read(selectedProjectIdProvider);
        await repo.delete(project);
        if (selected == project.id) {
          ref.read(selectedProjectIdProvider.notifier).state = null;
        }
      }
    }
  }
}

final _searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: ref.read(projectQueryProvider));
  ref.onDispose(controller.dispose);
  return controller;
});

class _ProjectCardSlot extends ConsumerWidget {
  const _ProjectCardSlot({
    required this.project,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onDrop,
  });

  final Project project;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final CaptureDropHandler onDrop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(projectsRepositoryProvider);

    return CortexDropRegion(
      borderRadius: 16,
      hitTestBehavior: HitTestBehavior.opaque,
      enableHudFx: false,
      onPayloads: onDrop,
      child: FutureBuilder<(int, Set<ResearchStage>)>(
        future: () async {
          final count = await repo.itemCount(project);
          final ordinals = await repo.occupiedStageOrdinals(project);
          final stages = {
            for (final o in ordinals) ResearchStage.values[o],
          };
          return (count, stages);
        }(),
        builder: (context, snap) {
          return ProjectCard(
            project: project,
            itemCount: snap.data?.$1 ?? 0,
            occupiedStages: snap.data?.$2 ?? const {},
            selected: selected,
            onTap: onTap,
            onLongPress: onLongPress,
          );
        },
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NO PROJECTS',
              style:
                  CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
            ),
            const SizedBox(height: 12),
            Text(
              'No active research. Initialize a project to begin.',
              textAlign: TextAlign.center,
              style: CortexTheme.body(color: CortexColors.muted),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: CortexColors.accent,
                foregroundColor: CortexColors.background,
              ),
              child: Text(
                'NEW PROJECT',
                style: CortexTheme.orbitron(
                  fontSize: 12,
                  color: CortexColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
