import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:manganku_app/features/home/presentation/home_page.dart';
import 'package:manganku_app/features/preview/presentation/preview_page.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String previewRoute = '/preview';

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    routes: [
      GoRoute(
        path: homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: previewRoute,
        name: 'preview',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return PreviewPage(imagePath: imagePath);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(homeRoute),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
