import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomerCategoryNavigation extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final Color primaryColor;

  const CustomerCategoryNavigation({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.primaryColor,
  });

  IconData _getIconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('all')) return LucideIcons.layoutGrid;
    if (lower.contains('best') || lower.contains('popular') || lower.contains('★')) {
      return LucideIcons.flame;
    }
    if (lower.contains('food') || lower.contains('dining') || lower.contains('burger')) {
      return LucideIcons.utensils;
    }
    if (lower.contains('bever') || lower.contains('drink') || lower.contains('coffee')) {
      return LucideIcons.coffee;
    }
    if (lower.contains('elec')) return LucideIcons.laptop;
    if (lower.contains('vehic') || lower.contains('car')) return LucideIcons.car;
    if (lower.contains('foot') || lower.contains('shoe')) return LucideIcons.footprints;
    return LucideIcons.tag;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          final icon = _getIconForCategory(cat);

          return InkWell(
            onTap: () => onSelectCategory(cat),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
