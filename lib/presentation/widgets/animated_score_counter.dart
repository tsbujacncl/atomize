import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// An animated counter that smoothly transitions between score values.
///
/// When the score changes, the number counts up/down and the color
/// transitions through the flame color spectrum. Includes a subtle
/// scale "pop" effect for emphasis.
class AnimatedScoreCounter extends StatefulWidget {
  /// The current score (0-100)
  final double score;

  /// Base text style (color will be overridden by flame color)
  final TextStyle? style;

  const AnimatedScoreCounter({
    super.key,
    required this.score,
    this.style,
  });

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _scaleAnimation;
  double _displayScore = 0;

  @override
  void initState() {
    super.initState();
    _displayScore = widget.score;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scoreAnimation = AlwaysStoppedAnimation(widget.score);

    // Scale animation: 1.0 -> 1.15 -> 1.0 (pop effect)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 60,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      setState(() {
        _displayScore = _scoreAnimation.value;
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.score != widget.score) {
      _animateToNewScore(oldWidget.score, widget.score);
    }
  }

  void _animateToNewScore(double fromScore, double toScore) {
    _scoreAnimation = Tween<double>(
      begin: fromScore,
      end: toScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFlameColor(_displayScore);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
          child: Text(
            '${_displayScore.round()}',
            style: widget.style?.copyWith(color: color) ??
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      },
    );
  }
}
