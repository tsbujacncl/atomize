import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/habit_provider.dart';

/// Screen for creating a new habit.
///
/// Form fields:
/// - What (habit name) — required
/// - When (time picker) — required
/// - Where (location) — optional
/// - Why (purpose) — optional
class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _whyController = TextEditingController();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _whyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
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
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            quickWhy: _whyController.text.trim().isEmpty
                ? null
                : _whyController.text.trim(),
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} created'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
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
