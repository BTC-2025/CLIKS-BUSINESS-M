import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool isPassword;
  final bool showClearButton;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.isPassword = false,
    this.showClearButton = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _value = widget.controller?.text ?? '';
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.red
        : _isFocused
            ? AppColors.primaryGreen
            : AppColors.border;
    final borderWidth = _isFocused || hasError ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodySmall.copyWith(
            color: hasError
                ? AppColors.red
                : _isFocused
                    ? AppColors.primaryGreen
                    : AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: AppRadius.sm,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (hasError ? AppColors.red : AppColors.primaryGreen)
                          .withValues(alpha: 0.08),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
            onEditingComplete: widget.onEditingComplete,
            validator: widget.validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
              filled: true,
              fillColor: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: BorderSide(
                    color: hasError ? AppColors.red : AppColors.primaryGreen,
                    width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide:
                    const BorderSide(color: AppColors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide:
                    const BorderSide(color: AppColors.red, width: 2),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon,
                      size: 18,
                      color: _isFocused
                          ? AppColors.primaryGreen
                          : AppColors.secondaryText)
                  : null,
              suffixIcon: _buildSuffix(),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasError
                ? Row(
                    key: const ValueKey('error'),
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 13, color: AppColors.red),
                      const SizedBox(width: 4),
                      Text(widget.errorText!,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.red, fontSize: 12)),
                    ],
                  )
                : Text(
                    key: const ValueKey('helper'),
                    widget.helperText!,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText, fontSize: 12),
                  ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
          size: 18,
          color: AppColors.secondaryText,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.showClearButton && _value.isNotEmpty) {
      return IconButton(
        icon: const Icon(LucideIcons.x,
            size: 16, color: AppColors.secondaryText),
        onPressed: () {
          widget.controller?.clear();
          setState(() => _value = '');
          widget.onChanged?.call('');
        },
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon,
            size: 18, color: AppColors.secondaryText),
        onPressed: widget.onSuffixTap,
      );
    }
    return null;
  }
}
