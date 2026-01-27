import 'package:flutter/material.dart';

/// App-wide design constants for consistent styling
abstract final class AppConstants {
  // ============================================
  // COLORS
  // ============================================

  /// Primary brand color (green)
  static const Color primaryColor = Color(0xFF89BD40);

  /// Scaffold background color
  static const Color scaffoldBackground = Color(0xFFF8FAFC);

  /// Action colors for different contexts
  static const Color indigoAction = Color(0xFF6366F1);
  static const Color emeraldAction = Color(0xFF0E9A4A);
  static const Color amberAction = Color(0xFFD1870A);
  static const Color errorAction = Color(0xFFDC2626);

  // ============================================
  // BORDER RADII
  // ============================================

  /// Extra small radius (color swatches, small indicators)
  static const double radiusXS = 4.0;

  /// Small radius (badges)
  static const double radiusS = 10.0;

  /// Medium radius (amount badges, form elements)
  static const double radiusM = 12.0;

  /// Standard radius (glass buttons)
  static const double radiusL = 14.0;

  /// Large radius (cards, tiles, standard buttons)
  static const double radiusXL = 16.0;

  /// Extra large radius (action buttons)
  static const double radiusXXL = 18.0;

  /// Round radius (dialogs, large containers)
  static const double radiusRound = 20.0;

  /// Pill radius (bottom nav, large rounded elements)
  static const double radiusPill = 24.0;

  // ============================================
  // COMPONENT HEIGHTS
  // ============================================

  /// Glass icon button height
  static const double glassButtonSize = 46.0;

  /// Inline/compact action button
  static const double buttonHeightCompact = 50.0;

  /// Standard action button in dialogs/sheets
  static const double buttonHeightStandard = 56.0;

  /// Subtotal button height
  static const double buttonHeightSubtotal = 58.0;

  /// Default action button height
  static const double buttonHeightDefault = 64.0;

  /// App bar and bottom nav height
  static const double appBarHeight = 70.0;

  /// Sum button height
  static const double buttonHeightSum = 72.0;

  /// Large button height
  static const double buttonHeightLarge = 80.0;

  // ============================================
  // ICON SIZES
  // ============================================

  /// Small icon size
  static const double iconSizeS = 22.0;

  /// Standard icon size
  static const double iconSizeM = 24.0;

  /// Large icon size
  static const double iconSizeL = 26.0;

  /// Extra large icon size
  static const double iconSizeXL = 40.0;

  // ============================================
  // SPACING
  // ============================================

  /// Extra small spacing
  static const double spacingXS = 4.0;

  /// Small spacing
  static const double spacingS = 8.0;

  /// Medium spacing
  static const double spacingM = 12.0;

  /// Standard spacing
  static const double spacingL = 16.0;

  /// Large spacing
  static const double spacingXL = 20.0;

  /// Extra large spacing
  static const double spacingXXL = 24.0;

  // ============================================
  // OPACITY VALUES
  // ============================================

  /// Subtle background opacity
  static const double opacitySubtle = 0.12;

  /// Light background opacity
  static const double opacityLight = 0.24;

  /// Medium border/overlay opacity
  static const double opacityMedium = 0.3;

  /// Disabled state opacity
  static const double opacityDisabled = 0.4;

  /// Strong background opacity
  static const double opacityStrong = 0.7;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  /// Fast animation (tap feedback)
  static const Duration animationFast = Duration(milliseconds: 100);

  /// Standard animation
  static const Duration animationStandard = Duration(milliseconds: 150);

  /// Slow animation (transitions)
  static const Duration animationSlow = Duration(milliseconds: 200);

  // ============================================
  // BORDER WIDTHS
  // ============================================

  /// Standard border width
  static const double borderWidth = 1.5;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Standard border radius
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);

  /// Action button border radius
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);

  /// Pill/round border radius
  static BorderRadius get borderRadiusPill => BorderRadius.circular(radiusPill);
}
