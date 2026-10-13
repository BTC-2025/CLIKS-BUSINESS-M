import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized shadows design system for Bento cards, modals, and hover states.
class AppShadows {
  AppShadows._();

  /// Subtle shadow for resting cards and light tiles
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Standard Bento card resting shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow for hover states and active Bento cards
  static List<BoxShadow> hover = [
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: AppColors.primaryGreen.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// High elevation for floating actions and popovers
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Brand tinted shadow for green CTA buttons and hero banners
  static List<BoxShadow> greenGlow = [
    BoxShadow(
      color: AppColors.primaryGreen.withValues(alpha: 0.22),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
