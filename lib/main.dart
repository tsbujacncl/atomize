import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/home/home_screen.dart';
import 'models/habit.dart';
import 'models/habit_log.dart';
import 'models/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitLogAdapter());
  Hive.registerAdapter(HabitPurposeAdapter());
  Hive.registerAdapter(NotificationPreferencesAdapter());
  Hive.registerAdapter(NotificationToneAdapter());

  runApp(const ProviderScope(child: AtomizeApp()));
}

class AtomizeApp extends StatelessWidget {
  const AtomizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomize',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
