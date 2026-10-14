import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppColors {
  // ─── Tailwind-style Green/Slate Theme Palette ───
  /// Header Background (Deep Green): rgb(19, 80, 41)
  static const Color headerBackground = Color(0xFF135029);
  static const Color deepGreen = Color(0xFF135029);

  /// Primary Text / Primary Green: rgb(22, 101, 52)
  static const Color primaryGreen = Color(0xFF166534);
  static const Color primaryText = Color(0xFF166534);
  static const Color darkGreen = Color(0xFF166534);
  static const Color accentGreen = Color(0xFF166534);
  static const Color success = Color(0xFF166534);

  /// Background (Light Green): rgb(240, 253, 244)
  static const Color backgroundLightGreen = Color(0xFFF0FDF4);
  static const Color lightGreenBackground = Color(0xFFF0FDF4);
  static const Color sidebarBackground = Color(0xFFF0FDF4);

  /// Scaffold Background: Color(0xFFF8FAFC)
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF8FAFC);

  /// Surface / White: rgb(255, 255, 255)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color footerArea = Color(0xFFFFFFFF);
  static const Color secondaryArea = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  /// Text (Slate/Dark): rgb(30, 41, 59)
  static const Color textSlateDark = Color(0xFF1E293B);
  static const Color darkText = Color(0xFF1E293B);

  /// Secondary Text: rgb(71, 85, 105)
  static const Color secondaryText = Color(0xFF475569);
  static const Color textSlateSecondary = Color(0xFF475569);

  /// Border Color (Tailwind Slate/Gray #E5E7EB): rgb(229, 231, 235)
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderSlate = Color(0xFFE5E7EB);
  static const Color defaultBorder = Color(0xFFE5E7EB);

  /// Table Border: rgb(229, 231, 235) / #e5e7eb
  static const Color tableBorder = Color(0xFFE5E7EB);

  /// Greenish Borders: rgb(220, 242, 228) and rgb(216, 243, 229)
  static const Color borderGreenLight = Color(0xFFDCF2E4);
  static const Color borderGreen = Color(0xFFD8F3E5);

  /// Other Accents
  static const Color accentLightGreen = Color(0xFFDCF2E4);
  static const Color accentLightBlue = Color(0xFFEFF6FF);
  static const Color accentDarkNavy = Color(0xFF0B1329);
  static const Color actionBlue = Color(0xFF2563EB);
  static const Color blue = Color(0xFF2563EB);
  static const Color contrastText = Color(0xFFFFFFFF);

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
  static List<Color> get heroGradientColors =>
      const [Color(0xFF166534), Color(0xFF166534)];

  /// Shadow color for statistics hero cards across sections
  static Color get heroShadowColor =>
      const Color(0xFF166534).withValues(alpha: 0.25);
}
