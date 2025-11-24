import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A widget that displays an animated flame representing habit score.
///
/// The flame color changes based on score:
/// - 0-30: Blue (cold/starting)
/// - 30-50: Blue→Orange transition
/// - 50-80: Orange (building momentum)
/// - 80-95: Orange→Red transition
/// - 95-100: Red with golden/white core (mastered)
class FlameWidget extends StatefulWidget {
  /// The current score (0-100)
  final double score;

  /// Size of the flame (width and height)
  final double size;

  /// Whether to animate the flame
  final bool animate;

  /// Callback when flame is tapped
  final VoidCallback? onTap;

  /// Whether the habit is completed today
  final bool isCompleted;

  const FlameWidget({
    super.key,
    required this.score,
    this.size = 48,
    this.animate = true,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  State<FlameWidget> createState() => _FlameWidgetState();
}

class _FlameWidgetState extends State<FlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _flickerAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FlameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flameColor = AppColors.getFlameColor(widget.score);
    final coreColor = AppColors.getFlameCoreColor(widget.score);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flickerAnimation,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _FlamePainter(
                color: flameColor,
                coreColor: coreColor,
                flickerScale: widget.animate ? _flickerAnimation.value : 1.0,
                isCompleted: widget.isCompleted,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final Color color;
  final Color? coreColor;
  final double flickerScale;
  final bool isCompleted;

  _FlamePainter({
    required this.color,
    this.coreColor,
    required this.flickerScale,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    final maxRadius = math.min(size.width, size.height) * 0.4;

    // Apply flicker scale
    final radius = maxRadius * flickerScale;

    // Main flame body (gradient from color to transparent)
    final flamePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.4),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw main flame shape
    final flamePath = _createFlamePath(center, radius, size);
    canvas.drawPath(flamePath, flamePaint);

    // Draw core if score is high enough
    if (coreColor != null) {
      final coreRadius = radius * 0.35;
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            coreColor!,
            coreColor!.withValues(alpha: 0.7),
            coreColor!.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: center, radius: coreRadius));

      canvas.drawCircle(center, coreRadius * flickerScale, corePaint);
    }

    // Draw completion checkmark if completed
    if (isCompleted) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final checkPath = Path()
        ..moveTo(center.dx - radius * 0.25, center.dy)
        ..lineTo(center.dx - radius * 0.05, center.dy + radius * 0.2)
        ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.15);

      canvas.drawPath(checkPath, checkPaint);
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius * 0.8, glowPaint);
  }

  Path _createFlamePath(Offset center, double radius, Size size) {
    final path = Path();

    // Flame shape - teardrop pointing upward
    final tipY = center.dy - radius * 1.4;
    final bottomY = center.dy + radius * 0.5;

    path.moveTo(center.dx, tipY);

    // Right side curve
    path.cubicTo(
      center.dx + radius * 0.8,
      center.dy - radius * 0.5,
      center.dx + radius * 0.9,
      center.dy + radius * 0.3,
      center.dx,
      bottomY,
    );

    // Left side curve (mirror)
    path.cubicTo(
      center.dx - radius * 0.9,
      center.dy + radius * 0.3,
      center.dx - radius * 0.8,
      center.dy - radius * 0.5,
      center.dx,
      tipY,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.coreColor != coreColor ||
        oldDelegate.flickerScale != flickerScale ||
        oldDelegate.isCompleted != isCompleted;
  }
}

/// A compact flame indicator for list views.
///
/// Shows a small flame icon with score percentage.
class FlameIndicator extends StatelessWidget {
  final double score;
  final double size;
  final bool showPercentage;

  const FlameIndicator({
    super.key,
    required this.score,
    this.size = 24,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFlameColor(score);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          color: color,
          size: size,
        ),
        if (showPercentage) ...[
          const SizedBox(width: 4),
          Text(
            '${score.round()}%',
            style: TextStyle(
              color: color,
              fontSize: size * 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
