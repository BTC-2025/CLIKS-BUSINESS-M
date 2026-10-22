import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/customer_view_settings_model.dart';

class CustomerThemeHelper {
  /// Resolves the configured font family dynamically with font size scaling and weight tuning.
  static TextStyle font(
    CustomerViewSettings settings, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    final scaledSize = fontSize * settings.fontSizeScale;
    final effectiveWeight = _adjustWeight(fontWeight, settings.fontWeightPreset);
    final family = settings.fontFamily.trim().toLowerCase();

    try {
      switch (family) {
        case 'poppins':
          return GoogleFonts.poppins(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'roboto':
          return GoogleFonts.roboto(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'outfit':
          return GoogleFonts.outfit(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'montserrat':
          return GoogleFonts.montserrat(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'plus jakarta sans':
          return GoogleFonts.plusJakartaSans(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'playfair display':
          return GoogleFonts.playfairDisplay(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'dm sans':
          return GoogleFonts.dmSans(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
        case 'inter':
        default:
          return GoogleFonts.inter(
            fontSize: scaledSize,
            fontWeight: effectiveWeight,
            color: color,
            letterSpacing: letterSpacing,
            height: height,
            fontStyle: fontStyle,
            decoration: decoration,
          );
      }
    } catch (_) {
      return GoogleFonts.inter(
        fontSize: scaledSize,
        fontWeight: effectiveWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
      );
    }
  }

  static FontWeight _adjustWeight(FontWeight base, String preset) {
    if (preset == 'Bold') {
      if (base == FontWeight.w400 || base == FontWeight.normal) return FontWeight.w600;
      if (base == FontWeight.w500) return FontWeight.w700;
      if (base == FontWeight.w600) return FontWeight.w800;
      return FontWeight.w900;
    } else if (preset == 'Light') {
      if (base == FontWeight.w800 || base == FontWeight.w900) return FontWeight.w700;
      if (base == FontWeight.w700 || base == FontWeight.w600) return FontWeight.w500;
      if (base == FontWeight.w500) return FontWeight.w400;
      return FontWeight.w300;
    }
    return base;
  }

  /// Formats currency with the configured symbol.
  static String formatPrice(CustomerViewSettings settings, double amount) {
    final sym = settings.currencySymbol;
    final isWhole = amount.truncateToDouble() == amount;
    return '$sym${isWhole ? amount.toInt() : amount.toStringAsFixed(2)}';
  }

  /// Returns surface background color based on tint and dark mode.
  static Color surfaceBackground(CustomerViewSettings settings) {
    if (settings.isDarkMode) {
      return const Color(0xFF0F172A); // Slate 900
    }
    switch (settings.surfaceTint) {
      case 'cream':
        return const Color(0xFFFDFBF7);
      case 'frost':
        return const Color(0xFFF1F5F9);
      case 'slate':
        return const Color(0xFFF8FAFC);
      default:
        return const Color(0xFFF8F9FA);
    }
  }

  /// Returns card surface color based on dark mode.
  static Color cardBackground(CustomerViewSettings settings) {
    if (settings.isDarkMode) {
      return const Color(0xFF1E293B);
    }
    return Colors.white;
  }

  /// Returns corner radius using the settings configuration or custom default.
  static double borderRadius(CustomerViewSettings settings, {double defaultRadius = 14}) {
    if (settings.borderRadius > 0) {
      return settings.borderRadius;
    }
    return defaultRadius;
  }
}
