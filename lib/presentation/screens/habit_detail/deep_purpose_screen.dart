import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../data/database/app_database.dart';
import '../../providers/habit_provider.dart';

/// Screen for editing deep purpose fields for a habit.
///
/// Shows three prompts:
/// - How does this habit make you feel?
/// - Who are you becoming?
/// - What will you achieve?
class DeepPurposeScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const DeepPurposeScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<DeepPurposeScreen> createState() => _DeepPurposeScreenState();
}

class _DeepPurposeScreenState extends ConsumerState<DeepPurposeScreen> {
  late final TextEditingController _feelingController;
  late final TextEditingController _identityController;
  late final TextEditingController _outcomeController;
  bool _isSaving = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _feelingController = TextEditingController(text: widget.habit.feelingWhy ?? '');
    _identityController = TextEditingController(text: widget.habit.identityWhy ?? '');
    _outcomeController = TextEditingController(text: widget.habit.outcomeWhy ?? '');
  }

  @override
  void dispose() {
    _feelingController.dispose();
    _identityController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.habit;
    final daysSinceCreated = DateTime.now().difference(habit.createdAt).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deepen Your Why'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      habit.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Gap(8),
                    Text(
                      "You've been building this habit for $daysSinceCreated days. "
                      "Let's connect it to something deeper.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const Gap(32),

                    // Current step content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStep(),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const Gap(16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _handleNext,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentStep < 2 ? 'Next' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFeelingStep();
      case 1:
        return _buildIdentityStep();
      case 2:
        return _buildOutcomeStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFeelingStep() {
    return _PurposeStep(
      key: const ValueKey('feeling'),
      icon: Icons.favorite_outline,
      title: 'How does this habit make you feel?',
      subtitle: 'Think about the emotions you experience during or after.',
      hint: 'e.g., Calm, energized, accomplished, peaceful...',
      examples: const [
        'Calm and centered',
        'Energized and ready',
        'Accomplished',
        'More flexible',
        'Clear-headed',
      ],
      controller: _feelingController,
    );
  }

  Widget _buildIdentityStep() {
    return _PurposeStep(
      key: const ValueKey('identity'),
      icon: Icons.person_outline,
      title: 'Who are you becoming?',
      subtitle: 'This habit is shaping your identity. Who is that person?',
      hint: 'e.g., Someone who prioritizes health...',
      examples: const [
        'Someone who takes care of their body',
        'A person who shows up for themselves',
        'A lifelong learner',
        'Someone with discipline',
        'A mindful person',
      ],
      controller: _identityController,
    );
  }

  Widget _buildOutcomeStep() {
    return _PurposeStep(
      key: const ValueKey('outcome'),
      icon: Icons.flag_outlined,
      title: 'What will you achieve?',
      subtitle: 'What concrete outcome are you working towards?',
      hint: 'e.g., Touch my toes, run a 5K...',
      examples: const [
        'Better flexibility',
        'More energy throughout the day',
        'Read 20 books this year',
        'Reduce stress and anxiety',
        'Build lasting strength',
      ],
      controller: _outcomeController,
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    // Save all fields
    setState(() => _isSaving = true);

    try {
      await ref.read(habitNotifierProvider.notifier).updateDeepPurpose(
            id: widget.habit.id,
            feelingWhy: _feelingController.text.trim().isEmpty
                ? null
                : _feelingController.text.trim(),
            identityWhy: _identityController.text.trim().isEmpty
                ? null
                : _identityController.text.trim(),
            outcomeWhy: _outcomeController.text.trim().isEmpty
                ? null
                : _outcomeController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purpose saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate saved
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// A single purpose prompt step.
class _PurposeStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String hint;
  final List<String> examples;
  final TextEditingController controller;

  const _PurposeStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.examples,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const Gap(24),

        // Text field
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          minLines: 2,
        ),
        const Gap(16),

        // Example chips
        Text(
          'Ideas:',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples.map((example) {
            return ActionChip(
              label: Text(example),
              onPressed: () {
                controller.text = example;
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
