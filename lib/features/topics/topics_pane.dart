import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/topic.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import 'topic_card.dart';
import 'topic_editor_sheet.dart';

class TopicsPane extends ConsumerWidget {
  const TopicsPane({
    super.key,
    this.embedded = false,
    this.onTopicSelected,
  });

  /// When true (two-pane), selection stays in-shell instead of pushing a route.
  final bool embedded;
  final ValueChanged<Topic>? onTopicSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final selectedId = ref.watch(selectedTopicIdProvider);

    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'CORTEX',
          style: CortexTheme.orbitron(fontSize: 18, color: CortexColors.accent),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTopic(context, ref),
        child: const Icon(Icons.add),
      ),
      body: topicsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CortexColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'DB ERROR: $e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
        data: (topics) {
          if (topics.isEmpty) {
            return _EmptyTopics(onCreate: () => _createTopic(context, ref));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 520
                  ? 3
                  : constraints.maxWidth >= 340
                      ? 2
                      : 1;
              // Drag-reorder when single column; grid otherwise.
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
                    final repo =
                        ref.read(topicsRepositoryProvider).valueOrNull;
                    if (repo == null) return;
                    await repo.reorder(topics[oldIndex].id, newIndex);
                  },
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return Padding(
                      key: ValueKey(topic.id),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TopicCardSlot(
                        topic: topic,
                        selected: embedded && selectedId == topic.id,
                        onTap: () {
                          ref.read(selectedTopicIdProvider.notifier).state =
                              topic.id;
                          onTopicSelected?.call(topic);
                        },
                        onLongPress: () =>
                            _showTopicActions(context, ref, topic, topics),
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
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return _TopicCardSlot(
                    topic: topic,
                    selected: embedded && selectedId == topic.id,
                    onTap: () {
                      ref.read(selectedTopicIdProvider.notifier).state =
                          topic.id;
                      onTopicSelected?.call(topic);
                    },
                    onLongPress: () =>
                        _showTopicActions(context, ref, topic, topics),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createTopic(BuildContext context, WidgetRef ref) async {
    final draft = await showTopicEditorSheet(context);
    if (draft == null) return;
    final repo = ref.read(topicsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    final topic = await repo.create(
      title: draft.title,
      description: draft.description,
      colorValue: draft.colorValue,
    );
    ref.read(selectedTopicIdProvider.notifier).state = topic.id;
    onTopicSelected?.call(topic);
  }

  Future<void> _showTopicActions(
    BuildContext context,
    WidgetRef ref,
    Topic topic,
    List<Topic> all,
  ) async {
    final index = all.indexWhere((t) => t.id == topic.id);
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
              title: Text('Rename / edit', style: CortexTheme.body()),
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
                'Delete topic',
                style: CortexTheme.body(color: CortexColors.danger),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    final repo = ref.read(topicsRepositoryProvider).valueOrNull;
    if (repo == null || !context.mounted) return;

    if (action == 'edit') {
      final draft = await showTopicEditorSheet(
        context,
        initialTitle: topic.title,
        initialDescription: topic.description,
        initialColor: topic.colorValue,
        confirmLabel: 'SAVE',
      );
      if (draft == null) return;
      await repo.rename(topic, draft.title);
      await repo.updateDescription(topic, draft.description);
      await repo.setColor(topic, draft.colorValue);
    } else if (action == 'up' && index > 0) {
      await repo.reorder(topic.id, index - 1);
    } else if (action == 'down' && index >= 0 && index < all.length - 1) {
      await repo.reorder(topic.id, index + 1);
    } else if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('DELETE TOPIC'),
          content: Text(
            'Delete "${topic.title}" and all of its items? This cannot be undone.',
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
        final selected = ref.read(selectedTopicIdProvider);
        await repo.delete(topic);
        if (selected == topic.id) {
          ref.read(selectedTopicIdProvider.notifier).state = null;
        }
      }
    }
  }
}

class _TopicCardSlot extends StatelessWidget {
  const _TopicCardSlot({
    required this.topic,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Topic topic;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: () async {
        await topic.items.load();
        return topic.items.length;
      }(),
      builder: (context, snap) {
        return TopicCard(
          topic: topic,
          itemCount: snap.data ?? 0,
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        );
      },
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  const _EmptyTopics({required this.onCreate});

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
              'NO TOPICS',
              style:
                  CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a research topic to start capturing.',
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
                'CREATE TOPIC',
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
