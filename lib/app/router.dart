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
        builder: (context, state, shell) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              CapsuleNavBar(
                selectedIndex: shell.currentIndex,
                onTap: (i) {
                  if (i == 2) {
                    StatisticsPageNavigation.requestMainPage();
                  }
                  shell.goBranch(
                    i,
                    initialLocation: i == 0 || i == shell.currentIndex,
                  );
                },
                onSettingsTap: () => showSettingsDialog(context),
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: shell,
                ),
              ),
            ],
          ),
        ),
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
