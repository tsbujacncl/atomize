import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/preferences_provider.dart';
import 'presentation/providers/score_provider.dart';
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
    final onboardingCompletedAsync = ref.watch(isOnboardingCompletedProvider);

    return onboardingCompletedAsync.when(
      data: (isCompleted) {
        if (isCompleted) {
          // Trigger day boundary decay check for returning users
          // This runs in the background and doesn't block the UI
          ref.watch(dayBoundaryDecayProvider);
          return const HomeScreen();
        } else {
          return const OnboardingFlow();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
