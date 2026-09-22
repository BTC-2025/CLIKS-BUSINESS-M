import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/text_styles.dart';

/// Maximum allowed transaction amount matching Zoho Books & Inventory standards:
/// Up to 12 digits before decimal, 2 digits after decimal (₹9,99,99,99,99,999.99).
const double kMaxAllowedAmount = 999999999999.99;
const String kMaxAllowedAmountText = '₹9,99,99,99,99,999.99';

/// Currency & Amount input formatter matching Zoho Books / Zoho Inventory standards:
/// - Maximum [integerDigits] digits before decimal point (default: 12, up to 999,999,999,999 or 99,999 Crores)
/// - Maximum [decimalDigits] digits after decimal (default: 2)
/// - Prevents multiple decimals, negative numbers, symbols, non-digits, and integer overflows.
class CurrencyInputFormatter extends TextInputFormatter {
  final int integerDigits;
  final int decimalDigits;

  const CurrencyInputFormatter({
    this.integerDigits = 12,
    this.decimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Handle leading dot: automatically prepend 0
    if (text == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    final pattern = decimalDigits > 0
        ? '^\\d{0,$integerDigits}(\\.\\d{0,$decimalDigits})?\$'
        : '^\\d{0,$integerDigits}\$';

    if (RegExp(pattern).hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

enum SnackType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _snackConfig(type);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: config.background,
              borderRadius: AppRadius.sm,
              border: Border.all(color: config.border),
              boxShadow: [
                BoxShadow(
                  color: config.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: config.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config.icon, color: config.iconColor, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: config.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static _SnackConfig _snackConfig(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          background: const Color(0xFFF0FDF4),
          border: const Color(0xFF86EFAC),
          icon: LucideIcons.checkCircle2,
          iconColor: AppColors.success,
          iconBg: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF166534),
          shadow: AppColors.success.withValues(alpha: 0.12),
        );
      case SnackType.error:
        return _SnackConfig(
          background: const Color(0xFFFFF1F2),
          border: const Color(0xFFFCA5A5),
          icon: LucideIcons.xCircle,
          iconColor: AppColors.red,
          iconBg: const Color(0xFFFFE4E6),
          textColor: const Color(0xFF9B1C1C),
          shadow: AppColors.red.withValues(alpha: 0.12),
        );
      case SnackType.warning:
        return _SnackConfig(
          background: const Color(0xFFFFFBEB),
          border: const Color(0xFFFCD34D),
          icon: LucideIcons.alertTriangle,
          iconColor: AppColors.yellow,
          iconBg: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
          shadow: AppColors.yellow.withValues(alpha: 0.12),
        );
      case SnackType.info:
        return _SnackConfig(
          background: const Color(0xFFEFF6FF),
          border: const Color(0xFF93C5FD),
          icon: LucideIcons.info,
          iconColor: AppColors.blue,
          iconBg: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1E40AF),
          shadow: AppColors.blue.withValues(alpha: 0.12),
        );
    }
  }
}

class _SnackConfig {
  final Color background, border, iconColor, iconBg, textColor, shadow;
  final IconData icon;

  _SnackConfig({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.textColor,
    required this.shadow,
  });
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.hoverBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: AppColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title,
            style: AppTextStyles.h3.copyWith(color: AppColors.darkText),
            textAlign: TextAlign.center),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center),
        ],
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: Text(actionLabel!),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            ),
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: isMacOS ? content : content.animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.alertTriangle,
              size: 40, color: AppColors.red),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Something went wrong',
            style: AppTextStyles.h3.copyWith(color: AppColors.darkText),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            ),
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: isMacOS ? content : content.animate().fadeIn(duration: 350.ms),
      ),
    );
  }
}

class AppLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingSpinner({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const AppSkeletonCard({super.key, this.width, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.sm,
        ),
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const AppSkeletonList({super.key, this.count = 5, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => AppSkeletonCard(height: itemHeight),
    );
  }
}

enum BadgeType { success, error, warning, info, neutral }

class AppStatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const AppStatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.round,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  (Color, Color) _colors(BadgeType t) {
    switch (t) {
      case BadgeType.success: return (const Color(0xFFDCFCE7), const Color(0xFF166534));
      case BadgeType.error:   return (const Color(0xFFFFE4E6), const Color(0xFF9B1C1C));
      case BadgeType.warning: return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
      case BadgeType.info:    return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
      case BadgeType.neutral: return (const Color(0xFFF1F5F9), const Color(0xFF475569));
    }
  }
}

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.darkText)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class AppLabeledDivider extends StatelessWidget {
  final String label;
  const AppLabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
