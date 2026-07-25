import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/topic.dart';
import '../../providers/items_provider.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../../widgets/hud_brackets.dart';
import 'item_detail.dart';
import 'manual_add_sheet.dart';
import 'widgets/item_card.dart';

class TopicFeed extends ConsumerStatefulWidget {
  const TopicFeed({
    super.key,
    this.showBack = false,
  });

  final bool showBack;

  @override
  ConsumerState<TopicFeed> createState() => _TopicFeedState();
}

class _TopicFeedState extends ConsumerState<TopicFeed> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(selectedTopicProvider);

    return topicAsync.when(
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
      data: (topic) {
        if (topic == null) {
          return Scaffold(
            backgroundColor: CortexColors.background,
            appBar: widget.showBack ? AppBar() : null,
            body: Center(
              child: Text(
                'SELECT A TOPIC',
                style: CortexTheme.orbitron(
                  fontSize: 14,
                  color: CortexColors.muted,
                ),
              ),
            ),
          );
        }
        return _FeedBody(
          topic: topic,
          showBack: widget.showBack,
          searchController: _searchController,
        );
      },
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({
    required this.topic,
    required this.showBack,
    required this.searchController,
  });

  final Topic topic;
  final bool showBack;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Color(topic.colorValue);
    final filter = ref.watch(feedFilterProvider(topic.id));
    final itemsAsync = ref.watch(filteredTopicItemsProvider(topic.id));

    return Scaffold(
      backgroundColor: CortexColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showManualAddSheet(context, topic: topic),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    topic.title.toUpperCase(),
                    style: CortexTheme.orbitron(
                      fontSize: 14,
                      color: CortexColors.text,
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(96),
                child: Column(
                  children: [
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
                                side: const BorderSide(color: CortexColors.hairline),
                                onSelected: (_) {
                                  ref
                                      .read(
                                        feedFilterProvider(topic.id).notifier,
                                      )
                                      .state = f;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: TextField(
                        controller: searchController,
                        style: CortexTheme.mono(fontSize: 13, color: CortexColors.text),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Filter in topic…',
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: CortexColors.muted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (v) {
                          ref.read(feedQueryProvider(topic.id).notifier).state = v;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: itemsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CortexColors.accent),
          ),
          error: (e, _) => Center(
            child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyFeed();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onTap: () {
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
                  },
                );
              },
            );
          },
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

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

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
