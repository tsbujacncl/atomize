import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../providers/completion_history_provider.dart';
import '../../providers/completion_stats_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/flame_widget.dart';
import '../../widgets/progress_bar_chart.dart';
import 'edit_habit_screen.dart';

/// Screen displaying detailed information about a habit.
class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return habitAsync.when(
      data: (habit) {
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Habit not found'),
            ),
          );
        }
        return _HabitDetailContent(habit: habit);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _HabitDetailContent extends ConsumerStatefulWidget {
  final Habit habit;

  const _HabitDetailContent({required this.habit});

  @override
  ConsumerState<_HabitDetailContent> createState() =>
      _HabitDetailContentState();
}

class _HabitDetailContentState extends ConsumerState<_HabitDetailContent> {
  StatsPeriod _selectedPeriod = StatsPeriod.oneWeek;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Edit',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined),
                    Gap(12),
                    Text('Archive'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    Gap(12),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Large flame visualization
            _LargeFlameSection(score: habit.score),
            const Gap(24),

            // Time period selector (unified)
            SegmentedButton<StatsPeriod>(
              segments: StatsPeriod.values
                  .map((p) => ButtonSegment(
                        value: p,
                        label: Text(p.label),
                      ))
                  .toList(),
              selected: {_selectedPeriod},
              onSelectionChanged: (selected) {
                setState(() => _selectedPeriod = selected.first);
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const Gap(24),

            // Score and completion stats
            _StatsSection(habit: habit, period: _selectedPeriod),
            const Gap(32),

            // Progress bar chart
            _ProgressChartSection(habit: habit, period: _selectedPeriod),
            const Gap(32),

            // Habit details
            _DetailsSection(habit: habit),
            const Gap(32),

            // Purpose section (if any)
            if (_hasPurpose(habit)) ...[
              _PurposeSection(habit: habit),
              const Gap(32),
            ],

            // Action buttons
            _ActionButtons(
              onEdit: () => _navigateToEdit(context),
              onArchive: () => _showArchiveDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasPurpose(Habit habit) {
    return (habit.quickWhy != null && habit.quickWhy!.isNotEmpty) ||
        (habit.feelingWhy != null && habit.feelingWhy!.isNotEmpty) ||
        (habit.identityWhy != null && habit.identityWhy!.isNotEmpty) ||
        (habit.outcomeWhy != null && habit.outcomeWhy!.isNotEmpty);
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habitId: widget.habit.id),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'archive':
        _showArchiveDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  Future<void> _showArchiveDialog(BuildContext context) async {
    final habit = widget.habit;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Habit'),
        content: Text(
          'Archive "${habit.name}"?\n\n'
          'The habit will be hidden but its history and progress will be preserved. '
          'You can restore it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(habitNotifierProvider.notifier).archiveHabit(habit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${habit.name} archived'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(habitNotifierProvider.notifier).unarchiveHabit(habit.id);
              },
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final habit = widget.habit;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Permanently delete "${habit.name}"?\n\n'
          'This will remove all history and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${habit.name} deleted')),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

/// Large flame visualization with score
class _LargeFlameSection extends StatelessWidget {
  final double score;

  const _LargeFlameSection({required this.score});

  @override
  Widget build(BuildContext context) {
    final flameColor = AppColors.getFlameColor(score);

    return Column(
      children: [
        FlameWidget(
          score: score,
          size: 120,
          animate: true,
        ),
        const Gap(16),
        Text(
          '${score.round()}%',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: flameColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          _getScoreLabel(score),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }

  String _getScoreLabel(double score) {
    if (score >= 95) return 'Mastered';
    if (score >= 80) return 'Strong habit';
    if (score >= 50) return 'Building momentum';
    if (score >= 30) return 'Getting started';
    return 'New habit';
  }
}

/// Stats section showing score, completion rate, and created date
class _StatsSection extends ConsumerWidget {
  final Habit habit;
  final StatsPeriod period;

  const _StatsSection({required this.habit, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(
      completionStatsProvider((
        habitId: habit.id,
        period: period,
      )),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'Score',
          value: '${habit.score.round()}%',
          color: AppColors.getFlameColor(habit.score),
        ),
        statsAsync.when(
          data: (stats) => _StatItem(
            label: 'Completed',
            value: '${stats.percentage.round()}%',
            subtitle: '${stats.completedDays}/${stats.totalDays} days',
          ),
          loading: () => const _StatItem(
            label: 'Completed',
            value: '...',
          ),
          error: (_, __) => const _StatItem(
            label: 'Completed',
            value: '-',
          ),
        ),
        _StatItem(
          label: 'Created',
          value: _formatDate(habit.createdAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat.MMMd().format(date);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Gap(4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Progress bar chart section
class _ProgressChartSection extends ConsumerWidget {
  final Habit habit;
  final StatsPeriod period;

  const _ProgressChartSection({required this.habit, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For "All Time", use days since habit creation
    final days = period == StatsPeriod.allTime
        ? DateTime.now().difference(habit.createdAt).inDays + 1
        : period.days;

    final historyAsync = ref.watch(
      completionHistoryProvider((
        habitId: habit.id,
        days: days,
      )),
    );

    return historyAsync.when(
      data: (history) => ProgressChartCard(
        history: history,
        score: habit.score,
        title: period.title,
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Could not load progress data'),
        ),
      ),
    );
  }
}

/// Details section showing when, where
class _DetailsSection extends StatelessWidget {
  final Habit habit;

  const _DetailsSection({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            _DetailRow(
              icon: Icons.schedule,
              label: 'When',
              value: _formatTime(habit.scheduledTime),
            ),
            if (habit.location != null && habit.location!.isNotEmpty) ...[
              const Gap(12),
              _DetailRow(
                icon: Icons.place_outlined,
                label: 'Where',
                value: habit.location!,
              ),
            ],
            const Gap(12),
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Type',
              value: habit.type.substring(0, 1).toUpperCase() +
                  habit.type.substring(1),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String scheduledTime) {
    try {
      final parts = scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final time = DateTime(2000, 1, 1, hour, minute);
      return DateFormat.jm().format(time);
    } catch (e) {
      return scheduledTime;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const Gap(12),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Purpose section showing why statements
class _PurposeSection extends StatelessWidget {
  final Habit habit;

  const _PurposeSection({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purpose',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            if (habit.quickWhy != null && habit.quickWhy!.isNotEmpty) ...[
              _PurposeItem(
                label: 'Why',
                value: habit.quickWhy!,
              ),
            ],
            if (habit.feelingWhy != null && habit.feelingWhy!.isNotEmpty) ...[
              const Gap(12),
              _PurposeItem(
                label: 'How it makes me feel',
                value: habit.feelingWhy!,
              ),
            ],
            if (habit.identityWhy != null && habit.identityWhy!.isNotEmpty) ...[
              const Gap(12),
              _PurposeItem(
                label: 'Who I\'m becoming',
                value: habit.identityWhy!,
              ),
            ],
            if (habit.outcomeWhy != null && habit.outcomeWhy!.isNotEmpty) ...[
              const Gap(12),
              _PurposeItem(
                label: 'What I\'ll achieve',
                value: habit.outcomeWhy!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PurposeItem extends StatelessWidget {
  final String label;
  final String value;

  const _PurposeItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Gap(4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Action buttons at the bottom
class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _ActionButtons({
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onArchive,
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Archive'),
          ),
        ),
        const Gap(16),
        Expanded(
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
        ),
      ],
    );
  }
}
