import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/customer_payment_dialog.dart';
import '../widgets/supplier_disbursement_dialog.dart';
import '../../../widgets/bento/bento.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int _activeTab = 0; // 0: Receivables, 1: Payables, 2: Registers, 3: Overdue

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-2026-001',
      'date': '12-08-2026',
      'customer': 'Acme Corp',
      'invoice': 'INV-101',
      'total': 15000.0,
      'paid': 15000.0,
      'mode': 'UPI',
      'status': 'Reconciled',
    },
    {
      'id': 'TXN-2026-002',
      'date': '12-08-2026',
      'customer': 'Zenith Retail',
      'invoice': 'INV-102',
      'total': 8500.0,
      'paid': 4000.0,
      'mode': 'Bank Transfer',
      'status': 'Pending',
    },
  ];

  void _openTransactionSheet(Map<String, dynamic>? item, {bool isSupplier = false}) {
    final isOutward = item != null ? (item['type'] == 'Outward') : isSupplier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (isOutward) {
          return RecordSupplierDisbursementDialog(
            transaction: item,
            onSave: (data) {
              setState(() {
                if (item != null) {
                  item.addAll(data);
                } else {
                  _transactions.insert(0, data);
                }
              });
            },
          );
        } else {
          return RecordCustomerPaymentDialog(
            transaction: item,
            onSave: (data) {
              setState(() {
                if (item != null) {
                  item.addAll(data);
                } else {
                  _transactions.insert(0, data);
                }
              });
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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

            // Segment Tabs Row
            _buildTabsRow(isMobile).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            SizedBox(height: isMobile ? 14 : 20),

            // Records Table Card
            _buildRecordsCard(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS SOFT UI BENTO HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMacOsBentoHero(BuildContext context, bool isMobile) {
    final double combinedBalance = _transactions.fold(0.0, (sum, item) => sum + (item['total'] as double));
    final double receivables = _transactions.where((t) => t['status'] != 'Reconciled').fold(0.0, (sum, item) => sum + ((item['total'] as double) - (item['paid'] as double)));
    final double dailyColl = _transactions.fold(0.0, (sum, item) => sum + (item['paid'] as double));
    final String efficiency = combinedBalance > 0 ? ((dailyColl / combinedBalance) * 100).toStringAsFixed(1) : '0.0';

    final String combinedFmt = combinedBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final String receivablesFmt = receivables.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final String dailyCollFmt = dailyColl.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return MacOsSoftUiBentoHero(
      margin: EdgeInsets.zero,
      title: 'Settlements & Cashflow Ledger',
      mainValue: '₹ $combinedFmt',
      subtitle: 'Net merchant collections, vendor disbursements & automated clearing cycles',
      badgeText: 'SETTLEMENTS LIVE',
      badgeIcon: LucideIcons.arrowLeftRight,
      isMobile: isMobile,
      chips: [
        MacOsBentoHeroChip(
          label: 'Pending Receivables',
          value: '₹ $receivablesFmt',
          icon: LucideIcons.arrowDownLeft,
          accentColor: const Color(0xFF166534),
        ),
        MacOsBentoHeroChip(
          label: 'Total Collected',
          value: '₹ $dailyCollFmt',
          icon: LucideIcons.badgeCheck,
          accentColor: const Color(0xFF2563EB),
        ),
        MacOsBentoHeroChip(
          label: 'Recovery Ratio',
          value: '$efficiency%',
          icon: LucideIcons.percent,
          accentColor: const Color(0xFFD97706),
        ),
      ],
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => _openTransactionSheet(null, isSupplier: true),
            icon: const Icon(LucideIcons.arrowUpRight, size: 13),
            label: const Text('Pay Supplier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              side: const BorderSide(color: Color(0xFFBBF7D0)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openTransactionSheet(null, isSupplier: false),
            icon: const Icon(LucideIcons.arrowDownLeft, size: 13),
            label: const Text('Receive Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final paySupplierBtn = OutlinedButton.icon(
      onPressed: () => _openTransactionSheet(null, isSupplier: true),
      icon: const Icon(LucideIcons.arrowUpRight, size: 14),
      label: const Text('Pay Supplier', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final receivePaymentBtn = ElevatedButton.icon(
      onPressed: () => _openTransactionSheet(null, isSupplier: false),
      icon: const Icon(LucideIcons.arrowDownLeft, size: 14),
      label: const Text('Receive Payment', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.stylishDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    final double combinedBalance = _transactions.fold(0.0, (sum, item) => sum + (item['total'] as double));
    final double receivables = _transactions.where((t) => t['status'] != 'Reconciled').fold(0.0, (sum, item) => sum + ((item['total'] as double) - (item['paid'] as double)));
    final double dailyColl = _transactions.fold(0.0, (sum, item) => sum + (item['paid'] as double));
    final String efficiency = combinedBalance > 0 ? ((dailyColl / combinedBalance) * 100).toStringAsFixed(1) : '0.0';

    final String combinedFmt = combinedBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final String receivablesFmt = receivables.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final String dailyCollFmt = dailyColl.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    final actionsWidget = isMobile
        ? Row(
            children: [
              Expanded(child: paySupplierBtn),
              const SizedBox(width: 8),
              Expanded(child: receivePaymentBtn),
            ],
          )
        : Row(
            children: [
              paySupplierBtn,
              const SizedBox(width: 8),
              receivePaymentBtn,
            ],
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
                      'COMBINED BALANCES',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ $combinedFmt',
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
              if (!isMobile) actionsWidget,
            ],
          ),
          if (isMobile) const SizedBox(height: 16),
          if (isMobile) actionsWidget,
          const SizedBox(height: 16),
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Receivables', '₹ $receivablesFmt', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Daily Coll.', '₹ $dailyCollFmt', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Efficiency', '$efficiency%', isMobile),
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

  Widget _buildTabsRow(bool isMobile) {
    final tabs = [
      {'title': 'Customer Receivables (Inward)', 'icon': LucideIcons.arrowDownLeft},
      {'title': 'Supplier Payables (Outward)', 'icon': LucideIcons.arrowUpRight},
      {'title': 'Bank & Cash Registers', 'icon': LucideIcons.landmark},
      {'title': 'Overdue Collections & Reminders', 'icon': LucideIcons.alertCircle},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTab == index;
          final tabItem = tabs[index];
          final icon = tabItem['icon'] as IconData;
          final title = tabItem['title'] as String;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF166534) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF166534).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecordsCard(bool isMobile) {
    if (_activeTab == 2) {
      return _buildBankRegistersView(isMobile);
    }

    if (isMobile) {
      return _buildMobileTransactionsList();
    }

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
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = math.max(constraints.maxWidth, 980.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // RECEIPT ID
                      1: FlexColumnWidth(1.2), // DATE
                      2: FlexColumnWidth(2.0), // CUSTOMER
                      3: FlexColumnWidth(1.4), // INVOICE LINKED
                      4: FlexColumnWidth(1.5), // TOTAL ORIGINAL
                      5: FlexColumnWidth(1.5), // PAID AMOUNT
                      6: FlexColumnWidth(1.5), // MODE
                      7: FlexColumnWidth(1.6), // RECONCILIATION
                      8: FlexColumnWidth(1.4), // ACTIONS
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('RECEIPT ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('DATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('CUSTOMER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('INVOICE LINKED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('TOTAL ORIGINAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('PAID AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('MODE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('RECONCILIATION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('ACTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                        ],
                      ),
                      ..._transactions.map((tx) {
                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx['date'], style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx['customer'], style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx['invoice'], style: const TextStyle(fontSize: 13, color: AppColors.secondaryText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('₹ ${tx['total']}', style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('₹ ${tx['paid']}', style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w600))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                  child: Text(tx['mode'], style: const TextStyle(fontSize: 12, color: AppColors.darkText), overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tx['status'] == 'Reconciled' ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(tx['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: tx['status'] == 'Reconciled' ? const Color(0xFF065F46) : const Color(0xFF92400E)), overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.pencil, size: 15, color: AppColors.blue),
                                      onPressed: () => _openTransactionSheet(tx),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.red),
                                      onPressed: () => setState(() => _transactions.removeWhere((item) => item['id'] == tx['id'])),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),

          if (_transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 64),
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

  Widget _buildMobileTransactionsList() {
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.receipt, color: Color(0xFF94A3B8), size: 24),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Transaction Records Found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Transactions recorded will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _transactions.map((tx) {
        final mode = tx['mode'] as String? ?? 'UPI';
        final isUPI = mode.toLowerCase().contains('upi');
        final isBank = mode.toLowerCase().contains('bank');
        final isCash = mode.toLowerCase().contains('cash');
        final isReconciled = tx['status'] == 'Reconciled';

        final iconColor = isUPI
            ? const Color(0xFF6366F1)
            : isBank
                ? const Color(0xFF2563EB)
                : isCash
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706);
        final iconBg = iconColor.withValues(alpha: 0.12);
        final modeIcon = isUPI
            ? LucideIcons.smartphone
            : isBank
                ? LucideIcons.landmark
                : isCash
                    ? LucideIcons.banknote
                    : LucideIcons.creditCard;

        final totalVal = (tx['total'] as num).toDouble();
        final paidVal = (tx['paid'] as num).toDouble();
        final totalStr = totalVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
        final paidStr = paidVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Customer & Subtitle (Mode/Date) + Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(modeIcon, size: 18, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['customer'] as String? ?? 'Unknown Customer',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx['mode'] ?? 'Payment'} • ${tx['date'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹ $paidStr',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF166534),
                        ),
                      ),
                      if (totalVal != paidVal) ...[
                        const SizedBox(height: 1),
                        Text(
                          'of ₹ $totalStr',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Bottom Row: Status Badge & Invoice Chip + Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isReconciled ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReconciled ? LucideIcons.checkCheck : LucideIcons.clock,
                                size: 11,
                                color: isReconciled ? const Color(0xFF166534) : const Color(0xFF92400E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tx['status'] as String? ?? 'Pending',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isReconciled ? const Color(0xFF166534) : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${tx['invoice'] ?? tx['id']}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _openTransactionSheet(tx),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(LucideIcons.pencil, size: 14, color: Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => setState(() => _transactions.removeWhere((item) => item['id'] == tx['id'])),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBankRegistersView(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _buildDefaultCashAccountCard(),
              const SizedBox(height: 16),
              _buildInternalTransferCard(),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDefaultCashAccountCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildInternalTransferCard()),
            ],
          );
  }

  Widget _buildDefaultCashAccountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.hoverBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACC-DEFL',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CASH',
                  style: TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Default Cash Account',
            style: TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Account No: ',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance:',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              Text(
                '₹ 0',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalTransferCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.arrowUpRight, color: AppColors.primaryGreen, size: 32),
            const SizedBox(height: 16),
            const Text(
              'Internal Transfer Funds',
              style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Move money between Cash-in-Hand and Bank accounts',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
