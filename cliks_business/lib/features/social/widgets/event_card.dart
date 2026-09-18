import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _isHovered ? AppColors.primaryGreen.withValues(alpha: 0.3) : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Color Area
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF0D5BD7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(label: 'NETWORKING', color: Colors.black.withValues(alpha: 0.3)),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _Badge(label: 'Free', color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusChip(label: 'OFFLINE', color: AppColors.blue.withValues(alpha: 0.1), textColor: AppColors.blue),
                      const Spacer(),
                      Icon(LucideIcons.calendar, size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      const Text('20 May', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New Launch',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  const Text(
                    'mr b',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14, color: AppColors.border),
                      SizedBox(width: 8),
                      Text('Tiruvallur', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: AppColors.border),
                      SizedBox(width: 8),
                      Text('00:00', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Text('Seats:', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      Spacer(),
                      Text('5/100 Booked', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.05,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 6,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const _AvatarStack(),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          AppSnackbar.show(
                            context,
                            "Entry reserved successfully! Check your email for QR ticket.",
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reserve Entry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == Colors.white ? AppColors.blue : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _StatusChip({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 24,
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 16.0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: [AppColors.success, AppColors.blue, AppColors.purpleAccent, AppColors.yellow][index],
                child: Text(
                  ['D', 'P', 'F', '+2'][index],
                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
