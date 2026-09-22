import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/navigation_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── FINANCIAL SUMMARY HERO CARD ───
          SliverToBoxAdapter(
            child: (isMacOS
                    ? _buildMacOSBusinessOverview(context, isMobile)
                    : _buildHeroSummary(context, isMobile))
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),


          // Quick Action Center Header
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: const Text(
                'Quick Action Center',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Quick Actions Wrap
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionTile(label: 'New Invoice', icon: LucideIcons.filePlus, color: AppColors.success, route: AppRoute.newInvoice),
                  _QuickActionTile(label: 'Sales Orders', icon: LucideIcons.shoppingBag, color: AppColors.blue, route: AppRoute.sales),
                  _QuickActionTile(label: 'Add Product', icon: LucideIcons.box, color: Colors.orange, route: AppRoute.products),
                  _QuickActionTile(label: 'POS Billing', icon: LucideIcons.monitor, color: Colors.teal, route: AppRoute.pos),
                  _QuickActionTile(label: 'Add Expense', icon: LucideIcons.trendingDown, color: AppColors.red, route: AppRoute.recordExpense),
                  _QuickActionTile(label: 'Attendance', icon: LucideIcons.clock, color: Colors.blueAccent, route: AppRoute.attendance),
                  _QuickActionTile(label: 'Suppliers', icon: LucideIcons.users, color: Colors.purple, route: AppRoute.suppliers),
                  _QuickActionTile(label: 'Add Customer', icon: LucideIcons.userPlus, color: Colors.pink, route: AppRoute.addCustomer),
                  _QuickActionTile(label: 'New Purchase PO', icon: LucideIcons.fileText, color: Colors.indigo, route: AppRoute.newPO),
                  _QuickActionTile(label: 'Staff Claim', icon: LucideIcons.dollarSign, color: Colors.green, route: AppRoute.lodgeStaffClaim),
                  _QuickActionTile(label: 'Onboard Staff', icon: LucideIcons.userCheck, color: Colors.lightGreen, route: AppRoute.staff),
                  _QuickActionTile(label: 'GST Records', icon: LucideIcons.layers, color: Colors.amber, route: AppRoute.gst),
                  _QuickActionTile(label: 'Marketing Hub', icon: LucideIcons.megaphone, color: Colors.deepOrange, route: AppRoute.marketing),
                  _QuickActionTile(label: 'FIN-PRO Audit Hub', icon: LucideIcons.activity, color: Colors.redAccent, route: AppRoute.auditHub),
                  _QuickActionTile(label: 'Purchase Bills', icon: LucideIcons.receipt, color: Colors.blue, route: AppRoute.purchase),
                  _QuickActionTile(label: 'New Purchase Bill', icon: LucideIcons.fileSpreadsheet, color: Colors.cyan, route: AppRoute.newPurchaseBill),
                  _QuickActionTile(label: 'Purchase Returns', icon: LucideIcons.arrowLeftRight, color: Colors.purple, route: AppRoute.returns),
                  _QuickActionTile(label: 'New Purchase Return', icon: LucideIcons.undo, color: Colors.pinkAccent, route: AppRoute.purchaseReturn),
                  _QuickActionTile(label: 'Sales Returns', icon: LucideIcons.refreshCw, color: Colors.orange, route: AppRoute.returns),
                  _QuickActionTile(label: 'Stock Management', icon: LucideIcons.database, color: Colors.blue, route: AppRoute.stock),
                  _QuickActionTile(label: 'Godown/Warehouse', icon: LucideIcons.home, color: Colors.brown, route: AppRoute.warehouse),
                  _QuickActionTile(label: 'Barcode Generator', icon: LucideIcons.barcode, color: Colors.black, route: AppRoute.barcodeGen),
                  _QuickActionTile(label: 'Split & Collect', icon: LucideIcons.split, color: Colors.deepPurple, route: AppRoute.splitCollect),
                  _QuickActionTile(label: 'Payments Ledger', icon: LucideIcons.bookOpen, color: AppColors.primaryGreen, route: AppRoute.transaction),
                  _QuickActionTile(label: 'Company Wallet', icon: LucideIcons.wallet, color: AppColors.blue, route: AppRoute.wallet),
                  _QuickActionTile(label: 'Loyalty Rewards', icon: LucideIcons.gift, color: AppColors.red, route: AppRoute.rewards),
                  _QuickActionTile(label: 'Staff Payroll', icon: LucideIcons.creditCard, color: Colors.indigoAccent, route: AppRoute.payroll),
                  _QuickActionTile(label: 'Double Entry Accounting', icon: LucideIcons.calculator, color: Colors.teal, route: AppRoute.accounting),
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          // Business Overview Charts Section
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: isMobile
                  ? Column(
                      children: [
                        _buildSalesPerformanceCard(context, isMobile),
                        const SizedBox(height: 20),
                        _buildExpenseDistributionCard(context),
                        const SizedBox(height: 20),
                        _buildTopPerformingProductsCard(context),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildSalesPerformanceCard(context, isMobile)),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: _buildExpenseDistributionCard(context)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTopPerformingProductsCard(context),
                      ],
                    ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildMacOSBusinessOverview(BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 14 : 24,
        isMobile ? 12 : 20,
        isMobile ? 14 : 24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Business Overview title & subtitle + Customise button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Business Overview',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF135029),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Monitor your enterprise performance and operations.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF135029),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.slidersHorizontal, size: 15, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Customise',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Statistics Cards
          if (isMobile)
            Column(
              children: [
                _buildMacOSStatCard(
                  icon: LucideIcons.trendingUp,
                  iconColor: const Color(0xFF135029),
                  iconBg: const Color(0xFFEAFAE3),
                  hasLiveBadge: true,
                  label: 'Total Sales Revenue',
                  amount: '₹10,21,25,50,71,294',
                ),
                const SizedBox(height: 12),
                _buildMacOSStatCard(
                  icon: LucideIcons.shoppingCart,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  hasLiveBadge: true,
                  label: 'Total Purchases',
                  amount: '₹13,84,791',
                ),
                const SizedBox(height: 12),
                _buildMacOSStatCard(
                  icon: LucideIcons.banknote,
                  iconColor: const Color(0xFFEA580C),
                  iconBg: const Color(0xFFFFF7ED),
                  hasLiveBadge: false,
                  label: 'Total Expenses',
                  amount: '₹3,14,61,64,99,53,93,93,80,00,00,00,00,00,00,00,00,00,00,000',
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildMacOSStatCard(
                    icon: LucideIcons.trendingUp,
                    iconColor: const Color(0xFF135029),
                    iconBg: const Color(0xFFEAFAE3),
                    hasLiveBadge: true,
                    label: 'Total Sales Revenue',
                    amount: '₹10,21,25,50,71,294',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMacOSStatCard(
                    icon: LucideIcons.shoppingCart,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    hasLiveBadge: true,
                    label: 'Total Purchases',
                    amount: '₹13,84,791',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMacOSStatCard(
                    icon: LucideIcons.banknote,
                    iconColor: const Color(0xFFEA580C),
                    iconBg: const Color(0xFFFFF7ED),
                    hasLiveBadge: false,
                    label: 'Total Expenses',
                    amount: '₹3,14,61,64,99,53,93,93,80,00,00,00,00,00,00,00,00,00,00,000',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMacOSStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool hasLiveBadge,
    required String label,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (hasLiveBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFAE3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: Color(0xFF135029),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 8 : 16, isMobile ? 14 : 24, 0),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUSINESS OVERVIEW',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Est. Net Profit: ₹0',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.activity, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroChip('Revenue', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Purchases', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Expenses', '₹0', isMobile),
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

  Widget _buildSalesPerformanceCard(BuildContext context, bool isMobile) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sales Performance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    SizedBox(height: 2),
                    Text('Interactive monthly sales aggregation graph.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.isMacOS ? const Color(0xFFEAFAE3) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.isMacOS
                        ? const Color(0xFF135029).withValues(alpha: 0.3)
                        : const Color(0xFF81C784),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Live Stream',
                  style: TextStyle(
                    color: AppColors.isMacOS ? const Color(0xFF135029) : const Color(0xFF2E7D32),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                // Y-Axis
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ['₹1,000', '₹750', '₹500', '₹250', '₹0']
                      .map((e) => Text(e, style: const TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)))
                      .toList(),
                ),
                const SizedBox(width: 12),
                // Chart lines & points
                Expanded(
                  child: Stack(
                    children: [
                      // Dashed horizontal guidelines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (_) => Container(height: 0.5, color: const Color(0xFFE5E7EB))),
                      ),
                      // Custom painter for trend line
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ChartLinePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // X-Axis
          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: months.map((m) => Text(m, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w600))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDistributionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 2),
          const Text('Expense allocation grouped by categories.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EAF4), style: BorderStyle.solid),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.trendingUp, size: 28, color: Color(0xFF9CA3AF)),
                SizedBox(height: 12),
                Text('No Expense Data Logged', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                SizedBox(height: 6),
                Text(
                  'Record business expenses under Purchases or Accounting to compile your category distribution breakdown.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingProductsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top Performing Products', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    SizedBox(height: 2),
                    Text('Highest volume contributors matrix.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7DD3FC), width: 0.5),
                ),
                child: const Text('VOLUME MATRIX', style: TextStyle(color: Color(0xFF0369A1), fontSize: 8.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EAF4)),
            ),
            child: const Center(
              child: Text(
                'No product sales analytics logged yet.',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }



}

// Removed DashboardStat and related card because they are now part of Hero summary

class _QuickActionTile extends ConsumerWidget {
  final String label;
  final IconData icon;
  final Color color;
  final AppRoute route;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(navigationProvider.notifier).setRoute(route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65), // Frosted glass look
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.darkText, fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final chartGreen = AppColors.isMacOS ? const Color(0xFF135029) : const Color(0xFF2E7D32);
    final paintLine = Paint()
      ..color = chartGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintDot = Paint()
      ..color = chartGreen
      ..style = PaintingStyle.fill;

    final paintDotInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simulate sales data points across 12 months (starts at 0, peaks slightly, mostly zero/low activity)
    final points = <Offset>[];
    final values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] * size.height);
      points.add(Offset(x, y));
    }

    // Draw connecting path (using a custom dotted pattern between points as shown in screenshot)
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // Draw dashed/dotted connection line between points
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 3.0;
      const spaceLength = 4.0;
      while (distance < metric.length) {
        final start = distance;
        final end = distance + dashLength;
        final segment = metric.extractPath(start, end > metric.length ? metric.length : end);
        canvas.drawPath(segment, paintLine);
        distance += dashLength + spaceLength;
      }
    }

    // Draw green rings on the chart points
    for (final point in points) {
      canvas.drawCircle(point, 5, paintLine);
      canvas.drawCircle(point, 3, paintDotInner);
      canvas.drawCircle(point, 1.5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

