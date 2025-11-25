import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/models/enums.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/duration_picker.dart';

/// Screen for creating a new habit.
///
/// Form fields:
/// - What (habit name) — required
/// - When (time picker) — required
/// - Where (location) — optional
/// - Why (purpose) — optional
class CreateHabitScreen extends ConsumerStatefulWidget {
  /// Optional callback when habit is successfully created.
  /// If provided, this is called instead of Navigator.pop().
  /// Used during onboarding flow.
  final VoidCallback? onHabitCreated;

  /// Whether to show the close button in the app bar.
  final bool showCloseButton;

  const CreateHabitScreen({
    super.key,
    this.onHabitCreated,
    this.showCloseButton = true,
  });

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _whyController = TextEditingController();
  final _countTargetController = TextEditingController(text: '8');
  final _weeklyTargetController = TextEditingController(text: '3');

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  HabitType _habitType = HabitType.binary;
  int? _timerDuration; // null = use default (2 min)
  String? _afterHabitId; // habit stacking
  bool _isSaving = false;

  // Reframing suggestion state
  String? _reframeSuggestion;

  // Trigger words for detecting negative habit framing
  static const _actionTriggers = [
    'stop',
    'quit',
    'reduce',
    'less',
    'avoid',
    'no more',
    'cut',
    'don\'t',
    'dont',
  ];

