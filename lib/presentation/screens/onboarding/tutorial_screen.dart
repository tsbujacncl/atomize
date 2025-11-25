import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../widgets/flame_widget.dart';

/// Tutorial screen (onboarding step 3) - Shows how to tap flame to complete.
class TutorialScreen extends StatefulWidget {
  /// Callback when user taps "Got it"
  final VoidCallback onComplete;

  const TutorialScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  double _demoScore = 15.0; // Start with a blue flame (new habit)
  bool _hasCompleted = false;

  void _onFlameTapped() {
    if (_hasCompleted) return;

    setState(() {
      _demoScore = 45.0; // Move to orange gradient
      _hasCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              Text(
                'How it works',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Gap(48),

              // Demo habit card
              _DemoHabitCard(
                score: _demoScore,
                isCompleted: _hasCompleted,
                onFlameTap: _onFlameTapped,
              ),

              const Gap(32),

              // Instruction text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _hasCompleted
                    ? Text(
                        'Your flame grows warmer each time you complete a habit.',
                        key: const ValueKey('completed'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      )
                    : Text(
                        'Tap the flame when you\'ve done it.',
                        key: const ValueKey('instruction'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
              ),

              const Spacer(flex: 3),

              // Got it button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onComplete,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Got it'),
                  ),
                ),
              ),

              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

/// A demo habit card for the tutorial.
class _DemoHabitCard extends StatelessWidget {
  final double score;
  final bool isCompleted;
  final VoidCallback onFlameTap;

  const _DemoHabitCard({
    required this.score,
    required this.isCompleted,
    required this.onFlameTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flame button
          GestureDetector(
            onTap: onFlameTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              child: Center(
                child: FlameWidget(
                  score: score,
                  size: 32,
                ),
              ),
            ),
          ),

          const Gap(16),

          // Habit info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Morning yoga',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.textTheme.bodySmall?.color
                        : null,
                  ),
                ),
                const Gap(4),
                Text(
                  '7:00 AM',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isCompleted
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('check'),
                        color: colorScheme.primary,
                        size: 20,
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        width: 20,
                        height: 20,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
