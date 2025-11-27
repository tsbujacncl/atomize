import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
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
          child: const AtomizeLogo(fontSize: 40),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 29),
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
  static const double _maxContentWidth = 700;

  /// Group habits by time of day, sorted by time with incomplete first.
  Map<String, List<TodayHabit>> _groupByTimeOfDay(List<TodayHabit> habits) {
    final morning = <TodayHabit>[];
    final afternoon = <TodayHabit>[];
    final evening = <TodayHabit>[];

    for (final habit in habits) {
      final hour = _parseHour(habit.habit.scheduledTime);
      if (hour < 12) {
        morning.add(habit);
      } else if (hour < 18) {
        afternoon.add(habit);
      } else {
        evening.add(habit);
      }
    }

    // Sort each group: incomplete first, then by scheduled time
    void sortGroup(List<TodayHabit> group) {
      group.sort((a, b) {
        // First sort by completion status (incomplete first)
        if (a.isCompletedToday != b.isCompletedToday) {
          return a.isCompletedToday ? 1 : -1;
        }
        // Then sort by scheduled time
        return a.habit.scheduledTime.compareTo(b.habit.scheduledTime);
      });
    }

    sortGroup(morning);
    sortGroup(afternoon);
    sortGroup(evening);

    return {
      if (morning.isNotEmpty) 'Morning': morning,
      if (afternoon.isNotEmpty) 'Afternoon': afternoon,
      if (evening.isNotEmpty) 'Evening': evening,
    };
  }

  int _parseHour(String scheduledTime) {
    try {
      final parts = scheduledTime.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return 12; // Default to afternoon
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group habits by time of day
    final groupedHabits = _groupByTimeOfDay(habits);

    // Count completed habits for stats
    final completedCount = habits.where((h) => h.isCompletedToday).length;

    // Check for purpose prompt
    final nextPurposePrompt = ref.watch(nextPurposePromptProvider);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                  // Period stats row (aggregate for selected period)
                  historyAsync.when(
                    data: (data) => _PeriodStatsRow(
                      period: selectedPeriod,
                      completionPercentage: data.periodCompletionPercentage,
                      avgScore: data.periodAvgScore,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
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

                  // Day header (Today, Yesterday, or date)
                  _DayHeader(date: selectedDate),
                  const Gap(12),

                  // Today stats row
                  historyAsync.when(
                    data: (data) => _TodayStatsRow(
                      completedCount: completedCount,
                      totalCount: habits.length,
                      avgScore: data.todayAvgScore,
                      scoreChange: data.todayScoreChange,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const Gap(20),

                  // Purpose prompt banner
                  nextPurposePrompt.when(
                    data: (habit) {
                      if (habit == null) return const SizedBox.shrink();
                      return _PurposePromptBanner(habit: habit);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Group habits by time of day
                  for (final entry in groupedHabits.entries) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                    ),
                    ...entry.value.map(
                      (habit) => _buildHabitCard(context, ref, habit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    WidgetRef ref,
    TodayHabit habit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HabitCard(
        todayHabit: habit,
        onComplete: habit.isCountType || habit.isCompletedToday
            ? null
            : () => _completeHabit(ref, habit.habit.id),
        onCountIncrement: habit.isCountType && !habit.isCompletedToday
            ? () => _incrementCount(ref, habit.habit.id)
            : null,
      ),
    );
  }

  /// Complete a habit and return the result for undo.
  Future<CompletionResult?> _completeHabit(WidgetRef ref, String habitId) async {
    return ref.read(completionNotifierProvider.notifier).completeHabit(
          habitId: habitId,
        );
  }

  Future<void> _incrementCount(WidgetRef ref, String habitId) async {
    await ref.read(completionNotifierProvider.notifier).incrementCount(
          habitId: habitId,
        );
  }
}

/// Period stats row showing aggregate completion % and average score for the period.
class _PeriodStatsRow extends StatelessWidget {
  final HistoryPeriod period;
  final double completionPercentage;
  final double avgScore;

  const _PeriodStatsRow({
    required this.period,
    required this.completionPercentage,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flameColor = AppColors.getFlameColor(avgScore);

    return Row(
      children: [
        // Completed box
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  period.displayLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const Gap(4),
                Text(
                  '${completionPercentage.round()}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        // Average box with heat-colored flame
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  period.displayLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: flameColor,
                      size: 24,
                    ),
                    const Gap(4),
                    Text(
                      avgScore.round().toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: flameColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Header showing the day name (Today, Yesterday, or formatted date).
class _DayHeader extends StatelessWidget {
  final DateTime date;

  const _DayHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    String label;
    if (dateOnly.isAtSameMomentAs(today)) {
      label = 'Today';
    } else if (dateOnly.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      // Format as "27th November 2025"
      final day = date.day;
      final suffix = _getDaySuffix(day);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      label = '$day$suffix ${months[date.month - 1]} ${date.year}';
    }

    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

/// Stats row showing completion fraction and average score for a day.
class _TodayStatsRow extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double avgScore;
  final int scoreChange;

  const _TodayStatsRow({
    required this.completedCount,
    required this.totalCount,
    required this.avgScore,
    required this.scoreChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allDone = totalCount > 0 && completedCount >= totalCount;
    final flameColor = AppColors.getFlameColor(avgScore);

    return Row(
      children: [
        // Completed box - green when all done
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: allDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: allDone
                    ? AppColors.success.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Completed',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (allDone) ...[
                      const Gap(4),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const Gap(8),
                Text(
                  '$completedCount/$totalCount',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: allDone ? AppColors.success : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        // Average box with heat-colored flame and change arrow
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average',
                  style: theme.textTheme.bodySmall,
                ),
                const Gap(8),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: flameColor,
                      size: 24,
                    ),
                    const Gap(4),
                    Text(
                      avgScore.round().toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: flameColor,
                      ),
                    ),
                    if (scoreChange != 0) ...[
                      const Gap(6),
                      Icon(
                        scoreChange > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: scoreChange > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      Text(
                        '${scoreChange.abs()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scoreChange > 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
