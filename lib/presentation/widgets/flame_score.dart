import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'animated_score_counter.dart';

/// A widget that displays a flame icon with the score value.
///
/// The flame color changes based on score level (blue → orange → red),
/// and the score number animates when it changes.
class FlameScore extends StatelessWidget {
  /// The current score (0-100)
  final double score;

  /// Size of the widget
  final double size;

  const FlameScore({
    super.key,
    required this.score,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFlameColor(score);

    return SizedBox(
      width: size,
      height: size + 8, // Extra space for the score text
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flame icon
          Icon(
            Icons.local_fire_department,
            size: size * 0.65,
            color: color,
          ),
          // Score number
          AnimatedScoreCounter(
            score: score,
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
