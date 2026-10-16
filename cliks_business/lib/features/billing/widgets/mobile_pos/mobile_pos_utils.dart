import 'package:flutter/material.dart';

class MobilePosColors {
  static const primaryGreen = Color(0xFF135029);
  static const darkGreen = Color(0xFF166534);
  static const lightGreen = Color(0xFFEAFAE3);
  static const accentGreen = Color(0xFF15803D);
  static const surfaceBg = Color(0xFFF8F9FA);
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFFFBEB);
  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFFEFF6FF);
  static const purple = Color(0xFF7C3AED);
}

String formatIndianCurrency(double amount) {
  final isNegative = amount < 0;
  final absVal = amount.abs();
  final parts = absVal
      .toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)
      .split('.');
  String whole = parts[0];
  final dec = parts.length > 1 && parts[1] != '00' ? '.${parts[1]}' : '';

  if (whole.length > 3) {
    final lastThree = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    whole = '${buffer.toString()},$lastThree';
  }

  return '${isNegative ? '-' : ''}$whole$dec';
}
