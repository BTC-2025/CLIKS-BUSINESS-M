import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

/// Data model for a chip displayed inside [MacOsSoftUiBentoHero].
class MacOsBentoHeroChip {
  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const MacOsBentoHeroChip({
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.onTap,
  });
}

/// A macOS-specific Soft UI Bento Hero Banner designed for desktop apps.
/// Features clean white surfaces, hairline borders, soft dual shadows,
/// large statistical typography, live status badges, and modular metric capsules.
class MacOsSoftUiBentoHero extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? subtitle;
  final String badgeText;
  final IconData? badgeIcon;
  final List<MacOsBentoHeroChip> chips;
  final Widget? trailingAction;
  final bool isMobile;
  final EdgeInsetsGeometry? margin;

  const MacOsSoftUiBentoHero({
    super.key,
    required this.title,
    required this.mainValue,
    this.subtitle,
    this.badgeText = 'LIVE',
    this.badgeIcon = LucideIcons.trendingUp,
    required this.chips,
    this.trailingAction,
    this.isMobile = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.fromLTRB(
            isMobile ? 14 : 24,
            isMobile ? 8 : 16,
            isMobile ? 14 : 24,
            0,
          ),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x03166534),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Title, Main Stat, and Live Badge / Trailing Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mainValue,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 26 : 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -1.0,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF2E4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badgeIcon != null) ...[
                          Icon(
                            badgeIcon,
                            size: 13,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailingAction != null) ...[
                    const SizedBox(width: 10),
                    trailingAction!,
                  ],
                ],
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 18),
            // Chips row: Bento statistical capsules
            LayoutBuilder(
              builder: (context, constraints) {
                if (isMobile) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips.map((c) => _buildMobileChip(c)).toList(),
                  );
                }
                return Row(
                  children: chips
                      .map((c) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildDesktopChip(c),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopChip(MacOsBentoHeroChip chip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (chip.icon != null) ...[
                Icon(
                  chip.icon,
                  size: 12,
                  color: chip.accentColor ?? const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  chip.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              chip.value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileChip(MacOsBentoHeroChip chip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chip.label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            chip.value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