  // Topic-specific reframe suggestions
  static const _reframeSuggestions = {
    'smoking': 'Smoke-free day',
    'smoke': 'Smoke-free day',
    'cigarette': 'Smoke-free day',
    'vape': 'Vape-free day',
    'vaping': 'Vape-free day',
    'alcohol': 'Alcohol-free day',
    'drinking': 'Alcohol-free day',
    'drink': 'Alcohol-free day',
    'beer': 'Alcohol-free day',
    'wine': 'Alcohol-free day',
    'phone': 'Phone under 30 mins',
    'screen': 'Screen time under 30 mins',
    'social media': 'Social media free day',
    'sugar': 'Sugar-free day',
    'sweets': 'Sugar-free day',
    'candy': 'Sugar-free day',
    'junk food': 'Healthy eating day',
    'junk': 'Healthy eating day',
    'fast food': 'Home-cooked meal day',
    'caffeine': 'Caffeine-free day',
    'coffee': 'Caffeine-free day',
    'soda': 'Soda-free day',
    'gambling': 'Gambling-free day',
    'gaming': 'Gaming under 1 hour',
    'snacking': 'Mindful eating day',
    'nail biting': 'Nail care day',
    'procrastinat': 'Focus time day',
  };

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkForReframeSuggestion);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForReframeSuggestion);
    _nameController.dispose();
    _locationController.dispose();
    _whyController.dispose();
    _countTargetController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  void _checkForReframeSuggestion() {
    final text = _nameController.text.toLowerCase();

    // Check if any action trigger word is present
    final hasActionTrigger = _actionTriggers.any((trigger) => text.contains(trigger));

    if (hasActionTrigger) {
      // Try to find a specific reframe suggestion
      String? suggestion;
      for (final entry in _reframeSuggestions.entries) {
        if (text.contains(entry.key)) {
          suggestion = entry.value;
          break;
        }
      }

      // Use generic suggestion if no specific one found
      suggestion ??= 'a positive action';

      if (_reframeSuggestion != suggestion) {
        setState(() => _reframeSuggestion = suggestion);
      }
    } else if (_reframeSuggestion != null) {
      setState(() => _reframeSuggestion = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
        leading: widget.showCloseButton
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              Text(
                'Create a new habit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(8),
              Text(
                'Start small. One habit at a time.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              const Gap(32),

              // What - Habit name (required)
              _buildSectionLabel(context, 'What', isRequired: true),
              const Gap(8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Do yoga, Read, Meditate',
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: _validateName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              // Reframing suggestion banner
              if (_reframeSuggestion != null) ...[
                const Gap(12),
                _ReframeSuggestionBanner(suggestion: _reframeSuggestion!),
              ],
              const Gap(24),

              // Type - Habit type selector
              _buildSectionLabel(context, 'Type'),
              const Gap(8),
              _HabitTypeSelector(
                selectedType: _habitType,
                onTypeChanged: (type) {
                  setState(() => _habitType = type);
                },
              ),

              // Count target (only for count type)
              if (_habitType == HabitType.count) ...[
                const Gap(16),
                _buildSectionLabel(context, 'Daily Target', isRequired: true),
                const Gap(8),
                TextFormField(
                  controller: _countTargetController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 8',
                    suffixText: 'times per day',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateCountTarget,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],

              // Weekly target (only for weekly type)
              if (_habitType == HabitType.weekly) ...[
                const Gap(16),
                _buildSectionLabel(context, 'Weekly Target', isRequired: true),
                const Gap(8),
                TextFormField(
                  controller: _weeklyTargetController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 3',
                    suffixText: 'times per week',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateWeeklyTarget,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const Gap(8),
                Text(
                  'Complete this habit at least this many times each week.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const Gap(24),

              // When - Time picker (required)
              _buildSectionLabel(context, 'When', isRequired: true),
              const Gap(8),
              _TimePicker(
                selectedTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() => _selectedTime = time);
                },
              ),
              const Gap(24),

              // Where - Location (optional)
              _buildSectionLabel(context, 'Where'),
              const Gap(8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Living room, Office, Kitchen',
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
              ),
              const Gap(24),

              // Why - Purpose (optional)
              _buildSectionLabel(context, 'Why'),
              const Gap(8),
              TextFormField(
                controller: _whyController,
                decoration: const InputDecoration(
                  hintText: 'Why does this matter to you?',
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                onFieldSubmitted: (_) => _saveHabit(),
              ),
              const Gap(8),
              Text(
                'A short purpose reminder helps on tough days.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(24),

              // Timer duration (optional)
              _buildSectionLabel(context, 'Timer Duration'),
              const Gap(8),
              DurationPicker(
                selectedDuration: _timerDuration,
                onDurationChanged: (duration) {
                  setState(() => _timerDuration = duration);
                },
                showDefaultOption: true,
              ),
              const Gap(8),
              Text(
                'How long to focus when completing this habit.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(24),

              // Habit Stacking (optional)
              _buildSectionLabel(context, 'Build a Routine'),
              const Gap(4),
              Text(
                'Do this habit right after another one.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(8),
              _HabitStackSelector(
                selectedHabitId: _afterHabitId,
                onHabitChanged: (habitId) {
                  setState(() => _afterHabitId = habitId);
                },
              ),
              const Gap(40),

              // Save button
              FilledButton(
                onPressed: _isSaving ? null : _saveHabit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
    BuildContext context,
    String label, {
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (isRequired) ...[
          const Gap(4),
          Text(
            '*',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ],
      ],
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a habit name';
    }
    if (value.trim().length < 2) {
      return 'Habit name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Habit name must be less than 100 characters';
    }
    return null;
  }

  String? _validateCountTarget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a target';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed < 1) {
      return 'Target must be at least 1';
    }
    if (parsed > 100) {
      return 'Target must be 100 or less';
    }
    return null;
  }

  String? _validateWeeklyTarget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a weekly target';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed < 1) {
      return 'Target must be at least 1';
    }
    if (parsed > 7) {
      return 'Target must be 7 or less';
    }
    return null;
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Format time as HH:mm
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await ref.read(habitNotifierProvider.notifier).createHabit(
            name: _nameController.text.trim(),
            scheduledTime: timeString,
            type: _habitType,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            quickWhy: _whyController.text.trim().isEmpty
                ? null
                : _whyController.text.trim(),
            countTarget: _habitType == HabitType.count
                ? int.tryParse(_countTargetController.text.trim())
                : null,
            weeklyTarget: _habitType == HabitType.weekly
                ? int.tryParse(_weeklyTargetController.text.trim())
                : null,
            timerDuration: _timerDuration,
            afterHabitId: _afterHabitId,
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} created'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Call callback if provided (onboarding flow), otherwise navigate back
        if (widget.onHabitCreated != null) {
          widget.onHabitCreated!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create habit: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Time picker widget that displays the selected time and opens a picker dialog.
class _TimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _TimePicker({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    final formattedTime = DateFormat.jm().format(dateTime);

    return InkWell(
      onTap: () => _showTimePicker(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const Gap(12),
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}

/// Segmented button for selecting habit type.
class _HabitTypeSelector extends StatelessWidget {
  final HabitType selectedType;
  final ValueChanged<HabitType> onTypeChanged;

  const _HabitTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HabitType>(
      segments: const [
        ButtonSegment(
          value: HabitType.binary,
          label: Text('Yes/No'),
          icon: Icon(Icons.check_circle_outline),
        ),
        ButtonSegment(
          value: HabitType.count,
          label: Text('Count'),
          icon: Icon(Icons.add_circle_outline),
        ),
        ButtonSegment(
          value: HabitType.weekly,
          label: Text('Weekly'),
          icon: Icon(Icons.calendar_view_week),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (selection) {
        onTypeChanged(selection.first);
      },
      showSelectedIcon: false,
    );
  }
}

/// Dropdown for selecting a habit to stack after (habit chaining).
class _HabitStackSelector extends ConsumerWidget {
  final String? selectedHabitId;
  final ValueChanged<String?> onHabitChanged;

  const _HabitStackSelector({
    required this.selectedHabitId,
    required this.onHabitChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      data: (habits) {
        return InkWell(
          onTap: () => _showHabitPicker(context, habits),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    _getSelectedHabitName(habits),
                    style: selectedHabitId == null
                        ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).hintColor,
                            )
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (selectedHabitId != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => onHabitChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Gap(12),
            Text('Loading habits...'),
          ],
        ),
      ),
      error: (_, __) => const InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text('Error loading habits'),
      ),
    );
  }

  String _getSelectedHabitName(List<Habit> habits) {
    if (selectedHabitId == null) {
      return 'None (standalone habit)';
    }
    final habit = habits.where((h) => h.id == selectedHabitId).firstOrNull;
    return habit?.name ?? 'Unknown habit';
  }

  Future<void> _showHabitPicker(
    BuildContext context,
    List<Habit> habits,
  ) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Stack After Habit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // None option
                  ListTile(
                    leading: const Icon(Icons.remove_circle_outline),
                    title: const Text('None (standalone habit)'),
                    selected: selectedHabitId == null,
                    onTap: () => Navigator.pop(context, ''),
                  ),
                  const Divider(),
                  // Habit options
                  ...habits.map(
                    (habit) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(habit.name),
                      subtitle: Text('Scheduled: ${habit.scheduledTime}'),
                      selected: selectedHabitId == habit.id,
                      onTap: () => Navigator.pop(context, habit.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      onHabitChanged(selected.isEmpty ? null : selected);
    }
  }
}

/// Banner suggesting positive reframing for breaking bad habits.
class _ReframeSuggestionBanner extends StatelessWidget {
  final String suggestion;

  const _ReframeSuggestionBanner({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGeneric = suggestion == 'a positive action';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡',
            style: TextStyle(fontSize: 18),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip: Frame it positively',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isGeneric
                            ? 'Try framing it as what you WILL do — this way every completion is a win!'
                            : 'Try: ',
                      ),
                      if (!isGeneric) ...[
                        TextSpan(
                          text: '"$suggestion"',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: ' — every completion is a win!',
                        ),
                      ],
                    ],
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
