import 'package:flutter/material.dart';
import 'package:furshed/screens/home_screen.dart';
import 'package:furshed/screens/proxy_demo_screen.dart';
import 'package:furshed/screens/schedule_screen.dart';
import 'package:furshed/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/proxy',
                name: 'proxy',
                builder: (context, state) => const ProxyDemoScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/schedule/:entityType/:entityId',
        name: 'schedule',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.extra as String?;
          return ScheduleScreen(
            entityType: state.pathParameters['entityType']!,
            entityId: state.pathParameters['entityId']!,
            title: title,
          );
        },
      ),
    ],
  );
}
