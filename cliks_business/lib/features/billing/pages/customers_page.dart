import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/customer_registration_dialog.dart';

// ═══════════════════════════════════════════════════════════════════
// CUSTOMER DATA MODEL
// ═══════════════════════════════════════════════════════════════════
class _CustomerRecord {
  final String id;
  final String name;
  final String? code;
  final String statusText;
  final Color statusBg;
  final Color statusFg;
  final String business;
  final String email;
  final String? phone;
  final String? connectionRequest;
  final String gstin;
  final double creditLimit;
  final double outstanding;
  final int loyaltyPts;
  final Color avatarBg;
  final Color avatarFg;
  final String avatarLetter;

  _CustomerRecord({
    required this.id,
    required this.name,
    this.code,
    required this.statusText,
    required this.statusBg,
    required this.statusFg,
    required this.business,
    required this.email,
    this.phone,
    this.connectionRequest,
    required this.gstin,
    required this.creditLimit,
    required this.outstanding,
    required this.loyaltyPts,
    required this.avatarBg,
    required this.avatarFg,
    required this.avatarLetter,
  });
}

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  int _activeTab = 0; // 0: Customers List, 1: Aging & Collection Reports, 2: Points Rules
  final TextEditingController _searchController = TextEditingController();
  String _selectedBalanceFilter = 'All Balances';

  // In-memory customer state matching Image 2
  late List<_CustomerRecord> _customers;

  @override
  void initState() {
    super.initState();
    _customers = [
      _CustomerRecord(
        id: '1',
        name: 'vincent1182003',
        code: null,
        statusText: 'Connected',
        statusBg: const Color(0xFFDCFCE7),
        statusFg: const Color(0xFF15803D),
        business: 'vincent1182003',
        email: 'vincent1182003@bnxmail.com',
        phone: null,
        connectionRequest: 'Supplier Connection Request (2026-08-29)',
        gstin: 'Unregistered',
        creditLimit: 0,
        outstanding: 0,
        loyaltyPts: 0,
        avatarBg: const Color(0xFFDCFCE7),
        avatarFg: const Color(0xFF15803D),
        avatarLetter: 'v',
      ),
      _CustomerRecord(
        id: '2',
        name: 'NIIT400',
        code: 'CUST-9007',
        statusText: 'Pending Request',
        statusBg: const Color(0xFFFEF3C7),
        statusFg: const Color(0xFFD97706),
        business: 'Personal',
        email: 'aruntest@bnxmail.com',
        phone: '9456161498',
        connectionRequest: null,
        gstin: 'KLEWDNWKEDNKJWE',
        creditLimit: 50000,
        outstanding: 0,
        loyaltyPts: 0,
        avatarBg: const Color(0xFFFEE2E2),
        avatarFg: const Color(0xFFDC2626),
        avatarLetter: 'N',
      ),
      _CustomerRecord(
        id: '3',
        name: 'sanjay123',
        code: null,
        statusText: 'Connected',
        statusBg: const Color(0xFFDCFCE7),
        statusFg: const Color(0xFF15803D),
        business: 'sanjay123',
        email: 'sanjay123@bnxmail.com',
        phone: null,
        connectionRequest: 'Supplier Connection Request (2026-08-19)',
        gstin: 'Unregistered',
        creditLimit: 0,
        outstanding: 0,
        loyaltyPts: 0,
        avatarBg: const Color(0xFFF3E8FF),
        avatarFg: const Color(0xFF7C3AED),
        avatarLetter: 's',
      ),
      _CustomerRecord(
        id: '4',
        name: 'Varshini',
        code: 'CUST-9770',
        statusText: 'Pending Request',
        statusBg: const Color(0xFFFEF3C7),
        statusFg: const Color(0xFFD97706),
        business: 'Personal',
        email: 'chandran123@bnxmail.com',
        phone: '6374943436',
        connectionRequest: null,
        gstin: '487SDCNDSCJHBD5',
        creditLimit: 0,
        outstanding: 0,
        loyaltyPts: 0,
        avatarBg: const Color(0xFFFEF3C7),
        avatarFg: const Color(0xFFD97706),
        avatarLetter: 'V',
      ),
      _CustomerRecord(
        id: '5',
        name: 'Ravi kumar',
        code: 'CUST-9404',
        statusText: 'Connected',
        statusBg: const Color(0xFFDCFCE7),
        statusFg: const Color(0xFF15803D),
        business: 'groceries',
        email: 'santhoshhhhhh@bnxmail.com',
        phone: '9587456522',
        connectionRequest: 'Supplier Connection Request (2026-08-20)',
        gstin: 'JGVHGVHVJHVJHVJ',
        creditLimit: 50000,
        outstanding: 0,
        loyaltyPts: 0,
        avatarBg: const Color(0xFFE0E7FF),
        avatarFg: const Color(0xFF4338CA),
        avatarLetter: 'R',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MODALS & ACTIONS
  // ═══════════════════════════════════════════════════════════════════
  void _openAddCustomerModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CustomerRegistrationDialog(
          onClose: () => Navigator.pop(ctx),
          onCustomerRegistered: (formData) {
            setState(() {
              final name = formData.name.trim();
              final letter = name.isNotEmpty ? name[0].toUpperCase() : 'C';
              _customers.insert(
                0,
                _CustomerRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  code: 'CUST-2406',
                  statusText: formData.accountStatus == 'Active'
                      ? 'Connected'
                      : formData.accountStatus,
                  statusBg: const Color(0xFFDCFCE7),
                  statusFg: const Color(0xFF15803D),
                  business: formData.shopName.isNotEmpty
                      ? formData.shopName
                      : 'Wholesale',
                  email: formData.email.isNotEmpty
                      ? formData.email
                      : '$name@bnxmail.com',
                  phone: formData.phone.isNotEmpty ? formData.phone : null,
                  connectionRequest: null,
                  gstin: formData.gstin.isNotEmpty
                      ? formData.gstin
                      : 'Unregistered',
                  creditLimit: formData.creditLimit,
                  outstanding: formData.openingBalance,
                  loyaltyPts: 0,
                  avatarBg: const Color(0xFFF3E8FF),
                  avatarFg: const Color(0xFF7C3AED),
                  avatarLetter: letter,
                ),
              );
            });
            AppSnackbar.show(context, 'Customer registered successfully',
                type: SnackType.success);
          },
        );
      },
    );
  }

  void _openBulkImportModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.fileSpreadsheet, color: Color(0xFF334155), size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Bulk Import Customers',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.uploadCloud, size: 36, color: Color(0xFF166534)),
                      const SizedBox(height: 10),
                      const Text(
                        'Upload CSV or Excel Spreadsheet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Columns supported: Name, Phone, Email, GSTIN, Credit Limit',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          AppSnackbar.show(context, 'Imported 10 demo customer contacts successfully.', type: SnackType.success);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Browse Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        AppSnackbar.show(context, 'Downloading customer_sample_import.csv template.', type: SnackType.info);
                      },
                      icon: const Icon(LucideIcons.download, size: 14, color: Color(0xFF166534)),
                      label: const Text('Download Sample CSV', style: TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPointsRulesModal() {
    final amountController = TextEditingController(text: '10000');
    int calcAmount = 10000;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final points = (calcAmount / 100).floor();
            final cashback = (points * 0.10).toStringAsFixed(2);

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 580,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Header (Image 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.calculator, color: Color(0xFF166534), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Points Calculation & Distribution Rules',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Understand your points-to-money ratio & cashback conversion',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Ratio Cards (Responsive on Mobile)
                    LayoutBuilder(
                      builder: (context, cardConstraints) {
                        final isMobileCard = cardConstraints.maxWidth < 450;
                        final card1 = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'EARNING RATIO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '₹100 = 1 Point',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Earn 1% reward points on every purchase total.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        );

                        final card2 = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MONEY VALUE RATIO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '10 Pts = ₹1.00',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '1 Point is equivalent to ₹0.10 in cash value.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isMobileCard) {
                          return Column(
                            children: [
                              card1,
                              const SizedBox(height: 12),
                              card2,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: card1),
                            const SizedBox(width: 14),
                            Expanded(child: card2),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Interactive Converter (Image 4)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.percent, size: 15, color: Color(0xFF166534)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Interactive Points-to-Money Converter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, convConstraints) {
                              final isMobileConv = convConstraints.maxWidth < 420;

                              final purchaseInput = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Purchase Amount (₹)',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: TextField(
                                      controller: amountController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                      onChanged: (val) {
                                        setModalState(() {
                                          calcAmount = int.tryParse(val.trim()) ?? 0;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              final pointsDisplay = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Points Earned & Cashback',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 38,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '+$points pts (₹$cashback)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              if (isMobileConv) {
                                return Column(
                                  children: [
                                    purchaseInput,
                                    const SizedBox(height: 8),
                                    const Icon(LucideIcons.arrowDown, size: 16, color: Color(0xFF166534)),
                                    const SizedBox(height: 8),
                                    pointsDisplay,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(flex: 4, child: purchaseInput),
                                  const SizedBox(width: 10),
                                  const Icon(LucideIcons.arrowRight, size: 16, color: Color(0xFF166534)),
                                  const SizedBox(width: 10),
                                  Expanded(flex: 5, child: pointsDisplay),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Got It Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        ),
                        child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
      },
    );
  }

  void _openLedgerModal(_CustomerRecord customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: EdgeInsets.all(MediaQuery.of(ctx).size.width < 550 ? 14 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: customer.avatarBg,
                            child: Text(
                              customer.avatarLetter,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: customer.avatarFg),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${customer.name} - Ledger Statement',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'GSTIN: ${customer.gstin} • Credit Limit: ₹${customer.creditLimit.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('NET RECEIVABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            SizedBox(height: 4),
                            Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('ACCOUNT STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                            SizedBox(height: 4),
                            Text('Fully Reconciled', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Recent Ledger Entries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                if (Theme.of(ctx).platform != TargetPlatform.macOS && MediaQuery.of(ctx).size.width < 550)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                              child: Text(
                                '2026-08-20',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Opening Balance',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                              child: Text(
                                'Debit: ₹0',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Credit: ₹0',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Bal: ₹0',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(ctx).size.width < 550 ? 460 : 0,
                        ),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.4),
                            1: FlexColumnWidth(2.0),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.2),
                          },
                          children: const [
                            TableRow(
                              decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                              children: [
                                Padding(padding: EdgeInsets.all(8), child: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                Padding(padding: EdgeInsets.all(8), child: Text('VOUCHER / REF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                Padding(padding: EdgeInsets.all(8), child: Text('DEBIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                Padding(padding: EdgeInsets.all(8), child: Text('CREDIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                Padding(padding: EdgeInsets.all(8), child: Text('BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(padding: EdgeInsets.all(8), child: Text('2026-08-20', style: TextStyle(fontSize: 11))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Opening Balance', style: TextStyle(fontSize: 11))),
                                Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11))),
                                Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11))),
                                Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        AppSnackbar.show(context, 'Exported customer ledger PDF to Downloads.', type: SnackType.success);
                      },
                      icon: const Icon(LucideIcons.fileDown, size: 14),
                      label: const Text('Export Statement PDF', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    if (isMacOS) {
      return _buildDesktopView(isMobile);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: (isMobile && _activeTab == 0)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton.extended(
                onPressed: _openAddCustomerModal,
                backgroundColor: const Color(0xFF166534),
                elevation: 4,
                icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                label: const Text(
                  'Add Customer',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting / Reports Style Header) ───
          SliverToBoxAdapter(
            child: _buildHeroSummary(isMobile)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 6),
          ),

          // ─── STICKY TAB NAVIGATION BAR ───
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabNavDelegate(
              height: isMobile ? 50 : 56,
              child: Container(
                color: const Color(0xFFF8F9FB),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildTabNav(isMobile),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 140 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activeTab == 0) ...[
                    // Search & Filter Row
                    _buildSearchFilterRow(isMobile),
                    const SizedBox(height: 16),
                    // Customers Table
                    _buildCustomersTable(isMobile),
                  ] else if (_activeTab == 1) ...[
                    // Aging & Collection Reports
                    _buildAgingReportsView(isMobile),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS / DESKTOP VIEW (UNTOUCHED ORIGINAL LAYOUT)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopView(bool isMobile) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 24,
          isMobile ? 12 : 20,
          isMobile ? 14 : 24,
          isMobile ? 80 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. HEADER (Image 2) ───
            _buildHeader(isMobile),
            const SizedBox(height: 18),

            // ─── 2. BENTO METRICS ROW (Image 2) ───
            _buildBentoMetrics(isMobile),
            const SizedBox(height: 18),

            // ─── 3. TABS BAR (Image 2 & 3) ───
            _buildTabsBar(isMobile),
            const SizedBox(height: 16),

            // ─── 4. TAB VIEW CONTENT ───
            if (_activeTab == 0) ...[
              // Search & Filter Row (Image 2)
              _buildSearchFilterRow(isMobile),
              const SizedBox(height: 16),
              // Customers Table (Image 2)
              _buildCustomersTable(isMobile),
            ] else if (_activeTab == 1) ...[
              // Aging & Collection Reports (Image 3)
              _buildAgingReportsView(isMobile),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE HERO SUMMARY CARD (Reports / Marketing / Barcode Gen Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
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
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.users, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CUSTOMER & UDHAAR LEDGER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.userCheck, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE STATUS',
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
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeroChip('ACTIVE CUSTOMERS', '${_customers.length}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('TOTAL OUTSTANDING', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('COLLECTION EFFICIENCY', '0%', isMobile),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 8.5 : 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE STICKY TAB NAVIGATION (Choice Chips matching Reports & Marketing)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabNav(bool isMobile) {
    final tabs = [
      {'label': 'Customers List', 'icon': LucideIcons.users},
      {'label': 'Aging & Collection Reports 📊', 'icon': LucideIcons.barChart2},
      {'label': 'Points Rules & Ratio', 'icon': LucideIcons.fileText},
    ];

    return Container(
      color: const Color(0xFFF8F9FB),
      height: isMobile ? 46 : 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 4),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeTab == index;
            final isLast = index == tabs.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: Builder(
                builder: (tabContext) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 2) {
                        _openPointsRulesModal();
                      } else {
                        setState(() => _activeTab = index);
                        Scrollable.ensureVisible(
                          tabContext,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: 0.5,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166534) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF166534).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[index]['icon'] as IconData,
                            size: isMobile ? 13 : 15,
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[index]['label'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 11.5 : 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. PAGE HEADER (Image 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isMobile) {
    final titleBlock = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x207C3AED),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(LucideIcons.userCheck, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Customers & Udhaar Ledger',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3),
              Text(
                'Manage customer profiles, credit limits, record payments, and export transaction statements.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _openBulkImportModal,
          icon: const Icon(LucideIcons.download, size: 14, color: Color(0xFF334155)),
          label: const Text(
            'Bulk Import (CSV)',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _openAddCustomerModal,
          icon: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
          label: const Text(
            'Add Customer',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF166534),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. BENTO METRICS ROW (Image 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBentoMetrics(bool isMobile) {
    final activeCount = _customers.length;

    final card1 = _buildSingleMetricCard(
      label: 'ACTIVE CUSTOMERS',
      value: '$activeCount',
      icon: LucideIcons.user,
      iconColor: const Color(0xFF9333EA),
      iconBg: const Color(0xFFF3E8FF),
    );

    final card2 = _buildSingleMetricCard(
      label: 'TOTAL OUTSTANDING (RECEIVABLES)',
      value: '₹0',
      icon: LucideIcons.alertCircle,
      iconColor: const Color(0xFFEF4444),
      iconBg: const Color(0xFFFEE2E2),
    );

    final card3 = _buildSingleMetricCard(
      label: 'ADVANCE RECEIVED',
      value: '₹0',
      icon: LucideIcons.clock,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFDBEAFE),
    );

    final card4 = _buildSingleMetricCard(
      label: 'COLLECTION EFFICIENCY',
      value: '0%',
      icon: LucideIcons.percent,
      iconColor: const Color(0xFF14B8A6),
      iconBg: const Color(0xFFCCFBF1),
    );

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 10),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 10),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 12),
        Expanded(child: card2),
        const SizedBox(width: 12),
        Expanded(child: card3),
        const SizedBox(width: 12),
        Expanded(child: card4),
      ],
    );
  }

  Widget _buildSingleMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. TABS BAR (Image 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTabsBar(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Tab 0: Customers List
          _buildPillTab(
            index: 0,
            icon: LucideIcons.user,
            label: 'Customers List',
            activeColor: const Color(0xFFEA580C),
            isSelected: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          const SizedBox(width: 8),

          // Tab 1: Aging & Collection Reports
          _buildPillTab(
            index: 1,
            icon: LucideIcons.barChart2,
            label: 'Aging & Collection Reports 📊',
            activeColor: const Color(0xFF0284C7),
            isSelected: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
          const SizedBox(width: 8),

          // Tab 2: Points Rules & Ratio (Modal trigger)
          _buildPillTab(
            index: 2,
            icon: LucideIcons.fileText,
            label: 'Points Rules & Ratio',
            activeColor: const Color(0xFF2563EB),
            isSelected: false,
            onTap: _openPointsRulesModal,
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. SEARCH & FILTER ROW (Image 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSearchFilterRow(bool isMobile) {
    final searchBox = Container(
      height: isMobile ? 36 : 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        style: TextStyle(fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Search by name, business or phone...',
          hintStyle: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF94A3B8)),
          prefixIcon: Icon(LucideIcons.search, size: isMobile ? 14 : 16, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 8 : 11),
        ),
      ),
    );

    final dropdownAndFilter = isMobile
        ? Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBalanceFilter,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      items: const [
                        DropdownMenuItem(value: 'All Balances', child: Text('All Balances')),
                        DropdownMenuItem(value: 'Receivables Only', child: Text('Receivables (Udhaar)')),
                        DropdownMenuItem(value: 'Settled (₹0)', child: Text('Settled (₹0)')),
                        DropdownMenuItem(value: 'High Credit Limit', child: Text('High Credit Limit')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBalanceFilter = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(LucideIcons.filter, size: 14, color: Color(0xFF64748B)),
                  onPressed: () {
                    AppSnackbar.show(context, 'Advanced customer filters applied.', type: SnackType.info);
                  },
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Balance filter dropdown
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBalanceFilter,
                    icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    items: const [
                      DropdownMenuItem(value: 'All Balances', child: Text('All Balances')),
                      DropdownMenuItem(value: 'Receivables Only', child: Text('Receivables (Udhaar)')),
                      DropdownMenuItem(value: 'Settled (₹0)', child: Text('Settled (₹0)')),
                      DropdownMenuItem(value: 'High Credit Limit', child: Text('High Credit Limit')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBalanceFilter = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button (Image 2)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.filter, size: 16, color: Color(0xFF64748B)),
                  onPressed: () {
                    AppSnackbar.show(context, 'Advanced customer filters applied.', type: SnackType.info);
                  },
                ),
              ),
            ],
          );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchBox,
          const SizedBox(height: 10),
          dropdownAndFilter,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchBox),
        const SizedBox(width: 12),
        dropdownAndFilter,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. CUSTOMERS BENTO TABLE (Image 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCustomersTable(bool isMobile) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _customers.where((c) {
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.business.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          (c.phone != null && c.phone!.contains(query));

      if (!matchesQuery) return false;

      if (_selectedBalanceFilter == 'Receivables Only') {
        return c.outstanding > 0;
      } else if (_selectedBalanceFilter == 'Settled (₹0)') {
        return c.outstanding == 0;
      } else if (_selectedBalanceFilter == 'High Credit Limit') {
        return c.creditLimit > 0;
      }
      return true;
    }).toList();

    if (isMobile && !isMacOS) {
      return _buildMobileCustomersCardList(filtered);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = isMobile
                ? math.max(constraints.maxWidth, 680.0)
                : math.max(constraints.maxWidth, 1140.0);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: isMobile
                      ? const {
                          0: FlexColumnWidth(2.5), // CUSTOMER NAME
                          1: FlexColumnWidth(2.7), // BUSINESS / EMAIL
                          2: FlexColumnWidth(1.6), // GSTIN / TYPE
                          3: FlexColumnWidth(1.2), // CREDIT LIMIT
                          4: FlexColumnWidth(1.2), // OUTSTANDING
                          5: FlexColumnWidth(1.8), // LOYALTY PTS / VIEW LEDGER
                          6: FixedColumnWidth(44), // ACTIONS
                        }
                      : const {
                          0: FlexColumnWidth(2.6), // CUSTOMER NAME
                          1: FlexColumnWidth(3.4), // BUSINESS / EMAIL
                          2: FlexColumnWidth(1.8), // GSTIN / TYPE
                          3: FlexColumnWidth(1.4), // CREDIT LIMIT
                          4: FlexColumnWidth(1.4), // OUTSTANDING
                          5: FlexColumnWidth(2.0), // LOYALTY PTS / VIEW LEDGER
                          6: FixedColumnWidth(60), // ACTIONS
                        },
                  children: [
                    // Table Header Row (Image 2)
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0)),
                      ),
                      children: [
                        _buildTableHeaderCell('CUSTOMER NAME ▽', isMobile: isMobile),
                        _buildTableHeaderCell('BUSINESS / EMAIL ▽', isMobile: isMobile),
                        _buildTableHeaderCell('GSTIN / TYPE ▽', isMobile: isMobile),
                        _buildTableHeaderCell('CREDIT LIMIT ▽', isMobile: isMobile),
                        _buildTableHeaderCell('OUTSTANDING ▽', isMobile: isMobile),
                        _buildTableHeaderCell('LOYALTY PTS ▽', isMobile: isMobile),
                        _buildTableHeaderCell('ACTIONS', alignment: Alignment.center, isMobile: isMobile),
                      ],
                    ),

                    // Customer Rows (Image 2)
                    ...filtered.map((cust) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        children: [
                          // Col 0: Customer Name + Avatar + Code + Status
                          _buildTableCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: isMobile ? 13 : 17,
                                  backgroundColor: cust.avatarBg,
                                  child: Text(
                                    cust.avatarLetter,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: cust.avatarFg,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 7 : 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cust.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: isMobile ? 11.5 : 13,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: isMobile ? 4 : 5,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            cust.code != null ? 'Code: ${cust.code}' : 'Code:',
                                            style: TextStyle(fontSize: isMobile ? 9 : 10, color: const Color(0xFF64748B)),
                                          ),
                                          Text(
                                            cust.statusText,
                                            style: TextStyle(
                                              fontSize: isMobile ? 9 : 10,
                                              fontWeight: FontWeight.bold,
                                              color: cust.statusFg,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 1: Business / Email / Phone / Supplier Pill (Image 2)
                          _buildTableCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cust.business,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 11 : 12.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  cust.email,
                                  style: TextStyle(
                                    fontSize: isMobile ? 9.5 : 11,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (cust.phone != null) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    cust.phone!,
                                    style: TextStyle(fontSize: isMobile ? 9 : 10.5, color: const Color(0xFF64748B)),
                                  ),
                                ],
                                if (cust.connectionRequest != null) ...[
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 6, vertical: isMobile ? 1.5 : 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cust.connectionRequest!,
                                      style: TextStyle(
                                        fontSize: isMobile ? 8.5 : 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 2: GSTIN / Type
                          _buildTableCell(
                            Text(
                              cust.gstin,
                              style: TextStyle(
                                fontSize: isMobile ? 10.5 : 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 3: Credit Limit
                          _buildTableCell(
                            Text(
                              cust.creditLimit > 0 ? '₹${cust.creditLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'), (m) => '${m[1]},')}' : '₹0',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 4: Outstanding
                          _buildTableCell(
                            Text(
                              '₹${cust.outstanding.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 5: Loyalty Pts / View Ledger Button (Image 2)
                          _buildTableCell(
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () => _openLedgerModal(cust),
                                icon: Icon(LucideIcons.fileText, size: isMobile ? 10 : 12, color: const Color(0xFF7C3AED)),
                                label: Text(
                                  'View Ledger',
                                  style: TextStyle(
                                    fontSize: isMobile ? 9.5 : 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3E8FF),
                                  foregroundColor: const Color(0xFF7C3AED),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 7 : 10, vertical: isMobile ? 4 : 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                ),
                              ),
                            ),
                            isMobile: isMobile,
                          ),

                          // Col 6: More Actions Menu (⋯)
                          _buildTableCell(
                            Center(
                              child: PopupMenuButton<String>(
                                icon: Icon(LucideIcons.ellipsis, size: isMobile ? 13 : 16, color: const Color(0xFF64748B)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'ledger', child: Text('View Ledger & Udhaar', style: TextStyle(fontSize: 12))),
                                  const PopupMenuItem(value: 'payment', child: Text('Record Payment', style: TextStyle(fontSize: 12))),
                                  const PopupMenuItem(value: 'credit', child: Text('Adjust Credit Limit', style: TextStyle(fontSize: 12))),
                                  const PopupMenuItem(value: 'whatsapp', child: Text('Send WhatsApp Statement', style: TextStyle(fontSize: 12))),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete Customer', style: TextStyle(fontSize: 12, color: Colors.red))),
                                ],
                                onSelected: (val) {
                                  if (val == 'ledger') {
                                    _openLedgerModal(cust);
                                  } else if (val == 'payment') {
                                    AppSnackbar.show(context, 'Payment record dialog for ${cust.name}.', type: SnackType.info);
                                  } else if (val == 'credit') {
                                    AppSnackbar.show(context, 'Credit limit editor for ${cust.name}.', type: SnackType.info);
                                  } else if (val == 'whatsapp') {
                                    AppSnackbar.show(context, 'WhatsApp statement sent to ${cust.name}.', type: SnackType.success);
                                  } else if (val == 'delete') {
                                    setState(() {
                                      _customers.removeWhere((c) => c.id == cust.id);
                                    });
                                    AppSnackbar.show(context, 'Customer removed from ledger.', type: SnackType.info);
                                  }
                                },
                              ),
                            ),
                            alignment: Alignment.center,
                            isMobile: isMobile,
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
      ),
    );
  }

  Widget _buildMobileCustomersCardList(List<_CustomerRecord> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: const [
            Icon(LucideIcons.users, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No customers found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cust = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name/Code/Status + PopupMenu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: cust.avatarBg,
                    child: Text(
                      cust.avatarLetter,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: cust.avatarFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cust.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              cust.code != null ? 'Code: ${cust.code}' : 'Code: -',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: cust.statusBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cust.statusText,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: cust.statusFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.ellipsis, size: 16, color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'ledger', child: Text('View Ledger & Udhaar', style: TextStyle(fontSize: 12))),
                      const PopupMenuItem(value: 'payment', child: Text('Record Payment', style: TextStyle(fontSize: 12))),
                      const PopupMenuItem(value: 'credit', child: Text('Adjust Credit Limit', style: TextStyle(fontSize: 12))),
                      const PopupMenuItem(value: 'whatsapp', child: Text('Send WhatsApp Statement', style: TextStyle(fontSize: 12))),
                      const PopupMenuItem(value: 'delete', child: Text('Delete Customer', style: TextStyle(fontSize: 12, color: Colors.red))),
                    ],
                    onSelected: (val) {
                      if (val == 'ledger') {
                        _openLedgerModal(cust);
                      } else if (val == 'payment') {
                        AppSnackbar.show(context, 'Payment record dialog for ${cust.name}.', type: SnackType.info);
                      } else if (val == 'credit') {
                        AppSnackbar.show(context, 'Credit limit editor for ${cust.name}.', type: SnackType.info);
                      } else if (val == 'whatsapp') {
                        AppSnackbar.show(context, 'WhatsApp statement sent to ${cust.name}.', type: SnackType.success);
                      } else if (val == 'delete') {
                        setState(() {
                          _customers.removeWhere((c) => c.id == cust.id);
                        });
                        AppSnackbar.show(context, 'Customer removed from ledger.', type: SnackType.info);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Business / Email / Phone
              Text(
                cust.business,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(LucideIcons.mail, size: 11, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      cust.email,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (cust.phone != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 11, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      cust.phone!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
              if (cust.connectionRequest != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cust.connectionRequest!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // Financial stats row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GSTIN / TYPE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            cust.gstin,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CREDIT LIMIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            cust.creditLimit > 0 ? '₹${cust.creditLimit.toStringAsFixed(0)}' : '₹0',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('OUTSTANDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            '₹${cust.outstanding.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: cust.outstanding > 0 ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // View Ledger Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openLedgerModal(cust),
                  icon: const Icon(LucideIcons.fileText, size: 12, color: Color(0xFF7C3AED)),
                  label: const Text(
                    'View Ledger',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E8FF),
                    foregroundColor: const Color(0xFF7C3AED),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeaderCell(String text, {Alignment alignment = Alignment.centerLeft, bool isMobile = false}) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20, vertical: isMobile ? 8 : 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 11 : 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child, {Alignment alignment = Alignment.centerLeft, bool isMobile = false}) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20, vertical: isMobile ? 7 : 16),
      child: ClipRect(child: child),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. TAB 1: AGING & COLLECTION REPORTS (Image 3)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAgingReportsView(bool isMobile) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Outstanding Receivables Ledger (Image 3)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: const Color(0xFFEA580C), size: isMobile ? 16 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Outstanding Receivables Ledger',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.circleCheck, color: const Color(0xFF16A34A), size: isMobile ? 16 : 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No overdue receivables logged. All customer accounts are settled and in good standing.',
                        style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF64748B), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 18),

        // Card 2: Outstanding Aging Reports (Image 3)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.clock, color: const Color(0xFF0D9488), size: isMobile ? 16 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Outstanding Aging Reports',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 18),
              // 3 Equal-width Aging stat boxes perfectly aligned
              Row(
                children: [
                  Expanded(
                    child: _buildAgingPill(
                      label: '0 - 15 Days',
                      value: '₹0',
                      textColor: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                      isCompact: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: _buildAgingPill(
                      label: '16 – 30 Days',
                      value: '₹0',
                      textColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                      isCompact: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: _buildAgingPill(
                      label: '31+ Days',
                      value: '₹0',
                      textColor: const Color(0xFFDC2626),
                      bgColor: const Color(0xFFFEE2E2),
                      isCompact: isMobile,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Collection Efficiency Rate (Image 3)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.pieChart, color: const Color(0xFF8B5CF6), size: isMobile ? 16 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Collection Efficiency Rate',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 18 : 24),
              // Radial ring gauge with 0% in center (Image 3)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? 76 : 90,
                      height: isMobile ? 76 : 90,
                      child: CircularProgressIndicator(
                        value: 0.0,
                        strokeWidth: isMobile ? 7 : 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                    ),
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Center(
                child: Text(
                  'Collection efficiency indicates recovered payments out of overall credit sales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 10.5 : 11,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 18),

        // Card 2: Top Customer Sales Contribution (Image 3)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.trendingUp, color: const Color(0xFF7C3AED), size: isMobile ? 16 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Top Customer Sales Contribution',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              // 6 Ranked Sales Contribution bars (Image 3)
              _buildContributionRow('sanjay123', '₹5,90,06,15,376', 1.0, const Color(0xFF8B5CF6), isCompact: isMobile),
              _buildContributionRow('Varshini', '₹2,36,61,23,372', 0.45, const Color(0xFF06B6D4), isCompact: isMobile),
              _buildContributionRow('Ravi kumar', '₹2,36,11,03,466', 0.44, const Color(0xFF06B6D4), isCompact: isMobile),
              _buildContributionRow('ravikumar', '₹5,20,241', 0.08, const Color(0xFFA78BFA), isCompact: isMobile),
              _buildContributionRow('ravikumar', '₹5,20,241', 0.08, const Color(0xFFA78BFA), isCompact: isMobile),
              _buildContributionRow('ravikumar', '₹4,65,161', 0.07, const Color(0xFFA78BFA), isCompact: isMobile),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftColumn,
          const SizedBox(height: 14),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 11, child: leftColumn),
        const SizedBox(width: 20),
        Expanded(flex: 9, child: rightColumn),
      ],
    );
  }

  Widget _buildAgingPill({
    required String label,
    required String value,
    required Color textColor,
    required Color bgColor,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 9 : 9.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isCompact ? 4 : 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionRow(String name, String amount, double progress, Color barColor, {bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: isCompact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amount,
                style: TextStyle(
                  fontSize: isCompact ? 10.5 : 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4338CA),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 3 : 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: isCompact ? 4.5 : 5.5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STICKY TAB NAV DELEGATE
// ═══════════════════════════════════════════════════════════════
class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyTabNavDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
