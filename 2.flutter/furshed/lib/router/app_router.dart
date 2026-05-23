import 'package:flutter/material.dart';
import 'package:furshed/screens/home_screen.dart';
import 'package:furshed/screens/schedule_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/schedule/:entityType/:entityId',
        name: 'schedule',
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
