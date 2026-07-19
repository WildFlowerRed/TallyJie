import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/capsule_nav_bar.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/ledger/presentation/pages/ledger_page.dart';
import '../features/statistics/presentation/pages/statistics_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/diary',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                pageBuilder: (c, s) =>
                    const NoTransitionPage(child: DiaryPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                pageBuilder: (c, s) =>
                    const NoTransitionPage(child: LedgerPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                pageBuilder: (c, s) =>
                    const NoTransitionPage(child: StatisticsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell shell;

  const _ShellScaffold({required this.shell});

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  void _goToBranch(int index) {
    if (index < 0 || index > 2 || index == widget.shell.currentIndex) return;
    if (index == 2) {
      StatisticsPageNavigation.requestMainPage();
    }
    widget.shell.goBranch(
      index,
      initialLocation: index == 0 || index == widget.shell.currentIndex,
    );
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 320) return;
    final current = widget.shell.currentIndex;
    if (velocity > 0) {
      _goToBranch(current - 1);
    } else {
      _goToBranch(current + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.shell.currentIndex;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          CapsuleNavBar(
            selectedIndex: currentIndex,
            onTap: _goToBranch,
            onSettingsTap: () => showSettingsDialog(context),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: _handleSwipe,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: widget.shell,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
