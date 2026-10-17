import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'bento_card.dart';

/// Modern SaaS Bento Chart Card.
/// Displays an interactive, minimal curved line graph with subtle gradient fill,
/// clean axes, status chips, and period selectors.
class BentoChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metricLabel;
  final String metricValue;
  final String? changePercentage;
  final List<String> xLabels;
  final List<double> values;
  final double maxY;
  final Color lineColor;
  final Color gradientStartColor;
  final Widget? trailing;

  const BentoChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.metricLabel,
    required this.metricValue,
    this.changePercentage,
    required this.xLabels,
    required this.values,
    this.maxY = 1000.0,
    this.lineColor = AppColors.primaryGreen,
    this.gradientStartColor = const Color(0xFFDCF2E4),
    this.trailing,
  });

  @override
  State<BentoChartCard> createState() => _BentoChartCardState();
}

class _BentoChartCardState extends State<BentoChartCard> {
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['12M', '6M', '30D', '7D'];
  int? _hoveredPointIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700 && defaultTargetPlatform != TargetPlatform.macOS;

    return BentoCard(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: LucideIcons.lineChart,
      iconColor: widget.lineColor,
      iconBackgroundColor: widget.lineColor.withValues(alpha: 0.1),
      padding: EdgeInsets.all(isCompact ? 12 : AppSpacing.xl),
      trailing: widget.trailing ?? _buildPeriodSelector(isCompact),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Highlight Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final badge = widget.changePercentage != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF2E4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.trendingUp,
                              size: 11, color: AppColors.primaryGreen),
                          const SizedBox(width: 3),
                          Text(
                            widget.changePercentage!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.metricLabel.isNotEmpty) ...[
                      Text(
                        widget.metricLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.metricValue,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          badge,
                        ],
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.metricValue,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    badge,
                  ],
                  const Spacer(),
                  Text(
                    widget.metricLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: isCompact ? 12 : 20),

          // Chart Canvas
          SizedBox(
            height: isCompact ? 140 : 180,
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    '₹1,000',
                    '₹750',
                    '₹500',
                    '₹250',
                    '₹0',
                  ]
                      .map(
                        (val) => Text(
                          val,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: 12),

                // Canvas Area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Clean horizontal gridlines
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                              (_) => Container(
                                height: 1,
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                          ),

                          // Interactive Chart Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BentoChartPainter(
                                values: widget.values,
                                maxY: widget.maxY,
                                lineColor: widget.lineColor,
                                gradientStart: widget.gradientStartColor,
                                hoveredIndex: _hoveredPointIndex,
                              ),
                            ),
                          ),

                          // Mouse Hover Detector along X-axis
                          Positioned.fill(
                            child: MouseRegion(
                              onHover: (event) {
                                final stepX = constraints.maxWidth /
                                    (widget.values.length - 1);
                                final index = (event.localPosition.dx / stepX)
                                    .round()
                                    .clamp(0, widget.values.length - 1);
                                if (_hoveredPointIndex != index) {
                                  setState(() => _hoveredPointIndex = index);
                                }
                              },
                              onExit: (_) {
                                if (_hoveredPointIndex != null) {
                                  setState(() => _hoveredPointIndex = null);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // X-Axis Labels
          Padding(
            padding: EdgeInsets.only(left: isCompact ? 36 : 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.xLabels
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      final shouldHide = isCompact &&
                          widget.xLabels.length > 6 &&
                          entry.key % 2 != 0;
                      return Text(
                        shouldHide ? '' : entry.value,
                        style: GoogleFonts.inter(
                          fontSize: isCompact ? 9.5 : 10.5,
                          fontWeight: _hoveredPointIndex == entry.key
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _hoveredPointIndex == entry.key
                              ? AppColors.primaryGreen
                              : const Color(0xFF6B7280),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector([bool isCompact = false]) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 2.0 : 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriodIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 6 : 8,
                vertical: isCompact ? 2.5 : 4,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _periods[index],
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 10 : 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BentoChartPainter extends CustomPainter {
  final List<double> values;
  final double maxY;
  final Color lineColor;
  final Color gradientStart;
  final int? hoveredIndex;

  _BentoChartPainter({
    required this.values,
    required this.maxY,
    required this.lineColor,
    required this.gradientStart,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final stepX = size.width / (values.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedY = (values[i] / (maxY <= 0 ? 1 : maxY)).clamp(0.0, 1.0);
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // 1. Draw smooth bezier curve path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // 2. Draw soft gradient area under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStart.withValues(alpha: 0.4),
          gradientStart.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 3. Draw the line stroke
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 4. Draw data points
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 5.5 : 3.5;

      if (isHovered) {
        // Subtle vertical indicator line on hover
        final hoverLinePaint = Paint()
          ..color = lineColor.withValues(alpha: 0.25)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(points[i].dx, 0),
          Offset(points[i].dx, size.height),
          hoverLinePaint,
        );
      }

      canvas.drawCircle(points[i], radius, dotPaint);
      canvas.drawCircle(points[i], radius, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BentoChartPainter oldDelegate) =>
      values != oldDelegate.values ||
      hoveredIndex != oldDelegate.hoveredIndex ||
      lineColor != oldDelegate.lineColor;
}
