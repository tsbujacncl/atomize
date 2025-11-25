import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/preferences_provider.dart';
import '../create_habit/create_habit_screen.dart';
import '../home/home_screen.dart';
import '../settings/account_screen.dart';
import 'tutorial_screen.dart';
import 'welcome_screen.dart';

/// Enum representing the current step in onboarding.
enum OnboardingStep {
  welcome,
  signIn,
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

  void _goToSignIn() {
    setState(() {
      _currentStep = OnboardingStep.signIn;
    });
  }

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

  /// Called after successful sign-in - check if user has habits synced
  Future<void> _onSignInComplete() async {
    final authService = ref.read(authServiceProvider);
    if (authService != null && !authService.isAnonymous) {
      // User signed in successfully - complete onboarding and go to home
      await _completeOnboarding();
    } else {
      // Still anonymous, go back to welcome
      setState(() {
        _currentStep = OnboardingStep.welcome;
      });
    }
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
          onSignIn: _goToSignIn,
        ),
      OnboardingStep.signIn => _SignInWrapper(
          onBack: () => setState(() => _currentStep = OnboardingStep.welcome),
          onSignInComplete: _onSignInComplete,
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

/// Wrapper for AccountScreen during onboarding.
class _SignInWrapper extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignInComplete;

  const _SignInWrapper({
    required this.onBack,
    required this.onSignInComplete,
  });

  @override
  ConsumerState<_SignInWrapper> createState() => _SignInWrapperState();
}

class _SignInWrapperState extends ConsumerState<_SignInWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen for auth changes
    _checkAuthState();
  }

  void _checkAuthState() {
    final authService = ref.read(authServiceProvider);
    authService?.onAuthStateChange.listen((state) {
      if (mounted && !authService.isAnonymous) {
        widget.onSignInComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope to handle back navigation
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: const AccountScreen(),
    );
  }
}
