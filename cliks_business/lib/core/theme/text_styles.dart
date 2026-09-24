import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.darkText,
        letterSpacing: -1.0,
        height: 1.5,
      );

  /// H1: 850 (Heavy/Black)
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.5,
      );

  /// H2: 800 (Extra Bold)
  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        letterSpacing: -0.3,
        height: 1.5,
      );

  /// H3: 950 (Ultra Black)
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.darkText,
        letterSpacing: -0.2,
        height: 1.5,
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  /// Base Font Size: 14.5px, Base Font Weight: 400 (Regular), Line Height: 1.5
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.5,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
        letterSpacing: 0.3,
        height: 1.5,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryText,
        letterSpacing: 1.0,
        height: 1.5,
      );

  static TextStyle get statLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.darkText,
        letterSpacing: -1.0,
        height: 1.5,
      );

  static TextStyle get statMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.5,
      );
}
