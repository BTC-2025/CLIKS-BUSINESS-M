import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/customer_payment_dialog.dart';
import '../widgets/supplier_disbursement_dialog.dart';

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
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Summary (Gradient Stats & Actions)
            _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
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
      'Customer Receivables (Inward)',
      'Supplier Payables (Outward)',
      'Bank & Cash Registers',
      'Overdue Collections & Reminders',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 8,
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
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable table to avoid horizontal overflow on mobile
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: isMobile ? 800 : 1000),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.hoverBackground),
                headingRowHeight: 44,
                columns: const [
                  DataColumn(label: Text('RECEIPT ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('INVOICE LINKED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('TOTAL ORIGINAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('PAID AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('RECONCILIATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                ],
                rows: _transactions.map((tx) {
                  return DataRow(cells: [
                    DataCell(Text(tx['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Text(tx['date'], style: const TextStyle(fontSize: 12))),
                    DataCell(Text(tx['customer'], style: const TextStyle(fontSize: 12))),
                    DataCell(Text(tx['invoice'], style: const TextStyle(fontSize: 12))),
                    DataCell(Text('₹ ${tx['total']}', style: const TextStyle(fontSize: 12))),
                    DataCell(Text('₹ ${tx['paid']}', style: const TextStyle(fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                      child: Text(tx['mode'], style: const TextStyle(fontSize: 10)),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tx['status'] == 'Reconciled' ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tx['status'], style: TextStyle(fontSize: 10, color: tx['status'] == 'Reconciled' ? const Color(0xFF065F46) : const Color(0xFF92400E))),
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 14, color: AppColors.blue),
                          onPressed: () => _openTransactionSheet(tx),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                          onPressed: () => setState(() => _transactions.removeWhere((item) => item['id'] == tx['id'])),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),

          if (_transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: const Center(
                child: Text(
                  'No transaction matching records found.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ACC-DEFL',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CASH',
                  style: TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
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
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
