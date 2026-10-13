import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
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
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);

    final card = MouseRegion(
      onEnter: (_) => widget.onTap != null || isDesktop
          ? setState(() => _hovered = true)
          : null,
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hovered && widget.onTap != null ? -2.0 : 0.0,
            0.0,
          ),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: widget.border ??
              Border.all(
                color: _hovered && widget.onTap != null
                    ? AppColors.primaryGreen.withValues(alpha: 0.35)
                    : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
          boxShadow: _hovered && widget.onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primaryGreen.withValues(alpha: 0.05),
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

    if (widget.withAnimation && !isDesktop) {
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
