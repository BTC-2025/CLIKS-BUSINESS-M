import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.actionBlue,
        surface: AppColors.cardBackground,
        background: AppColors.background,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 32,
          fontWeight: FontWeight.w900, // H1 850 / Black
          height: 1.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 26,
          fontWeight: FontWeight.w800, // H2 800
          height: 1.5,
        ),
        displaySmall: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w900, // H3 950
          height: 1.5,
        ),
        headlineLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
        headlineMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
        headlineSmall: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          height: 1.5,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 14.5, // Base font size
          fontWeight: FontWeight.w400, // Regular
          height: 1.5, // Line height 1.5
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
}
