import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'models/habit.dart';
import 'models/habit_log.dart';
import 'models/hive_adapters.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitLogAdapter());
  Hive.registerAdapter(HabitPurposeAdapter());
  Hive.registerAdapter(NotificationPreferencesAdapter());
  Hive.registerAdapter(NotificationToneAdapter());

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Check if onboarding is completed
  final settingsBox = await Hive.openBox('settings');
  final bool isOnboardingCompleted = settingsBox.get('onboarding_completed', defaultValue: false);

  runApp(ProviderScope(child: AtomizeApp(showOnboarding: !isOnboardingCompleted)));
}

class AtomizeApp extends StatelessWidget {
  final bool showOnboarding;

  const AtomizeApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomize',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
