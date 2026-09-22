import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF0F5B2E);
  static const Color darkGreen = Color(0xFF084421);
  static const Color accentGreen = Color(0xFF1F7A46);
  static const Color success = Color(0xFF27AE60);
  
  static const Color background = Color(0xFFF5F7F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6EBEF);
  
  static const Color darkText = Color(0xFF132238);
  static const Color secondaryText = Color(0xFF6B7280);
  
  static const Color blue = Color(0xFF0D5BD7);
  static const Color purpleAccent = Color(0xFF7B61FF);
  static const Color red = Color(0xFFE74C3C);
  static const Color yellow = Color(0xFFF2C94C);
  
  static const Color hoverBackground = Color(0xFFEEF7F0);
  static const Color sidebarBackground = Color(0xFFEAF6EC);

  // macOS-specific palette tokens
  static const Color macosDarkGreen = Color(0xFF135029);
  static const Color macosLightGreen = Color(0xFFEAFAE3);

  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns stylish dark green #135029 on macOS, and #0F5B2E on other platforms
  static Color get stylishDarkGreen => isMacOS ? macosDarkGreen : primaryGreen;

  /// Returns light green highlight #EAFAE3 on macOS, and #E8F5E9 on other platforms
  static Color get lightGreenHighlight => isMacOS ? macosLightGreen : const Color(0xFFE8F5E9);

  /// Gradient colors for statistics hero cards across sections.
  /// On macOS: strictly NO gradient, pure solid dark green #135029.
  static List<Color> get heroGradientColors => isMacOS
      ? const [Color(0xFF135029), Color(0xFF135029)]
      : const [Color(0xFF0F5B2E), Color(0xFF1A7A42), Color(0xFF22905A)];

  /// Shadow color for statistics hero cards across sections
  static Color get heroShadowColor => isMacOS
      ? const Color(0xFF135029).withValues(alpha: 0.25)
      : const Color(0xFF0F5B2E).withValues(alpha: 0.25);
}
