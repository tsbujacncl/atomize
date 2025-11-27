import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/models/enums.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/icon_picker.dart';

/// Screen for editing an existing habit.
class EditHabitScreen extends ConsumerStatefulWidget {
  final String habitId;

  const EditHabitScreen({
    super.key,
    required this.habitId,
  });

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _whyController = TextEditingController();
  final _weeklyTargetController = TextEditingController();
  final _timerMinutesController = TextEditingController(text: '2');
  final _timerSecondsController = TextEditingController(text: '0');

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  HabitType _habitType = HabitType.binary;
  String? _afterHabitId; // habit stacking
  String? _selectedIcon;
  bool _isSaving = false;
  bool _isInitialized = false;

  // Max width for content on wide screens
  static const double _maxContentWidth = 500;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _whyController.dispose();
    _weeklyTargetController.dispose();
    _timerMinutesController.dispose();
    _timerSecondsController.dispose();
    super.dispose();
  }

  void _initializeFromHabit(Habit habit) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = habit.name;
    _locationController.text = habit.location ?? '';
    _whyController.text = habit.quickWhy ?? '';
    _afterHabitId = habit.afterHabitId;
    _selectedIcon = habit.icon;
    _habitType = HabitType.values.firstWhere(
      (t) => t.name == habit.type,
      orElse: () => HabitType.binary,
    );
    _weeklyTargetController.text = habit.weeklyTarget?.toString() ?? '3';

    // Parse timer duration (seconds) into minutes and seconds
    final duration = habit.timerDuration ?? 120; // Default 2 minutes
    _timerMinutesController.text = (duration ~/ 60).toString();
    _timerSecondsController.text = (duration % 60).toString();

    // Parse scheduled time
    try {
      final parts = habit.scheduledTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitByIdProvider(widget.habitId));

    return habitAsync.when(
      data: (habit) {
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Habit')),
            body: const Center(child: Text('Habit not found')),
          );
        }

        _initializeFromHabit(habit);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Habit'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // What - Habit name with icon picker on left
                            _buildSectionLabel(context, 'What', isRequired: true),
                            const Gap(8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconPickerButton(
                                  iconId: _selectedIcon,
                                  onChanged: (iconId) {
                                    setState(() => _selectedIcon = iconId);
                                  },
                                ),
                                const Gap(12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g., Do yoga, Read, Meditate',
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    textInputAction: TextInputAction.next,
                                    validator: _validateName,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                              ],
                            ),

                            // Weekly target (only for weekly type habits)
                            if (_habitType == HabitType.weekly) ...[
                              const Gap(24),
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
                            const Gap(24),

                            // Timer duration (minutes + seconds input)
                            _buildSectionLabel(context, 'Timer Duration'),
                            const Gap(8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    controller: _timerMinutesController,
                                    decoration: const InputDecoration(
                                      hintText: '2',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'min',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Gap(16),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    controller: _timerSecondsController,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'sec',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
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
                              excludeHabitId: widget.habitId,
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
                                  : const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit Habit')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Habit')),
        body: Center(child: Text('Error: $error')),
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

      // Calculate timer duration in seconds from min + sec inputs
      final minutes = int.tryParse(_timerMinutesController.text.trim()) ?? 2;
      final seconds = int.tryParse(_timerSecondsController.text.trim()) ?? 0;
      final timerDuration = (minutes * 60) + seconds;

      await ref.read(habitNotifierProvider.notifier).updateHabit(
            id: widget.habitId,
            name: _nameController.text.trim(),
            scheduledTime: timeString,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            quickWhy: _whyController.text.trim().isEmpty
                ? null
                : _whyController.text.trim(),
            timerDuration: timerDuration > 0 ? timerDuration : null,
            updateTimerDuration: true,
            countTarget: null, // Count type removed
            updateCountTarget: false,
            weeklyTarget: _habitType == HabitType.weekly
                ? int.tryParse(_weeklyTargetController.text.trim())
                : null,
            updateWeeklyTarget: _habitType == HabitType.weekly,
            afterHabitId: _afterHabitId,
            updateAfterHabitId: true,
            icon: _selectedIcon,
            updateIcon: true,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update habit: $e'),
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

/// Dropdown for selecting a habit to stack after (habit chaining).
class _HabitStackSelector extends ConsumerWidget {
  final String? selectedHabitId;
  final ValueChanged<String?> onHabitChanged;
  final String? excludeHabitId;

  const _HabitStackSelector({
    required this.selectedHabitId,
    required this.onHabitChanged,
    this.excludeHabitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      data: (habits) {
        // Filter out current habit if editing
        final availableHabits = excludeHabitId != null
            ? habits.where((h) => h.id != excludeHabitId).toList()
            : habits;

        return InkWell(
          onTap: () => _showHabitPicker(context, availableHabits),
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
                    _getSelectedHabitName(availableHabits),
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
