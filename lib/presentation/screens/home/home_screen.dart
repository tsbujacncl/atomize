import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../providers/habit_provider.dart';
import '../../providers/home_history_provider.dart';
import '../../providers/purpose_prompt_provider.dart';
import '../../providers/today_habits_provider.dart';
import '../../providers/score_provider.dart';
import '../../widgets/atomize_logo.dart';
import '../../widgets/date_nav_header.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/history_bar_chart.dart';
import '../../widgets/period_selector.dart';
import '../create_habit/create_habit_screen.dart';
import '../habit_detail/deep_purpose_screen.dart';
import '../habit_detail/edit_habit_screen.dart';
import '../past_day/past_day_screen.dart';
import '../settings/settings_screen.dart';

/// Main home screen displaying today's habits with history navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.sevenDays;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  void _navigatePrevious() {
    setState(() {
      if (_selectedPeriod.isDaily) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else {
        // Go back one month
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          1,
        );
      }
    });
  }

  void _navigateNext() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedPeriod.isDaily) {
      final nextDate = _selectedDate.add(const Duration(days: 1));
      final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);
      if (!nextDateOnly.isAfter(today)) {
        setState(() {
          _selectedDate = nextDate;
        });
      }
    } else {
      final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      if (nextMonth.year < now.year ||
          (nextMonth.year == now.year && nextMonth.month <= now.month)) {
        setState(() {
          _selectedDate = nextMonth;
        });
      }
    }
  }

  void _onPeriodChanged(HistoryPeriod period) {
    setState(() {
      _selectedPeriod = period;
      // Reset to today when changing periods
      _selectedDate = DateTime.now();
    });
  }

  void _onBarTap(DateTime date) {
    if (_selectedPeriod.isDaily) {
      // Navigate to past day screen
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tapDate = DateTime(date.year, date.month, date.day);

      if (tapDate.isAtSameMomentAs(today)) {
        // Already showing today
        setState(() {
          _selectedDate = date;
        });
      } else {
        // Navigate to past day
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PastDayScreen(date: date),
          ),
        );
      }
    } else {
      // For monthly views, update selected date to show that month
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showDatePicker() async {
    if (!_selectedPeriod.isDaily) {
      // Show date picker for 1y/All mode
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PastDayScreen(date: picked),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final historyAsync = ref.watch(homeHistoryProvider((
      period: _selectedPeriod,
      selectedDate: _selectedDate,
    )));

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _goToToday,
          child: const AtomizeLogo(fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _goToToday();
          ref.invalidate(todayHabitsProvider);
          ref.invalidate(homeHistoryProvider);
        },
        child: todayHabitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return const _EmptyState();
            }
            return _HabitListWithHistory(
              habits: habits,
              historyAsync: historyAsync,
              selectedPeriod: _selectedPeriod,
              selectedDate: _selectedDate,
              onPeriodChanged: _onPeriodChanged,
              onPrevious: _navigatePrevious,
              onNext: _navigateNext,
              onBarTap: _onBarTap,
              onDateTap: _selectedPeriod.isDaily ? null : _showDatePicker,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const Gap(16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: todayHabitsAsync.whenOrNull(
        data: (habits) => habits.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateHabitScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Habit'),
              ),
      ),
    );
  }
}

