import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/add_money_dialog.dart';
import '../../../widgets/bento/bento.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMoneyDialog(),
                  );
                },
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Summary (Gradient Stats & Actions)
            isMacOS
                ? _buildMacOsBentoHero(context, isMobile)
                : _buildHeroSummary(context, isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0),
            SizedBox(height: isMobile ? 14 : 28),

            // Wallet History Table Card
            _buildHistoryCard(isMobile).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS SOFT UI BENTO HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMacOsBentoHero(BuildContext context, bool isMobile) {
    return MacOsSoftUiBentoHero(
      margin: EdgeInsets.zero,
      title: 'Digital Treasury & Cloud Wallet',
      mainValue: '₹ 0',
      subtitle: 'Encrypted reserve balance, escrow deposits & instant payout liquidity',
      badgeText: 'TREASURY ACTIVE',
      badgeIcon: LucideIcons.wallet,
      isMobile: isMobile,
      chips: [
        MacOsBentoHeroChip(
          label: 'Total Deposits',
          value: '₹0',
          icon: LucideIcons.arrowDownLeft,
          accentColor: const Color(0xFF166534),
        ),
        MacOsBentoHeroChip(
          label: 'Withdrawals',
          value: '₹0',
          icon: LucideIcons.arrowUpRight,
          accentColor: const Color(0xFF2563EB),
        ),
        MacOsBentoHeroChip(
          label: 'Pending Escrow',
          value: '₹0',
          icon: LucideIcons.clock,
          accentColor: const Color(0xFFD97706),
        ),
      ],
      trailingAction: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddMoneyDialog(),
          );
        },
        icon: const Icon(LucideIcons.plus, size: 13),
        label: const Text('Add Money', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final addMoneyButton = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AddMoneyDialog(),
        );
      },
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text('Add Money', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.stylishDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STORED BALANCE',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ 0',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) addMoneyButton,
            ],
          ),
          const SizedBox(height: 16),
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Deposits', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Withdrawals', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Pending', '₹0', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Wallet History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                if (!isMobile) const Spacer(),
                Container(
                  width: isMobile ? double.infinity : 220,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.tableBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.search, color: AppColors.secondaryText, size: 14),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search descriptions or IDs...',
                            hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.tableBorder),

          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = math.max(constraints.maxWidth, 800.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // TRANSACTION ID
                      1: FlexColumnWidth(1.6), // DATE & TIME
                      2: FlexColumnWidth(2.6), // DESCRIPTION
                      3: FlexColumnWidth(1.4), // DIRECTION
                      4: FlexColumnWidth(1.4), // AMOUNT
                    },
                    children: const [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        children: [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Text('TRANSACTION ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Text('DATE & TIME', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Text('DESCRIPTION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Text('DIRECTION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Text('AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // No records indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Center(
              child: Text(
                'No transaction matching records found.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
