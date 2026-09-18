import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PricingCard extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final String originalPrice;
  final String saveAmount;
  final IconData icon;
  final bool isPopular;

  const PricingCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.saveAmount,
    required this.icon,
    this.isPopular = false,
  });

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? AppColors.primaryGreen : AppColors.border,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: AppColors.success, size: 24),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  '₹${widget.originalPrice}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.secondaryText,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save ₹${widget.saveAmount}',
                    style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${widget.price}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                const Text(
                  ' / year',
                  style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
                ),
              ],
            ),
            Text(
              '(Equivalent to ₹${(int.parse(widget.price.replaceAll(',', '')) / 12).round()} per month)',
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Upgrade Plan',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
