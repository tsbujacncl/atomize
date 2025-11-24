import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/widgets/flame_widget.dart';

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
      home: const PlaceholderHomeScreen(),
    );
  }
}

/// Temporary placeholder until HomeScreen is implemented in Milestone 5
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomize'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Demo flame at different scores
            const FlameWidget(score: 25, size: 80),
            const SizedBox(height: 16),
            Text(
              'Atomize V1.2',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Small habits. Big change.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 48),
            // Score demo row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScoreDemo(score: 0),
                _ScoreDemo(score: 40),
                _ScoreDemo(score: 70),
                _ScoreDemo(score: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDemo extends StatelessWidget {
  final double score;

  const _ScoreDemo({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlameWidget(score: score, size: 48),
        const SizedBox(height: 4),
        Text(
          '${score.round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
