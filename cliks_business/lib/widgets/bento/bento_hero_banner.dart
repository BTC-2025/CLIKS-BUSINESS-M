import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Premium Bento Hero Banner designed for the dashboard top area.
/// Provides enterprise financial overview with live indicators,
/// sleek glass chips, and high-contrast typography.
class BentoHeroBanner extends StatelessWidget {
  final String title;
  final String netProfitText;
  final List<BentoHeroChipData> chips;
  final VoidCallback? onCustomiseTap;
  final bool isMobile;

  const BentoHeroBanner({
    super.key,
    this.title = 'BUSINESS OVERVIEW',
    required this.netProfitText,
    required this.chips,
    this.onCustomiseTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF166534), // Forest Green
            Color(0xFF14532D), // Deep Emerald Green
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 10.5 : 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1.1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80), // Bright green dot
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4ADE80),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      netProfitText,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 20 : 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCustomiseTap != null)
                InkWell(
                  onTap: onCustomiseTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 9 : 14, vertical: isMobile ? 5 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.slidersHorizontal,
                            size: isMobile ? 12 : 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Customise',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 18),

          // Chips Row / Grid
          if (isMobile)
            Column(
              children: [
                Row(
                  children: [
                    if (chips.isNotEmpty)
                      Expanded(child: _buildChip(chips[0], isMobile)),
                    if (chips.length > 1) ...[
                      const SizedBox(width: 8),
                      Expanded(child: _buildChip(chips[1], isMobile)),
                    ],
                  ],
                ),
                if (chips.length > 2) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildChip(chips[2], isMobile)),
                      if (chips.length > 3) ...[
                        const SizedBox(width: 8),
                        Expanded(child: _buildChip(chips[3], isMobile)),
                      ],
                    ],
                  ),
                ],
              ],
            )
          else
            Row(
              children: chips.asMap().entries.map((entry) {
                final index = entry.key;
                final chip = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == chips.length - 1 ? 0 : 12,
                    ),
                    child: _buildChip(chip, isMobile),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(BentoHeroChipData chip, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 9 : 14,
        vertical: isMobile ? 7 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (chip.icon != null) ...[
                Icon(chip.icon,
                    size: isMobile ? 11.5 : 13, color: Colors.white.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  chip.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 9.5 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              chip.value,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 13.5 : 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BentoHeroChipData {
  final String label;
  final String value;
  final IconData? icon;

  const BentoHeroChipData({
    required this.label,
    required this.value,
    this.icon,
  });
}
