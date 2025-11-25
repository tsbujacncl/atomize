import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/preferences_provider.dart';
import 'presentation/providers/score_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_flow.dart';

class AtomizeApp extends ConsumerWidget {
  const AtomizeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from preferences
    final themeModeAsync = ref.watch(currentThemeModeProvider);
    final themeMode = themeModeAsync.when(
      data: (mode) => _parseThemeMode(mode),
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp(
      title: 'Atomize',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _AppHome(),
    );
  }

  ThemeMode _parseThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

/// Handles initial routing based on onboarding status.
class _AppHome extends ConsumerWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth (anonymous sign-in if needed)
    final authInitAsync = ref.watch(authInitializationProvider);

    // Initialize connectivity and sync
    final syncInitAsync = ref.watch(syncInitProvider);

    final onboardingCompletedAsync = ref.watch(isOnboardingCompletedProvider);

    // Show loading while auth initializes
    return authInitAsync.when(
      data: (_) => syncInitAsync.when(
        data: (_) => onboardingCompletedAsync.when(
          data: (isCompleted) {
            if (isCompleted) {
              // Trigger day boundary decay check for returning users
              ref.watch(dayBoundaryDecayProvider);
              return const HomeScreen();
            } else {
              return const OnboardingFlow();
            }
          },
          loading: () => _buildLoadingScreen(),
          error: (error, _) => _buildErrorScreen(error),
        ),
        loading: () => _buildLoadingScreen(),
        error: (error, _) {
          // Sync error is not fatal - continue without sync
          return onboardingCompletedAsync.when(
            data: (isCompleted) {
              if (isCompleted) {
                ref.watch(dayBoundaryDecayProvider);
                return const HomeScreen();
              } else {
                return const OnboardingFlow();
              }
            },
            loading: () => _buildLoadingScreen(),
            error: (error, _) => _buildErrorScreen(error),
          );
        },
      ),
      loading: () => _buildLoadingScreen(),
      error: (error, _) {
        // Auth error is not fatal - continue without sync
        return onboardingCompletedAsync.when(
          data: (isCompleted) {
            if (isCompleted) {
              ref.watch(dayBoundaryDecayProvider);
              return const HomeScreen();
            } else {
              return const OnboardingFlow();
            }
          },
          loading: () => _buildLoadingScreen(),
          error: (error, _) => _buildErrorScreen(error),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
