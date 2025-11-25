import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../providers/habit_provider.dart';

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

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _whyController.dispose();
    super.dispose();
  }

  void _initializeFromHabit(Habit habit) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = habit.name;
    _locationController.text = habit.location ?? '';
    _whyController.text = habit.quickWhy ?? '';

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
                padding: const EdgeInsets.all(24),
                children: [
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

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Format time as HH:mm
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

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
