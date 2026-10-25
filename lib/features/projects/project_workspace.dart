import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/claim.dart';
import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../data/models/research_item.dart';
import '../../fx/drag_fx_controller.dart';
import '../../fx/materialize_card.dart';
import '../../providers/claims_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/projects_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../../widgets/hud_brackets.dart';
import '../capture/cortex_drop_region.dart';
import '../capture/quick_capture.dart';
import '../feed/item_detail.dart';
import '../feed/manual_add_sheet.dart';
import '../feed/widgets/item_card.dart';
import 'claims_panel.dart';

class ProjectWorkspace extends ConsumerStatefulWidget {
  const ProjectWorkspace({
    super.key,
    this.showBack = false,
  });

  final bool showBack;

  @override
  ConsumerState<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends ConsumerState<ProjectWorkspace> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(selectedProjectProvider);

    return projectAsync.when(
      loading: () => const Scaffold(
        backgroundColor: CortexColors.background,
        body: Center(
          child: CircularProgressIndicator(color: CortexColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: CortexColors.background,
        body: Center(
          child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            backgroundColor: CortexColors.background,
            appBar: widget.showBack ? AppBar() : null,
            body: Center(
              child: Text(
                'SELECT A PROJECT',
                style: CortexTheme.orbitron(
                  fontSize: 14,
                  color: CortexColors.muted,
                ),
              ),
            ),
          );
        }
        return _WorkspaceBody(
          project: project,
          showBack: widget.showBack,
          searchController: _searchController,
        );
      },
    );
  }
}

class _WorkspaceBody extends ConsumerWidget {
  const _WorkspaceBody({
    required this.project,
    required this.showBack,
    required this.searchController,
  });

  final Project project;
  final bool showBack;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Color(project.colorValue);
    final selectedStage = ref.watch(selectedStageProvider(project.id));
    final captureStage = selectedStage ?? ResearchStage.evidence;
    final filter = ref.watch(feedFilterProvider(project.id));
    final tagFilter = ref.watch(feedTagFilterProvider(project.id));
    final allItems =
        ref.watch(projectItemsProvider(project.id)).valueOrNull ?? [];
    final projectTags = {
      for (final i in allItems) ...i.tags.map((t) => t.toLowerCase()),
    }.toList()
      ..sort();
    final itemsAsync = ref.watch(filteredProjectItemsProvider(project.id));
    final isOverview = selectedStage == null;
    final headerHeight =
        isOverview ? 56.0 : (projectTags.isEmpty ? 112.0 : 156.0);

