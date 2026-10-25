import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/project.dart';
import '../../providers/projects_provider.dart';
import '../../theme/cortex_colors.dart';
import '../projects/project_workspace.dart';
import '../projects/projects_pane.dart';
import '../search/global_search.dart';
import '../settings/settings_page.dart';

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
      ProjectsPane(
        onProjectSelected: (project) => _openWorkspace(context, project),
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
            label: 'Projects',
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

  void _openWorkspace(BuildContext context, Project project) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondary) {
          return FadeTransition(
            opacity: animation,
            child: const ProjectWorkspace(showBack: true),
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
    ref.watch(selectedProjectIdProvider);

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
            child: const ProjectsPane(embedded: true),
          ),
          Container(width: 1, color: CortexColors.hairline),
          const Expanded(child: ProjectWorkspace()),
        ],
      ),
      bottomNavigationBar:
          _WideNav(tabIndex: tabIndex, onTabChanged: onTabChanged),
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
          label: 'Projects',
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
