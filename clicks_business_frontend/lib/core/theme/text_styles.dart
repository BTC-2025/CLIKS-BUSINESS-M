import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.secondaryText,
        height: 1.5,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: AppColors.darkText,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
        letterSpacing: 0.3,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.0,
      );

  static TextStyle get overline => GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryText,
        letterSpacing: 1.0,
      );

  static TextStyle get statLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        letterSpacing: -1.0,
        height: 1.0,
      );

  static TextStyle get statMedium => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        letterSpacing: -0.5,
        height: 1.0,
      );
}
