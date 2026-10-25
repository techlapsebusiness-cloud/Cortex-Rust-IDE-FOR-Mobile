import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/project.dart';
import '../../data/models/research_item.dart';
import '../../providers/items_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/search_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../feed/item_detail.dart';
import '../feed/widgets/item_card.dart';

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(globalSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeFilter = ref.watch(globalSearchTypeProvider);
    final tagFilter = ref.watch(globalSearchTagProvider);
    final tags = ref.watch(tagsIndexProvider).valueOrNull ?? [];
    final results = ref.watch(globalSearchProvider);

    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'SEARCH',
          style: CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: CortexTheme.mono(fontSize: 14, color: CortexColors.text),
              decoration: const InputDecoration(
                hintText: 'Notes, tags, titles, URLs…',
                prefixIcon: Icon(Icons.search, color: CortexColors.muted),
              ),
              onChanged: (v) {
                ref.read(globalSearchQueryProvider.notifier).state = v;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in FeedFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        _typeLabel(f),
                        style: CortexTheme.mono(
                          fontSize: 11,
                          color: typeFilter == f
                              ? CortexColors.background
                              : CortexColors.muted,
                        ),
                      ),
                      selected: typeFilter == f,
                      showCheckmark: false,
                      selectedColor: CortexColors.accent,
                      backgroundColor: CortexColors.surface,
                      side: const BorderSide(color: CortexColors.hairline),
                      onSelected: (_) {
                        ref.read(globalSearchTypeProvider.notifier).state = f;
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (tags.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        'ALL TAGS',
                        style: CortexTheme.mono(
                          fontSize: 11,
                          color: tagFilter == null
                              ? CortexColors.background
                              : CortexColors.muted,
                        ),
                      ),
                      selected: tagFilter == null,
                      showCheckmark: false,
                      selectedColor: CortexColors.secondaryGlow,
                      backgroundColor: CortexColors.surface,
                      side: const BorderSide(color: CortexColors.hairline),
                      onSelected: (_) {
                        ref.read(globalSearchTagProvider.notifier).state = null;
                      },
                    ),
                  ),
                  for (final tag in tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          '#$tag',
                          style: CortexTheme.mono(
                            fontSize: 11,
                            color: tagFilter == tag
                                ? CortexColors.background
                                : CortexColors.secondaryGlow,
                          ),
                        ),
                        selected: tagFilter == tag,
                        showCheckmark: false,
                        selectedColor: CortexColors.secondaryGlow,
                        backgroundColor: CortexColors.surface,
                        side: const BorderSide(color: CortexColors.hairline),
                        onSelected: (_) {
                          ref.read(globalSearchTagProvider.notifier).state =
                              tagFilter == tag ? null : tag;
                        },
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: CortexColors.accent),
              ),
              error: (e, _) => Center(
                child: Text(
                  '$e',
                  style: CortexTheme.mono(color: CortexColors.danger),
                ),
              ),
              data: (data) {
                final hasQuery =
                    ref.watch(globalSearchQueryProvider).trim().isNotEmpty;
                final hasFilter =
                    typeFilter != FeedFilter.all || tagFilter != null;
                if (!hasQuery && !hasFilter) {
                  return Center(
                    child: Text(
                      'SEARCH PROJECTS & CAPTURES',
                      style: CortexTheme.orbitron(
                        fontSize: 13,
                        color: CortexColors.muted,
                      ),
                    ),
                  );
                }
                if (data.projectHits.isEmpty && data.groupedItems.isEmpty) {
                  return Center(
                    child: Text(
                      'NO MATCHES',
                      style: CortexTheme.orbitron(
                        fontSize: 13,
                        color: CortexColors.muted,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    if (data.projectHits.isNotEmpty) ...[
                      Text(
                        'PROJECTS',
                        style: CortexTheme.orbitron(
                          fontSize: 12,
                          color: CortexColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final p in data.projectHits)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 4,
                            height: 28,
                            color: Color(p.colorValue),
                          ),
                          title: Text(
                            p.title.toUpperCase(),
                            style: CortexTheme.orbitron(fontSize: 12),
                          ),
                          subtitle: p.researchQuestion.isNotEmpty
                              ? Text(
                                  p.researchQuestion,
                                  style: CortexTheme.mono(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () {
                            ref.read(selectedProjectIdProvider.notifier).state =
                                p.id;
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                    for (final entry in data.groupedItems.entries) ...[
                      Text(
                        entry.key.title.toUpperCase(),
                        style: CortexTheme.orbitron(
                          fontSize: 12,
                          color: Color(entry.key.colorValue),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final item in entry.value) ...[
                        ItemCard(
                          item: item,
                          onTap: () => _openItem(context, item, entry.key),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openItem(BuildContext context, ResearchItem item, Project project) {
    ref.read(selectedProjectIdProvider.notifier).state = project.id;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondary) {
          return FadeTransition(
            opacity: animation,
            child: ItemDetailPage(itemId: item.id),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  String _typeLabel(FeedFilter f) => switch (f) {
        FeedFilter.all => 'ALL',
        FeedFilter.text => 'TEXT',
        FeedFilter.links => 'LINKS',
        FeedFilter.images => 'IMAGES',
        FeedFilter.videos => 'VIDEOS',
        FeedFilter.files => 'FILES',
      };
}
