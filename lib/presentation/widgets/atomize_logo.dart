import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// The Atomize logo wordmark with gradient text and inline atom icon.
///
/// Design:
/// - "Atomize" with capital A only
/// - The "o" is replaced with an atom icon (atom.png image)
/// - Blue (#3B82F6) to indigo (#6366F1) gradient left-to-right
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

    // Atom icon size proportional to font (20% smaller than text)
    final iconSize = fontSize * 0.8;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.flameBlue, AppColors.accent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('At', style: textStyle),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize * 0.02),
            child: Image.asset(
              'assets/images/atom.png',
              width: iconSize,
              height: iconSize,
              color: Colors.white, // Will be colored by ShaderMask
            ),
          ),
          Text('mize', style: textStyle),
        ],
      ),
    );
  }
}

/// A larger version of the logo for splash/onboarding screens.
class AtomizeLogoLarge extends StatelessWidget {
  const AtomizeLogoLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const AtomizeLogo(fontSize: 48);
  }
}
