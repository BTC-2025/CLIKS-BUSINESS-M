import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      primaryColor: AppColors.primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen, // Color(0xFF166534)
        secondary: AppColors.actionBlue,
        surface: AppColors.surfaceWhite,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground, // Color(0xFFF8FAFC)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.headerBackground, // Color(0xFF135029)
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        displaySmall: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        headlineLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        headlineMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        headlineSmall: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 13.0, // Base font size: 13px per typography spec
          fontWeight: FontWeight.w400, // Normal weight: FontWeight.w400
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.secondaryText, // Color(0xFF475569)
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        labelMedium: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.bold, // Heading text style bold per spec
          color: AppColors.darkText, // Color(0xFF1E293B)
        ),
        dataTextStyle: GoogleFonts.inter(
          fontSize: 13.0, // Data text style Inter at 13pt per spec
          fontWeight: FontWeight.w400,
          color: AppColors.darkText, // Color(0xFF1E293B)
        ),
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        dividerThickness: 1,
        horizontalMargin: 20.0,
        columnSpacing: 20.0,
        headingRowHeight: 52.0,
        dataRowMinHeight: 48.0,
        dataRowMaxHeight: 52.0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen, // Color(0xFF166534)
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Low borderRadius (4.0 - 8.0)
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: GoogleFonts.inter(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Low borderRadius (4.0 - 8.0)
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.border),
          textStyle: GoogleFonts.inter(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Low borderRadius (4.0 - 8.0)
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 13.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
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
