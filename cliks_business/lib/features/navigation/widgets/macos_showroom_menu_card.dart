import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

/// Provider controlling the visibility of the Showroom / Branch Scope menu card on macOS and desktop.
final macosShowroomMenuVisibleProvider = StateProvider<bool>((ref) => false);

/// Provider holding the currently selected showroom / branch scope.
final selectedShowroomScopeProvider =
    StateProvider<String>((ref) => 'All Showrooms');

/// Floating dropdown menu card representing the Branch / Showroom Scope selector on macOS and desktop.
class MacOSShowroomMenuCard extends ConsumerWidget {
  const MacOSShowroomMenuCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedScope = ref.watch(selectedShowroomScopeProvider);
    final isAllSelected = selectedScope == 'All Showrooms';
    final isMainSelected = selectedScope == 'Main Showroom';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 285,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Scope title on left, Registered count on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BRANCH / SHOWROOM',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'SCOPE',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '1',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'REGISTERED',
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Option 1: All Showrooms (Company-wide consolidated data)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedShowroomScopeProvider.notifier).state =
                      'All Showrooms';
                  ref.read(macosShowroomMenuVisibleProvider.notifier).state =
                      false;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAllSelected
                        ? const Color(0xFFF0FDF4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAllSelected
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.store,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'All Showrooms',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Company-wide consolidated data',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAllSelected)
                        const Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Section Header: INDIVIDUAL SHOWROOMS
            const Text(
              'INDIVIDUAL SHOWROOMS',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Option 2: Main Showroom (MAIN-01 • Chennai • Main HQ)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedShowroomScopeProvider.notifier).state =
                      'Main Showroom';
                  ref.read(macosShowroomMenuVisibleProvider.notifier).state =
                      false;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMainSelected
                        ? const Color(0xFFF0FDF4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMainSelected
                          ? const Color(0xFF86EFAC)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.store,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Main Showroom',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'MAIN-01 • Chennai • Main HQ',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMainSelected)
                        const Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Action: + Manage Showrooms & Stock
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  ref.read(macosShowroomMenuVisibleProvider.notifier).state =
                      false;
                  ref
                      .read(navigationProvider.notifier)
                      .setRoute(AppRoute.warehouse);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.plus,
                          size: 13,
                          color: Color(0xFF334155),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Manage Showrooms & Stock',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
