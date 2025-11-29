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
                label: const Text('New Atom'),
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
              // Gradient flame icon
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.flameBlue, AppColors.flameOrange],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.local_fire_department,
                  size: 80,
                ),
              ),
              const Gap(24),
              Text(
                'Start your first atom',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              Text(
                'Small steps lead to big changes.',
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
                label: const Text('Add Atom'),
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

  String _getSectionEmoji(String section) {
    switch (section) {
      case 'Morning':
        return '☀️ ';
      case 'Afternoon':
        return '🌤️ ';
      case 'Evening':
        return '🌙 ';
      default:
        return '';
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

                  // Combined stats boxes + chart side by side
                  historyAsync.when(
                    data: (data) => _CombinedStatsWithChart(
                      period: selectedPeriod,
                      // Today stats
                      todayCompletedCount: completedCount,
                      todayTotalCount: habits.length,
                      todayAvgScore: data.todayAvgScore,
                      todayScoreChange: data.todayScoreChange,
                      // Period stats
                      periodCompletionPercentage: data.periodCompletionPercentage,
                      periodAvgScore: data.periodAvgScore,
                      // Chart
                      historyData: data,
                      selectedDate: selectedDate,
                      onBarTap: onBarTap,
                    ),
                    loading: () => const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox(
                      height: 150,
                      child: Center(child: Text('Failed to load history')),
                    ),
                  ),
                  const Gap(16),

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
                        _getSectionEmoji(entry.key) + entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.sectionHeaderText,
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

/// Combined stats boxes (Today + Period) beside the bar chart.
class _CombinedStatsWithChart extends StatelessWidget {
  final HistoryPeriod period;
  // Today stats
  final int todayCompletedCount;
  final int todayTotalCount;
  final double todayAvgScore;
  final int todayScoreChange;
  // Period stats
  final double periodCompletionPercentage;
  final double periodAvgScore;
  // Chart
  final HomeHistoryData historyData;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onBarTap;

  const _CombinedStatsWithChart({
    required this.period,
    required this.todayCompletedCount,
    required this.todayTotalCount,
    required this.todayAvgScore,
    required this.todayScoreChange,
    required this.periodCompletionPercentage,
    required this.periodAvgScore,
    required this.historyData,
    required this.selectedDate,
    required this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayFlameColor = AppColors.getFlameColor(todayAvgScore);
    final periodFlameColor = AppColors.getFlameColor(periodAvgScore);
    final allDone = todayTotalCount > 0 && todayCompletedCount >= todayTotalCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Stats boxes stacked vertically
        SizedBox(
          width: 135,
          child: Column(
            children: [
              // Completed box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    // Today row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$todayCompletedCount/$todayTotalCount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: allDone ? AppColors.success : null,
                              ),
                            ),
                            if (allDone) ...[
                              const Gap(3),
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const Gap(4),
                    // Period row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${period.displayLabel}:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${periodCompletionPercentage.round()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              // Average box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    // Today row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: todayFlameColor,
                              size: 14,
                            ),
                            const Gap(2),
                            Text(
                              todayAvgScore.round().toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: todayFlameColor,
                              ),
                            ),
                            if (todayScoreChange != 0) ...[
                              const Gap(3),
                              Icon(
                                todayScoreChange > 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 10,
                                color: todayScoreChange > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              Text(
                                '${todayScoreChange.abs()}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: todayScoreChange > 0
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
                    const Gap(4),
                    // Period row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${period.displayLabel}:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: periodFlameColor,
                              size: 14,
                            ),
                            const Gap(2),
                            Text(
                              periodAvgScore.round().toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: periodFlameColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        // Right column: Bar chart
        Expanded(
          child: HistoryBarChart(
            data: historyData,
            selectedDate: selectedDate,
            onBarTap: onBarTap,
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
