import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:uuid/uuid.dart';
import '../../models/habit.dart';
import '../habits/habit_provider.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Purpose Controllers
  final _feelController = TextEditingController();
  final _becomeController = TextEditingController();
  final _achieveController = TextEditingController();

  // Half-life selection
  int _selectedDays = 1;
  int _selectedHours = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _feelController.dispose();
    _becomeController.dispose();
    _achieveController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final halfLifeSeconds = (_selectedDays * 24 * 3600) + (_selectedHours * 3600);
      
      final newHabit = Habit(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        halfLifeSeconds: halfLifeSeconds > 0 ? halfLifeSeconds : 3600, // Minimum 1 hour
        purpose: HabitPurpose(
          feelStatement: _feelController.text.isNotEmpty ? _feelController.text : null,
          becomeStatement: _becomeController.text.isNotEmpty ? _becomeController.text : null,
          achieveStatement: _achieveController.text.isNotEmpty ? _achieveController.text : null,
          lastUpdated: DateTime.now(),
        ),
      );

      ref.read(habitsProvider.notifier).addHabit(newHabit);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Info Section
                Text(
                  'Basic Info',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Gap(16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Morning Yoga',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., 10 minutes of stretching',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const Gap(24),

                // Half-Life Section
                Text(
                  'Half-Life Period',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'How long until habit strength drops to 50% without practice?',
                  style: TextStyle(color: Colors.grey),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        NumberPicker(
                          value: _selectedDays,
                          minValue: 0,
                          maxValue: 30,
                          onChanged: (value) => setState(() => _selectedDays = value),
                        ),
                        const Text('Days'),
                      ],
                    ),
                    const Gap(16),
                    Column(
                      children: [
                        NumberPicker(
                          value: _selectedHours,
                          minValue: 0,
                          maxValue: 23,
                          onChanged: (value) => setState(() => _selectedHours = value),
                        ),
                        const Text('Hours'),
                      ],
                    ),
                  ],
                ),
                const Gap(24),

                // Purpose Section
                Text(
                  'The "Why"',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'Define your motivation to stay on track.',
                  style: TextStyle(color: Colors.grey),
                ),
                const Gap(16),
                TextFormField(
                  controller: _feelController,
                  decoration: const InputDecoration(
                    labelText: 'How will it make you feel?',
                    hintText: 'e.g., Energized, Calm',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(12),
                TextFormField(
                  controller: _becomeController,
                  decoration: const InputDecoration(
                    labelText: 'Who do you want to become?',
                    hintText: 'e.g., A healthy person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(12),
                TextFormField(
                  controller: _achieveController,
                  decoration: const InputDecoration(
                    labelText: 'What will you achieve?',
                    hintText: 'e.g., Better posture',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(32),

                // Save Button
                FilledButton.icon(
                  onPressed: _saveHabit,
                  icon: const Icon(Icons.save),
                  label: const Text('Create Habit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

