import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    final (bg, fg, border) = _colors(disabled);
    final padding = _padding();
    final iconSize = _iconSize();
    final textStyle = _textStyle(fg, disabled);

    Widget child = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else if (widget.leadingIcon != null)
          Icon(widget.leadingIcon, size: iconSize, color: fg),
        if (!widget.isLoading &&
            widget.leadingIcon != null &&
            widget.label.isNotEmpty)
          const SizedBox(width: AppSpacing.xs),
        if (widget.label.isNotEmpty) Text(widget.label, style: textStyle),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(widget.trailingIcon, size: iconSize, color: fg),
        ],
      ],
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && !disabled ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: disabled ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : widget.onPressed,
              borderRadius: AppRadius.sm,
              splashColor: fg.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadius.sm,
                  border: border,
                  boxShadow: widget.variant == AppButtonVariant.primary &&
                          !disabled
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Border?) _colors(bool disabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (AppColors.primaryGreen, Colors.white, null);
      case AppButtonVariant.secondary:
        return (AppColors.primaryGreen.withValues(alpha: 0.1),
            AppColors.primaryGreen, null);
      case AppButtonVariant.outline:
        return (Colors.transparent, AppColors.primaryGreen,
            Border.all(color: AppColors.primaryGreen));
      case AppButtonVariant.ghost:
        return (Colors.transparent, AppColors.secondaryText,
            null);
      case AppButtonVariant.danger:
        return (AppColors.red.withValues(alpha: 0.09), AppColors.red,
            Border.all(color: AppColors.red.withValues(alpha: 0.3)));
    }
  }

  EdgeInsetsGeometry _padding() {
    switch (widget.size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl, vertical: AppSpacing.lg);
    }
  }

  double _iconSize() {
    switch (widget.size) {
      case AppButtonSize.sm: return 14;
      case AppButtonSize.md: return 16;
      case AppButtonSize.lg: return 18;
    }
  }

  TextStyle _textStyle(Color fg, bool disabled) {
    final base = switch (widget.size) {
      AppButtonSize.sm => AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600, fontSize: 12),
      AppButtonSize.md => AppTextStyles.button,
      AppButtonSize.lg => AppTextStyles.button.copyWith(fontSize: 16),
    };
    return base.copyWith(color: fg);
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.xs,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.hoverBackground,
            borderRadius: AppRadius.xs,
          ),
          child: Icon(
            icon,
            size: size * 0.48,
            color: iconColor ?? AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
