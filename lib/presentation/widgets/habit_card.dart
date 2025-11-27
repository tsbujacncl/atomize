import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/constants/habit_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../providers/score_provider.dart';
import '../providers/today_habits_provider.dart';
import '../screens/habit_detail/habit_detail_screen.dart';
import '../screens/timer/timer_screen.dart';

/// Card widget displaying a single habit for the home screen.
///
/// New compact layout with expand/collapse:
/// - Collapsed: [Icon] Name [▶️] ⏱ Time · 📍 Location 🔥 Score
/// - Expanded: Shows action buttons row (Start, Done, View, Undo)
class HabitCard extends ConsumerStatefulWidget {
  final TodayHabit todayHabit;

  /// Called when quick complete (Done button) is pressed.
  /// Returns CompletionResult for undo functionality.
  final Future<CompletionResult?> Function()? onComplete;

  /// Called when count is incremented for count-type habits.
  final VoidCallback? onCountIncrement;

  const HabitCard({
    super.key,
    required this.todayHabit,
    this.onComplete,
    this.onCountIncrement,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  bool _isExpanded = false;

  TodayHabit get todayHabit => widget.todayHabit;
  Habit get habit => todayHabit.habit;
  bool get isCompleted => todayHabit.isCompletedToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = habit.score;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(
                color: AppColors.completedCardBorder.withValues(alpha: 0.5),
                width: 1)
            : null,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: isCompleted ? AppColors.completedCardBackground : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main row (always visible)
                  _buildMainRow(context, theme, score),

                  // Expanded action buttons
                  if (_isExpanded) ...[
                    const Gap(12),
                    _buildActionButtons(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainRow(BuildContext context, ThemeData theme, double score) {
    final iconData = getIconData(habit.icon);
    final flameColor = AppColors.getFlameColor(score);

    return Row(
      children: [
        // Habit icon (left)
        _buildHabitIcon(theme, iconData),
        const Gap(12),

        // Habit name + play button / checkmark
        Expanded(
          child: Row(
            children: [
              // Name with strikethrough if completed
              Flexible(
                child: Text(
                  habit.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.textTheme.bodySmall?.color
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),

              // Play button or checkmark
              if (isCompleted)
                Icon(
                  Icons.check,
                  size: 20,
                  color: AppColors.success,
                )
              else
                _buildPlayButton(context),
            ],
          ),
        ),
        const Gap(12),

        // Time and location
        _buildTimeLocation(theme),
        const Gap(12),

        // Flame score (right)
        _buildFlameScore(theme, score, flameColor),
      ],
    );
  }

  Widget _buildHabitIcon(ThemeData theme, IconData iconData) {
    final score = habit.score;
    final color = AppColors.getFlameColor(score);

    // Progress ring for count/weekly types
    double? progress;
    String? progressText;
    if (todayHabit.isCountType) {
      progress = todayHabit.countProgress;
      progressText = '${todayHabit.todayCount}/${todayHabit.countTarget}';
    } else if (todayHabit.isWeeklyType) {
      progress = todayHabit.weeklyProgress;
      progressText = '${todayHabit.weeklyCount}/${todayHabit.weeklyTarget}';
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? color.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest,
            ),
          ),

          // Progress ring (for count/weekly types)
          if (progress != null && !isCompleted)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

          // Icon
          Icon(
            iconData,
            size: 22,
            color: isCompleted ? color : theme.colorScheme.onSurfaceVariant,
          ),

          // Progress text badge (for count/weekly when not completed)
          if (progressText != null && !isCompleted)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  progressText,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    // For count type, tap increments count
    if (todayHabit.isCountType && widget.onCountIncrement != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onCountIncrement?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: AppColors.accent),
                const Gap(2),
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Regular play button for timer
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openTimer(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            size: 18,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLocation(ThemeData theme) {
    final hasTime = habit.scheduledTime.isNotEmpty;
    final hasLocation = habit.location != null && habit.location!.isNotEmpty;

    if (!hasTime && !hasLocation) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTime) ...[
          Icon(
            Icons.schedule,
            size: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
          const Gap(2),
          Text(
            _formatTimeShort(habit.scheduledTime),
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
        if (hasTime && hasLocation) ...[
          const Gap(4),
          Text(
            '·',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const Gap(4),
        ],
        if (hasLocation) ...[
          Icon(
            Icons.place_outlined,
            size: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
          const Gap(2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 60),
            child: Text(
              habit.location!,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFlameScore(ThemeData theme, double score, Color flameColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: 20,
          color: flameColor,
        ),
        const Gap(2),
        Text(
          score.round().toString(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: flameColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompleted) {
      // Completed: Undo, View
      return Row(
        children: [
          _ActionButton(
            icon: Icons.undo,
            label: 'Undo',
            color: theme.colorScheme.outline,
            onTap: () => _handleUndo(context),
          ),
          const Gap(8),
          _ActionButton(
            icon: Icons.visibility_outlined,
            label: 'View',
            color: theme.colorScheme.outline,
            onTap: () => _openDetail(context),
          ),
        ],
      );
    } else {
      // Not completed: Start, Done, View
      return Row(
        children: [
          _ActionButton(
            icon: Icons.play_arrow,
            label: 'Start',
            color: AppColors.accent,
            onTap: () => _openTimer(context),
          ),
          const Gap(8),
          if (!todayHabit.isCountType) ...[
            _ActionButton(
              icon: Icons.check,
              label: 'Done',
              color: AppColors.success,
              onTap: () => _handleComplete(context),
            ),
            const Gap(8),
          ],
          _ActionButton(
            icon: Icons.visibility_outlined,
            label: 'View',
            color: theme.colorScheme.outline,
            onTap: () => _openDetail(context),
          ),
        ],
      );
    }
  }

  void _openTimer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimerScreen(habit: habit),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habitId: habit.id),
      ),
    );
  }

  Future<void> _handleComplete(BuildContext context) async {
    if (widget.onComplete == null) return;

    final result = await widget.onComplete!();
    if (result != null && context.mounted) {
      // Show snackbar with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} completed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _handleUndo(context),
          ),
        ),
      );
    }

    // Collapse after completing
    setState(() {
      _isExpanded = false;
    });
  }

  Future<void> _handleUndo(BuildContext context) async {
    // Use undoTodayCompletion from the provider
    final success = await ref
        .read(completionNotifierProvider.notifier)
        .undoTodayCompletion(habitId: habit.id);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habit.name} undone')),
      );
    }

    // Collapse after undo
    setState(() {
      _isExpanded = false;
    });
  }

  /// Convert "10:00 PM" to "10PM", "2:30 PM" to "2:30PM", etc.
  String _formatTimeShort(String scheduledTime) {
    try {
      final parts = scheduledTime.split(':');
      if (parts.length != 2) return scheduledTime;

      final hour24 = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final isPM = hour24 >= 12;
      final hour12 = hour24 == 0
          ? 12
          : hour24 > 12
              ? hour24 - 12
              : hour24;
      final suffix = isPM ? 'PM' : 'AM';

      if (minute == 0) {
        return '$hour12$suffix';
      } else {
        return '$hour12:${minute.toString().padLeft(2, '0')}$suffix';
      }
    } catch (e) {
      return scheduledTime;
    }
  }
}

/// Action button for expanded state.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
