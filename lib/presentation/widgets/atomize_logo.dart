import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// The Atomize logo wordmark with gradient text and inline flame.
///
/// Design:
/// - "Atomize" with capital A only
/// - The "o" is replaced with a flame icon
/// - Blue (#3B82F6) to orange (#F97316) gradient left-to-right
/// - Static (no animation)
class AtomizeLogo extends StatelessWidget {
  /// Font size for the logo text
  final double fontSize;

  const AtomizeLogo({
    super.key,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: Colors.white, // Base color for ShaderMask
    );

    // Flame size proportional to font (slightly larger than text height)
    final flameSize = fontSize * 1.1;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.flameBlue, AppColors.flameOrange],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('At', style: textStyle),
          SizedBox(
            width: flameSize * 0.75,
            height: flameSize,
            child: CustomPaint(
              painter: _LogoFlamePainter(),
            ),
          ),
          Text('mize', style: textStyle),
        ],
      ),
    );
  }
}

/// A simplified flame painter for the logo.
///
/// No animation, no glow - just the clean flame shape.
/// Color comes from parent ShaderMask.
class _LogoFlamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // Will be colored by ShaderMask
      ..style = PaintingStyle.fill;

    final path = _createFlamePath(size);
    canvas.drawPath(path, paint);
  }

  Path _createFlamePath(Size size) {
    final path = Path();

    final centerX = size.width / 2;
    final centerY = size.height * 0.55;
    final radius = math.min(size.width, size.height) * 0.4;

    // Flame tip (top)
    final tipY = centerY - radius * 1.3;
    // Flame bottom
    final bottomY = centerY + radius * 0.5;

    path.moveTo(centerX, tipY);

    // Right side curve
    path.cubicTo(
      centerX + radius * 0.7,
      centerY - radius * 0.4,
      centerX + radius * 0.8,
      centerY + radius * 0.3,
      centerX,
      bottomY,
    );

    // Left side curve (mirror)
    path.cubicTo(
      centerX - radius * 0.8,
      centerY + radius * 0.3,
      centerX - radius * 0.7,
      centerY - radius * 0.4,
      centerX,
      tipY,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A larger version of the logo for splash/onboarding screens.
class AtomizeLogoLarge extends StatelessWidget {
  const AtomizeLogoLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const AtomizeLogo(fontSize: 48);
  }
}
