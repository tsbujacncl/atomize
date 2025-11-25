import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular timer widget with a flame icon in the center.
///
/// Displays progress as a ring that fills clockwise with smooth animation.
class TimerCircle extends StatefulWidget {
  /// Progress from 0.0 (not started) to 1.0 (complete).
  final double progress;

  /// Remaining time formatted as MM:SS.
  final String timeText;

  /// Whether the timer is currently paused.
  final bool isPaused;

  /// Whether the timer has completed.
  final bool isCompleted;

  /// Size of the circle.
  final double size;

  const TimerCircle({
    super.key,
    required this.progress,
    required this.timeText,
    this.isPaused = false,
    this.isCompleted = false,
    this.size = 280,
  });

  @override
  State<TimerCircle> createState() => _TimerCircleState();
}

class _TimerCircleState extends State<TimerCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void didUpdateWidget(TimerCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      // Animate from current animated value to new progress
      _previousProgress = _progressAnimation.value;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _controller.forward(from: 0.0);
    }

    // Stop animation when paused
    if (widget.isPaused && !oldWidget.isPaused) {
      _controller.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor =
        widget.isCompleted ? Colors.green : theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedProgress = _progressAnimation.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: animatedProgress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  progressColor: progressColor,
                  strokeWidth: 12,
                ),
              ),

              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flame icon that grows with progress
                  _AnimatedFlame(
                    progress: animatedProgress,
                    isCompleted: widget.isCompleted,
                    isPaused: widget.isPaused,
                  ),

                  const SizedBox(height: 8),

                  // Time display
                  Text(
                    widget.timeText,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  if (widget.isPaused) ...[
                    const SizedBox(height: 4),
                    Text(
                      'PAUSED',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated flame icon that grows as progress increases.
class _AnimatedFlame extends StatelessWidget {
  final double progress;
  final bool isCompleted;
  final bool isPaused;

  const _AnimatedFlame({
    required this.progress,
    required this.isCompleted,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    // Scale flame from 1.0 to 1.5 based on progress
    final scale = 1.0 + (progress * 0.5);
    // Opacity increases slightly with progress
    final opacity = isPaused ? 0.5 : (0.7 + (progress * 0.3));

    final color = isCompleted
        ? Colors.green
        : Color.lerp(
            Colors.orange.shade300,
            Colors.deepOrange,
            progress,
          );

    return Transform.scale(
      scale: scale,
      child: Icon(
        isCompleted ? Icons.check_circle : Icons.local_fire_department,
        size: 64,
        color: color?.withValues(alpha: opacity),
      ),
    );
  }
}

/// Custom painter for the circular progress ring.
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
