import 'package:flutter/material.dart';

/// Application color palette.
///
/// Following the design document's minimalist, anti-addictive philosophy.
/// Colors are calming and supportive rather than gamified/dopamine-inducing.
abstract final class AppColors {
  // ============== Accent ==============

  /// Primary accent color - calm teal
  static const Color accent = Color(0xFF4ECDC4);

  /// Lighter variant of accent
  static const Color accentLight = Color(0xFF7EDDD7);

  /// Darker variant of accent
  static const Color accentDark = Color(0xFF2E9D96);

  // ============== Flame Colors by Score ==============

  /// Blue flame for scores 0-30 (starting/cold)
  static const Color flameBlue = Color(0xFF3B82F6);

  /// Orange flame for scores 50-80 (building)
  static const Color flameOrange = Color(0xFFF97316);

  /// Red flame for scores 80-95 (strong)
  static const Color flameRed = Color(0xFFEF4444);

  /// Gold core for score 95-100 (mastered)
  static const Color flameGold = Color(0xFFFBBF24);

  /// White core for perfect score (100)
  static const Color flameWhite = Color(0xFFFFFBEB);

  // ============== Light Theme ==============

  /// Light theme background
  static const Color lightBackground = Color(0xFFFAFAFA);

  /// Light theme surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme card
  static const Color lightCard = Color(0xFFFFFFFF);

  /// Light theme primary text
  static const Color lightTextPrimary = Color(0xFF1F2937);

  /// Light theme secondary text
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Light theme tertiary text
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  /// Light theme divider
  static const Color lightDivider = Color(0xFFE5E7EB);

  // ============== Dark Theme ==============

  /// Dark theme background
  static const Color darkBackground = Color(0xFF111827);

  /// Dark theme surface
  static const Color darkSurface = Color(0xFF1F2937);

  /// Dark theme card
  static const Color darkCard = Color(0xFF374151);

  /// Dark theme primary text
  static const Color darkTextPrimary = Color(0xFFF9FAFB);

  /// Dark theme secondary text
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// Dark theme tertiary text
  static const Color darkTextTertiary = Color(0xFF6B7280);

  /// Dark theme divider
  static const Color darkDivider = Color(0xFF374151);

  // ============== Semantic Colors ==============

  /// Success color (used sparingly)
  static const Color success = Color(0xFF10B981);

  /// Warning color
  static const Color warning = Color(0xFFF59E0B);

  /// Error color
  static const Color error = Color(0xFFEF4444);

  // ============== Flame Color Helpers ==============

  /// Get the flame color for a given score (0-100).
  ///
  /// Color progression:
  /// - 0-30: Blue (#3B82F6)
  /// - 30-50: Blue→Orange gradient
  /// - 50-80: Orange (#F97316)
  /// - 80-95: Orange→Red gradient
  /// - 95-100: Red (#EF4444) with golden core
  static Color getFlameColor(double score) {
    if (score < 30) {
      return flameBlue;
    } else if (score < 50) {
      // Transition from blue to orange
      final t = (score - 30) / 20;
      return Color.lerp(flameBlue, flameOrange, t)!;
    } else if (score < 80) {
      return flameOrange;
    } else if (score < 95) {
      // Transition from orange to red
      final t = (score - 80) / 15;
      return Color.lerp(flameOrange, flameRed, t)!;
    } else {
      return flameRed;
    }
  }

  /// Get the flame core color for high scores.
  ///
  /// Returns null for scores below 95.
  /// - 95-99: Golden core
  /// - 100: White core
  static Color? getFlameCoreColor(double score) {
    if (score < 95) return null;
    if (score >= 100) return flameWhite;
    return flameGold;
  }

  /// Get a list of gradient colors for the flame.
  ///
  /// Returns multiple colors for richer flame effect.
  static List<Color> getFlameGradient(double score) {
    final main = getFlameColor(score);
    final core = getFlameCoreColor(score);

    if (core != null) {
      return [core, main, main.withValues(alpha: 0.8)];
    }

    return [
      main,
      main.withValues(alpha: 0.9),
      main.withValues(alpha: 0.7),
    ];
  }
}
