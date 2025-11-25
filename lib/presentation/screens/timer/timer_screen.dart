import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/services/audio_service.dart';
import '../../providers/score_provider.dart';
import '../../providers/timer_provider.dart';
import '../../widgets/timer_circle.dart';

/// Full-screen timer for habit completion.
class TimerScreen extends ConsumerStatefulWidget {
  /// The habit to time.
  final Habit habit;

  const TimerScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  bool _hasCompletedHabit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start the timer after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitTimerProvider.notifier).startTimer(widget.habit);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if timer completed while in background
      final completed =
          ref.read(habitTimerProvider.notifier).checkBackgroundCompletion();
      if (completed && !_hasCompletedHabit) {
        _onTimerComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(habitTimerProvider);
    final theme = Theme.of(context);

    // Watch for completion
    ref.listen<TimerState?>(habitTimerProvider, (previous, next) {
      if (next != null && next.isCompleted && !_hasCompletedHabit) {
        _onTimerComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onCancel,
        ),
        title: Text(widget.habit.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Timer circle
            if (timerState != null)
              TimerCircle(
                progress: timerState.progress,
                timeText: _formatTime(timerState.remainingSeconds),
                isPaused: timerState.isPaused,
                isCompleted: timerState.isCompleted,
              )
            else
              const CircularProgressIndicator(),

            const Spacer(),

            // Quick why reminder
            if (widget.habit.quickWhy != null &&
                widget.habit.quickWhy!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Why you do this:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      widget.habit.quickWhy!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),
            ],

            // Control buttons
            if (timerState != null && !timerState.isCompleted)
              _ControlButtons(
                isPaused: timerState.isPaused,
                onPauseResume: _onPauseResume,
                onFinishEarly: _onFinishEarly,
              ),

            // Completion message
            if (timerState?.isCompleted == true) ...[
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const Gap(16),
              Text(
                'Great job!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                'Habit completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.done),
                label: const Text('Done'),
              ),
            ],

            const Gap(48),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onPauseResume() {
    final timerState = ref.read(habitTimerProvider);
    if (timerState == null) return;

    if (timerState.isPaused) {
      ref.read(habitTimerProvider.notifier).resumeTimer();
    } else {
      ref.read(habitTimerProvider.notifier).pauseTimer();
    }
  }

  Future<void> _onTimerComplete() async {
    if (_hasCompletedHabit) return;
    _hasCompletedHabit = true;

    // Play completion sound
    await AudioService().playCompletionSound();

    // Complete the habit
    await ref.read(completionNotifierProvider.notifier).completeHabit(
          habitId: widget.habit.id,
          source: CompletionSource.timer,
        );
  }

  void _onFinishEarly() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Early?'),
        content: const Text(
          'Are you sure you want to finish early?\n\n'
          'The habit will be marked as complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && !_hasCompletedHabit) {
        ref.read(habitTimerProvider.notifier).cancelTimer();
        _onTimerComplete();
      }
    });
  }

  void _onCancel() {
    final timerState = ref.read(habitTimerProvider);

    if (timerState != null && timerState.isCompleted) {
      // Timer already completed, just pop
      Navigator.of(context).pop();
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Timer?'),
        content: const Text(
          'Are you sure you want to cancel?\n\n'
          'The habit will not be marked as complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel Timer'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(habitTimerProvider.notifier).cancelTimer();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }
}

/// Control buttons for pause/resume and finish early.
class _ControlButtons extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPauseResume;
  final VoidCallback onFinishEarly;

  const _ControlButtons({
    required this.isPaused,
    required this.onPauseResume,
    required this.onFinishEarly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Finish early button
          OutlinedButton(
            onPressed: onFinishEarly,
            child: const Text('Finish Early'),
          ),

          const Gap(16),

          // Pause/Resume button
          FilledButton.icon(
            onPressed: onPauseResume,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(isPaused ? 'Resume' : 'Pause'),
          ),
        ],
      ),
    );
  }
}
