import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/topic.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../feed/topic_feed.dart';
import '../search/global_search.dart';
import '../settings/settings_page.dart';
import '../topics/topics_pane.dart';

/// Breakpoint for Fold unfolded two-pane layout (§9).
const double kCortexWideBreakpoint = 840;

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kCortexWideBreakpoint;
        if (wide) {
          return _WideShell(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
          );
        }
        return _NarrowShell(
          tabIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
        );
      },
    );
  }
}

class _NarrowShell extends ConsumerWidget {
  const _NarrowShell({
    required this.tabIndex,
    required this.onTabChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = [
      TopicsPane(
        onTopicSelected: (topic) => _openFeed(context, topic),
      ),
      const GlobalSearchPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: CortexColors.background,
      body: IndexedStack(index: tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: CortexColors.surface,
        indicatorColor: CortexColors.accent.withValues(alpha: 0.15),
        selectedIndex: tabIndex,
        onDestinationSelected: onTabChanged,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, color: CortexColors.muted),
            selectedIcon: Icon(Icons.grid_view, color: CortexColors.accent),
            label: 'Topics',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, color: CortexColors.muted),
            selectedIcon: Icon(Icons.search, color: CortexColors.accent),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune, color: CortexColors.muted),
            selectedIcon: Icon(Icons.tune, color: CortexColors.accent),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _openFeed(BuildContext context, Topic topic) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondary) {
          return FadeTransition(
            opacity: animation,
            child: const TopicFeed(showBack: true),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _WideShell extends ConsumerWidget {
  const _WideShell({
    required this.tabIndex,
    required this.onTabChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep selected topic across fold/unfold via Riverpod state.
    ref.watch(selectedTopicIdProvider);

    if (tabIndex == 1) {
      return Scaffold(
        backgroundColor: CortexColors.background,
        body: const GlobalSearchPage(),
        bottomNavigationBar:
            _WideNav(tabIndex: tabIndex, onTabChanged: onTabChanged),
      );
    }
    if (tabIndex == 2) {
      return Scaffold(
        backgroundColor: CortexColors.background,
        body: const SettingsPage(),
        bottomNavigationBar:
            _WideNav(tabIndex: tabIndex, onTabChanged: onTabChanged),
      );
    }

    return Scaffold(
      backgroundColor: CortexColors.background,
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.38,
            child: const TopicsPane(embedded: true),
          ),
          Container(width: 1, color: CortexColors.hairline),
          const Expanded(child: TopicFeed()),
        ],
      ),
      bottomNavigationBar: _WideNav(tabIndex: tabIndex, onTabChanged: onTabChanged),
    );
  }
}

class _WideNav extends StatelessWidget {
  const _WideNav({required this.tabIndex, required this.onTabChanged});

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 64,
      backgroundColor: CortexColors.surface,
      indicatorColor: CortexColors.accent.withValues(alpha: 0.15),
      selectedIndex: tabIndex,
      onDestinationSelected: onTabChanged,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined, color: CortexColors.muted),
          selectedIcon: Icon(Icons.grid_view, color: CortexColors.accent),
          label: 'Topics',
        ),
        NavigationDestination(
          icon: Icon(Icons.search, color: CortexColors.muted),
          selectedIcon: Icon(Icons.search, color: CortexColors.accent),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune, color: CortexColors.muted),
          selectedIcon: Icon(Icons.tune, color: CortexColors.accent),
          label: 'Settings',
        ),
      ],
    );
  }
}
