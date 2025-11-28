import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../widgets/atomize_logo.dart';

/// The first onboarding screen - Welcome.
///
/// Shows the Atomize logo prominently with tagline and get started button.
class WelcomeScreen extends StatelessWidget {
  /// Callback when user taps "Get Started"
  final VoidCallback onGetStarted;

  /// Callback when user taps "Sign in" (for returning users)
  final VoidCallback? onSignIn;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo (centered)
              const Center(child: AtomizeLogoLarge()),

              const Gap(24),

              // Tagline
              Text(
                'Small habits. Big change.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),

              const Gap(48),

              // Get Started button
              FilledButton(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('Get Started'),
              ),

              const Gap(16),

              // Sign in link (for returning users)
              TextButton(
                onPressed: onSignIn,
                child: Text(
                  'Already have an account? Sign in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
