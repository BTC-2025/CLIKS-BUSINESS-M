import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_order_model.dart';

class CustomerOrderTimerWidget extends StatefulWidget {
  final CustomerOrder order;
  final Color primaryColor;

  const CustomerOrderTimerWidget({
    super.key,
    required this.order,
    required this.primaryColor,
  });

  @override
  State<CustomerOrderTimerWidget> createState() =>
      _CustomerOrderTimerWidgetState();
}

class _CustomerOrderTimerWidgetState extends State<CustomerOrderTimerWidget> {
  late Timer _timer;
  late Duration _remaining;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.order.estimatedPrepMinutes * 60;
    final elapsed = DateTime.now().difference(widget.order.createdAt).inSeconds;
    final remainingSecs = (_totalSeconds - elapsed).clamp(0, _totalSeconds);
    _remaining = Duration(seconds: remainingSecs);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nowElapsed = DateTime.now().difference(widget.order.createdAt).inSeconds;
      final remSecs = (_totalSeconds - nowElapsed);

      if (remSecs <= 0) {
        setState(() {
          _remaining = Duration.zero;
        });
        timer.cancel();
      } else {
        setState(() {
          _remaining = Duration(seconds: remSecs);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 1.0;
    final elapsedSeconds = _totalSeconds - _remaining.inSeconds;
    return (elapsedSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _remaining == Duration.zero;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Preparation status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFF0FDF4)
                  : widget.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone ? LucideIcons.bellRing : LucideIcons.clock,
                  size: 15,
                  color: isDone ? const Color(0xFF16A34A) : widget.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isDone ? 'READY FOR PICKUP' : 'ESTIMATED PREPARATION TIME',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDone ? const Color(0xFF16A34A) : widget.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Big Timer Display
          Text(
            isDone ? 'READY!' : _formatDuration(_remaining),
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: isDone ? const Color(0xFF16A34A) : const Color(0xFF111827),
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            isDone
                ? 'Your order is packed and ready at the service counter!'
                : 'Freshly preparing your items in our kitchen...',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? const Color(0xFF16A34A) : widget.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
