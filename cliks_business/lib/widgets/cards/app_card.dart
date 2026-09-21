import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double elevation;
  final bool withAnimation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.elevation = 0,
    this.withAnimation = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) => widget.onTap != null
          ? setState(() => _hovered = true)
          : null,
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scale(_hovered && widget.onTap != null ? 1.008 : 1.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBackground,
          borderRadius: AppRadius.md,
          border: widget.border ??
              Border.all(color: AppColors.border),
          boxShadow: _hovered && widget.onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.09),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.md,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.md,
            splashColor: AppColors.primaryGreen.withValues(alpha: 0.04),
            highlightColor: Colors.transparent,
            child: Padding(
              padding:
                  widget.padding ?? const EdgeInsets.all(AppSpacing.xl),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.withAnimation) {
      return card
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.04, end: 0, curve: Curves.easeOut);
    }
    return card;
  }
}

class AppAccentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;

  const AppAccentCard({
    super.key,
    required this.child,
    this.padding,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor ?? AppColors.primaryGreen,
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      padding ?? const EdgeInsets.all(AppSpacing.xl),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
