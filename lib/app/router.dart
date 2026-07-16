import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/capsule_nav_bar.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/ledger/presentation/pages/ledger_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/book/presentation/pages/book_page.dart';
import '../features/statistics/presentation/pages/statistics_page.dart';

/// App 路由配置
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/diary',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: CapsuleNavBar(
              selectedIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },
        branches: [
          // 日记
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DiaryPage(),
                ),
              ),
            ],
          ),
          // 记账
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LedgerPage(),
                ),
              ),
            ],
          ),
          // 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
                routes: [
                  GoRoute(
                    path: 'statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _buildTransitionPage(
                      const StatisticsPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'book',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _buildTransitionPage(
                      const BookPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static Page _buildTransitionPage(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
