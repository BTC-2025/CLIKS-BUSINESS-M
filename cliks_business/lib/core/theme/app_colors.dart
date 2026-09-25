import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppColors {
  // ─── Background Colors ───
  /// Main Background: rgb(240, 253, 244) (a very light mint green)
  static const Color background = Color(0xFFF0FDF4);
  static const Color sidebarBackground = Color(0xFFF0FDF4);

  /// Footer/Secondary Area: rgb(255, 255, 255) (White)
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color footerArea = Color(0xFFFFFFFF);
  static const Color secondaryArea = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  /// Other Accents
  /// rgb(220, 242, 228) (light green)
  static const Color accentLightGreen = Color(0xFFDCF2E4);
  /// rgb(239, 246, 255) (light blue)
  static const Color accentLightBlue = Color(0xFFEFF6FF);
  /// rgb(11, 19, 41) (dark navy/black)
  static const Color accentDarkNavy = Color(0xFF0B1329);

  // ─── Text Colors ───
  /// Primary Text: rgb(22, 101, 52) (dark forest green)
  static const Color primaryText = Color(0xFF166534);
  static const Color primaryGreen = Color(0xFF166534);
  static const Color darkGreen = Color(0xFF166534);
  static const Color accentGreen = Color(0xFF166534);
  static const Color success = Color(0xFF166534);

  /// Secondary/Neutral Text:
  /// rgb(17, 24, 39) (very dark gray/black)
  static const Color darkText = Color(0xFF111827);
  /// rgb(55, 65, 81) (muted gray)
  static const Color secondaryText = Color(0xFF374151);

  /// Action/Link Text: rgb(37, 99, 235) (vibrant blue)
  static const Color actionBlue = Color(0xFF2563EB);
  static const Color blue = Color(0xFF2563EB);

  /// Contrast Text: rgb(255, 255, 255) (white, on dark backgrounds)
  static const Color contrastText = Color(0xFFFFFFFF);

  // ─── Border Colors ───
  /// Default Borders: rgb(229, 231, 235) (standard light gray)
  static const Color border = Color(0xFFE5E7EB);
  static const Color defaultBorder = Color(0xFFE5E7EB);

  /// Greenish Borders: rgb(220, 242, 228) and rgb(216, 243, 229)
  static const Color borderGreenLight = Color(0xFFDCF2E4);
  static const Color borderGreen = Color(0xFFD8F3E5);

  // Additional helper UI colors
  static const Color purpleAccent = Color(0xFF7B61FF);
  static const Color red = Color(0xFFE74C3C);
  static const Color yellow = Color(0xFFF2C94C);
  static const Color hoverBackground = Color(0xFFDCF2E4);

  // macOS-specific palette tokens
  static const Color macosDarkGreen = Color(0xFF166534);
  static const Color macosLightGreen = Color(0xFFDCF2E4);

  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns stylish dark green #166534 on macOS
  static Color get stylishDarkGreen => isMacOS ? macosDarkGreen : primaryGreen;

  /// Returns light green highlight #DCF2E4 on macOS
  static Color get lightGreenHighlight => isMacOS ? macosLightGreen : accentLightGreen;

  /// Colors for statistics hero cards across sections.
  /// Universal solid dark green #166534 matching header.
  static List<Color> get heroGradientColors =>
      const [Color(0xFF166534), Color(0xFF166534)];

  /// Shadow color for statistics hero cards across sections
  static Color get heroShadowColor => isMacOS
      ? const Color(0xFF166534).withValues(alpha: 0.25)
      : const Color(0xFF166534).withValues(alpha: 0.25);
}
