import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';

class AtomizeApp extends StatelessWidget {
  const AtomizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomize',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
