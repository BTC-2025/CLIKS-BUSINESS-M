import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.5,
      );

  /// H1: 700 (Bold)
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.3,
        height: 1.5,
      );

  /// H2: 700 (Bold)
  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.2,
        height: 1.5,
      );

  /// H3: 600 (Semi-bold)
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        height: 1.5,
      );

  /// H4: 600 (Semi-bold)
  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  /// Base Font Size: 13px (approx 13.0 in Flutter), Normal Weight: FontWeight.w400
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.5,
      );

  /// Table Header: 13pt bold Inter
  static TextStyle get tableHeader => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        height: 1.5,
      );

  /// Table Data: 13pt regular Inter
  static TextStyle get tableData => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  /// Primary Green Text
  static TextStyle get primaryGreenText => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
        height: 1.5,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
        letterSpacing: 0.2,
        height: 1.5,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryText,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get statLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.5,
      );

  static TextStyle get statMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.2,
        height: 1.5,
      );
}

/// Alias for AppTextStyles conforming to design system naming convention
typedef AppTypography = AppTextStyles;