    return CortexDropRegion(
      onPayloads: (payloads) => quickAddWithUndo(
        context,
        ref,
        project: project,
        payloads: payloads,
        stage: captureStage,
      ),
      child: Scaffold(
        backgroundColor: CortexColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showManualAddSheet(
            context,
            project: project,
            stage: captureStage,
          ),
          child: const Icon(Icons.add),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: showBack,
                backgroundColor: CortexColors.background,
                title: HudBrackets(
                  color: accent,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      project.title.toUpperCase(),
                      style: CortexTheme.orbitron(
                        fontSize: 14,
                        color: CortexColors.text,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Claims',
                    icon: const Icon(Icons.account_tree_outlined,
                        color: CortexColors.muted),
                    onPressed: () =>
                        showClaimsPanel(context, project: project),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(headerHeight),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(
                                  'OVERVIEW',
                                  style: CortexTheme.mono(
                                    fontSize: 11,
                                    color: isOverview
                                        ? CortexColors.background
                                        : CortexColors.muted,
                                  ),
                                ),
                                selected: isOverview,
                                showCheckmark: false,
                                selectedColor: accent,
                                backgroundColor: CortexColors.surface,
                                side: BorderSide(
                                  color: isOverview
                                      ? accent.withValues(alpha: 0.5)
                                      : CortexColors.hairline,
                                ),
                                onSelected: (_) {
                                  ref
                                      .read(
                                        selectedStageProvider(project.id)
                                            .notifier,
                                      )
                                      .state = null;
                                },
                              ),
                            ),
                            for (final stage in ResearchStage.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  label: Text(
                                    stage.shortLabel,
                                    style: CortexTheme.mono(
                                      fontSize: 11,
                                      color: selectedStage == stage
                                          ? CortexColors.background
                                          : CortexColors.muted,
                                    ),
                                  ),
                                  selected: selectedStage == stage,
                                  showCheckmark: false,
                                  selectedColor: accent,
                                  backgroundColor: CortexColors.surface,
                                  side: BorderSide(
                                    color: selectedStage == stage
                                        ? accent.withValues(alpha: 0.5)
                                        : CortexColors.hairline,
                                  ),
                                  onSelected: (_) {
                                    ref
                                        .read(
                                          selectedStageProvider(project.id)
                                              .notifier,
                                        )
                                        .state = stage;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isOverview) ...[
                        if (projectTags.isNotEmpty)
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              children: [
                                for (final tag in projectTags)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        '#$tag',
                                        style: CortexTheme.mono(
                                          fontSize: 10,
                                          color: tagFilter == tag
                                              ? CortexColors.background
                                              : CortexColors.secondaryGlow,
                                        ),
                                      ),
                                      selected: tagFilter == tag,
                                      showCheckmark: false,
                                      selectedColor: CortexColors.secondaryGlow,
                                      backgroundColor: CortexColors.surface,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: const BorderSide(
                                        color: CortexColors.hairline,
                                      ),
                                      onSelected: (_) {
                                        ref
                                            .read(
                                              feedTagFilterProvider(project.id)
                                                  .notifier,
                                            )
                                            .state =
                                            tagFilter == tag ? null : tag;
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: TextField(
                            controller: searchController,
                            style: CortexTheme.mono(
                              fontSize: 13,
                              color: CortexColors.text,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Filter in ${selectedStage.label}…',
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: CortexColors.muted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (v) {
                              ref
                                  .read(feedQueryProvider(project.id).notifier)
                                  .state = v;
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
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    label: Text(
                                      _filterLabel(f),
                                      style: CortexTheme.mono(
                                        fontSize: 11,
                                        color: filter == f
                                            ? CortexColors.background
                                            : CortexColors.muted,
                                      ),
                                    ),
                                    selected: filter == f,
                                    showCheckmark: false,
                                    selectedColor: CortexColors.accent,
                                    backgroundColor: CortexColors.surface,
                                    side: const BorderSide(
                                      color: CortexColors.hairline,
                                    ),
                                    onSelected: (_) {
                                      ref
                                          .read(
                                            feedFilterProvider(project.id)
                                                .notifier,
                                          )
                                          .state = f;
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ];
          },
          body: isOverview
              ? _OverviewTab(project: project, accent: accent)
              : _StageItemsTab(
                  project: project,
                  stage: selectedStage,
                  itemsAsync: itemsAsync,
                ),
        ),
      ),
    );
  }

  String _filterLabel(FeedFilter f) => switch (f) {
        FeedFilter.all => 'ALL',
        FeedFilter.text => 'TEXT',
        FeedFilter.links => 'LINKS',
        FeedFilter.images => 'IMAGES',
        FeedFilter.videos => 'VIDEOS',
        FeedFilter.files => 'FILES',
      };
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.project, required this.accent});

  final Project project;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(projectClaimsProvider(project.id));
    final allItems =
        ref.watch(projectItemsProvider(project.id)).valueOrNull ?? [];
    final occupied = {
      for (final i in allItems) i.stage,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (project.researchQuestion.isNotEmpty) ...[
          Text(
            'RESEARCH QUESTION',
            style: CortexTheme.orbitron(fontSize: 11, color: CortexColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            project.researchQuestion,
            style: CortexTheme.mono(fontSize: 13, color: CortexColors.text),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'STAGE PROGRESS',
          style: CortexTheme.orbitron(fontSize: 11, color: CortexColors.muted),
        ),
        const SizedBox(height: 10),
        _StageProgressBar(occupied: occupied, accent: accent),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'CLAIMS',
              style:
                  CortexTheme.orbitron(fontSize: 11, color: CortexColors.muted),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => showClaimsPanel(context, project: project),
              child: Text(
                'MANAGE',
                style: CortexTheme.mono(fontSize: 11, color: accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        claimsAsync.when(
          loading: () => const LinearProgressIndicator(
            color: CortexColors.accent,
            backgroundColor: CortexColors.surface,
          ),
          error: (e, _) => Text(
            '$e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
          data: (claims) {
            if (claims.isEmpty) {
              return Text(
                'No claims yet — add hypotheses to track evidence balance.',
                style: CortexTheme.body(color: CortexColors.muted, fontSize: 13),
              );
            }
            return Column(
              children: [
                for (final claim in claims.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OverviewClaimChip(claim: claim),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.occupied, required this.accent});

  final Set<ResearchStage> occupied;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final stage in ResearchStage.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Tooltip(
                message: stage.label,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: occupied.contains(stage)
                        ? accent
                        : CortexColors.elevated,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OverviewClaimChip extends StatelessWidget {
  const _OverviewClaimChip({required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EvidenceBalance>(
      future: () async {
        await claim.evidence.load();
        return EvidenceBalance.fromEvidence(claim.evidence);
      }(),
      builder: (context, snap) {
        final balance = snap.data;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CortexColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CortexColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                claim.statement,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CortexTheme.body(fontSize: 13),
              ),
              if (balance != null) ...[
                const SizedBox(height: 6),
                Text(
                  '▲ ${balance.supports} · ▼ ${balance.refutes} · ${claim.confidence}%',
                  style: CortexTheme.mono(fontSize: 10, color: CortexColors.muted),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StageItemsTab extends ConsumerWidget {
  const _StageItemsTab({
    required this.project,
    required this.stage,
    required this.itemsAsync,
  });

  final Project project;
  final ResearchStage stage;
  final AsyncValue<List<ResearchItem>> itemsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stage == ResearchStage.reference) {
      final refsAsync = ref.watch(projectReferencesProvider(project.id));
      return refsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CortexColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
        ),
        data: (refs) {
          if (refs.isEmpty) {
            return const _EmptyStage();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: refs.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = refs[index];
              return ListTile(
                tileColor: CortexColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: CortexColors.hairline),
                ),
                title: Text(
                  item.previewTitle ?? item.sourceUrl ?? item.citation ?? 'Ref',
                  style: CortexTheme.body(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.citation ?? item.sourceUrl ?? '',
                  style: CortexTheme.mono(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openItem(context, item),
              );
            },
          );
        },
      );
    }

    return itemsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CortexColors.accent),
      ),
      error: (e, _) => Center(
        child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyStage();
        }
        final materializeIds =
            ref.watch(dragFxProvider.select((s) => s.materializeItemIds));
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final assemble = materializeIds.contains(item.id);
            final card = ItemCard(
              item: item,
              onTap: () => _openItem(context, item),
            );
            if (assemble) {
              return MaterializeCard(
                key: ValueKey('mat-${item.id}'),
                onComplete: () {
                  ref.read(dragFxProvider.notifier).clearMaterialize(item.id);
                },
                child: card,
              );
            }
            return TweenAnimationBuilder<double>(
              key: ValueKey(item.id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: card,
            );
          },
        );
      },
    );
  }

  void _openItem(BuildContext context, ResearchItem item) {
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
}

class _EmptyStage extends StatelessWidget {
  const _EmptyStage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              painter: _ScanGridPainter(),
              child: const SizedBox(width: 220, height: 120),
            ),
            const SizedBox(height: 20),
            Text(
              'Share or drag research here.',
              textAlign: TextAlign.center,
              style: CortexTheme.orbitron(
                fontSize: 13,
                color: CortexColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use + to add a note, link, image, or file.',
              textAlign: TextAlign.center,
              style: CortexTheme.body(color: CortexColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    const step = 16.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final border = Paint()
      ..color = CortexColors.accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