/// Empty state when no habits exist.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const Gap(24),
              Text(
                'No habits yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(8),
              Text(
                'Create your first habit to get started.\nSmall steps lead to big changes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateHabitScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create First Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of habits with history navigation at the top.
class _HabitListWithHistory extends ConsumerWidget {
  final List<TodayHabit> habits;
  final AsyncValue<HomeHistoryData> historyAsync;
  final HistoryPeriod selectedPeriod;
  final DateTime selectedDate;
  final ValueChanged<HistoryPeriod> onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onBarTap;
  final VoidCallback? onDateTap;

  const _HabitListWithHistory({
    required this.habits,
    required this.historyAsync,
    required this.selectedPeriod,
    required this.selectedDate,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onBarTap,
    this.onDateTap,
  });

  // Max width for content on wide screens
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate completed and incomplete habits
    final incomplete = habits.where((h) => !h.isCompletedToday).toList();
    final completed = habits.where((h) => h.isCompletedToday).toList();

    // Check for purpose prompt
    final nextPurposePrompt = ref.watch(nextPurposePromptProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Date navigation header
            DateNavHeader(
              date: selectedDate,
              period: selectedPeriod,
              onPrevious: onPrevious,
              onNext: onNext,
              onDateTap: onDateTap,
            ),
            const Gap(12),

            // Period selector
            Center(
              child: PeriodSelector(
                selected: selectedPeriod,
                onChanged: onPeriodChanged,
              ),
            ),
            const Gap(16),

            // History bar chart
            historyAsync.when(
              data: (data) => HistoryBarChart(
                data: data,
                selectedDate: selectedDate,
                onBarTap: onBarTap,
              ),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(
                height: 120,
                child: Center(child: Text('Failed to load history')),
              ),
            ),
            const Gap(24),

            // Purpose prompt banner
            nextPurposePrompt.when(
              data: (habit) {
                if (habit == null) return const SizedBox.shrink();
                return _PurposePromptBanner(habit: habit);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Incomplete habits
            if (incomplete.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'To Do',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ),
              ...incomplete.map(
                (habit) => _buildHabitCard(context, ref, habit),
              ),
            ],

            // Completed habits
            if (completed.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ),
              ...completed.map(
                (habit) => _buildHabitCard(context, ref, habit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    WidgetRef ref,
    TodayHabit habit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPressStart: (details) {
          _showHabitContextMenu(
            context,
            ref,
            habit.habit,
            details.globalPosition,
          );
        },
        child: HabitCard(
          todayHabit: habit,
          onQuickComplete: habit.isCountType || habit.isCompletedToday
              ? null
              : () => _quickCompleteHabit(ref, habit.habit.id),
          onCountIncrement: habit.isCountType && !habit.isCompletedToday
              ? () => _incrementCount(ref, habit.habit.id)
              : null,
        ),
      ),
    );
  }

  void _showHabitContextMenu(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    Offset position,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 20, color: Theme.of(context).colorScheme.onSurface),
              const Gap(12),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined,
                  size: 20, color: Theme.of(context).colorScheme.onSurface),
              const Gap(12),
              const Text('Archive'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              const Gap(12),
              Text('Delete', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'edit':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditHabitScreen(habitId: habit.id),
            ),
          );
          break;
        case 'archive':
          _showArchiveDialog(context, ref, habit);
          break;
        case 'delete':
          _showDeleteDialog(context, ref, habit);
          break;
      }
    });
  }

  Future<void> _showArchiveDialog(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Habit'),
        content: Text(
          'Archive "${habit.name}"?\n\n'
          'The habit will be hidden but its history and progress will be preserved. '
          'You can restore it later from Settings.',
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
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
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
      }
    }
  }

  Future<void> _quickCompleteHabit(WidgetRef ref, String habitId) async {
    await ref.read(completionNotifierProvider.notifier).completeHabit(
          habitId: habitId,
        );
  }

  Future<void> _incrementCount(WidgetRef ref, String habitId) async {
    await ref.read(completionNotifierProvider.notifier).incrementCount(
          habitId: habitId,
        );
  }
}

/// Banner prompting user to add deep purpose for a habit.
class _PurposePromptBanner extends StatelessWidget {
  final Habit habit;

  const _PurposePromptBanner({required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysSinceCreated = DateTime.now().difference(habit.createdAt).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => _openDeepPurposeScreen(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deepen your "${habit.name}"',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      "$daysSinceCreated days in! Let's connect it to something deeper.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDeepPurposeScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeepPurposeScreen(habit: habit),
      ),
    );
  }
}
