import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/preferences_provider.dart';
import '../create_habit/create_habit_screen.dart';
import '../home/home_screen.dart';
import 'tutorial_screen.dart';
import 'welcome_screen.dart';

/// Enum representing the current step in onboarding.
enum OnboardingStep {
  welcome,
  createHabit,
  tutorial,
}

/// Orchestrates the onboarding flow.
///
/// Flow:
/// 1. Welcome Screen - "Get Started" button
/// 2. Create First Habit - Create at least one habit
/// 3. Tutorial - Learn to tap the flame
/// 4. Home Screen (onboarding complete)
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  OnboardingStep _currentStep = OnboardingStep.welcome;

  void _goToCreateHabit() {
    setState(() {
      _currentStep = OnboardingStep.createHabit;
    });
  }

  void _goToTutorial() {
    setState(() {
      _currentStep = OnboardingStep.tutorial;
    });
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed in preferences
    await ref.read(preferencesNotifierProvider.notifier).completeOnboarding();

    if (mounted) {
      // Navigate to home screen, replacing the onboarding flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentStep) {
      OnboardingStep.welcome => WelcomeScreen(
          onGetStarted: _goToCreateHabit,
          // Sign in functionality not implemented yet
          onSignIn: null,
        ),
      OnboardingStep.createHabit => CreateHabitScreen(
          onHabitCreated: _goToTutorial,
          showCloseButton: false,
        ),
      OnboardingStep.tutorial => TutorialScreen(
          onComplete: _completeOnboarding,
        ),
    };
  }
}
