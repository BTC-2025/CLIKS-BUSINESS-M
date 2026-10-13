import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_ui_kit.dart';

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
    final nameCtrl = TextEditingController();
    final businessCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final creditLimitCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.userPlus, color: Color(0xFF166534), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add New Customer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Customer Full Name *',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Mobile Phone *',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: businessCtrl,
                        decoration: InputDecoration(
                          labelText: 'Business Name / Category',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: gstinCtrl,
                        decoration: InputDecoration(
                          labelText: 'GSTIN (Optional)',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditLimitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Credit Limit (₹)',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          AppSnackbar.show(context, 'Please enter customer name', type: SnackType.warning);
                          return;
                        }
                        setState(() {
                          _customers.insert(
                            0,
                            _CustomerRecord(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameCtrl.text.trim(),
                              code: 'CUST-${math.Random().nextInt(9000) + 1000}',
                              statusText: 'Connected',
                              statusBg: const Color(0xFFDCFCE7),
                              statusFg: const Color(0xFF15803D),
                              business: businessCtrl.text.trim().isEmpty ? 'Personal' : businessCtrl.text.trim(),
                              email: emailCtrl.text.trim().isEmpty ? 'client@company.com' : emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                              connectionRequest: null,
                              gstin: gstinCtrl.text.trim().isEmpty ? 'Unregistered' : gstinCtrl.text.trim(),
                              creditLimit: double.tryParse(creditLimitCtrl.text.trim()) ?? 0,
                              outstanding: 0,
                              loyaltyPts: 0,
                              avatarBg: const Color(0xFFDCFCE7),
                              avatarFg: const Color(0xFF15803D),
                              avatarLetter: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim()[0].toUpperCase() : 'C',
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        AppSnackbar.show(context, 'Customer added successfully', type: SnackType.success);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Save Customer', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Row(
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
                        const Text(
                          'Bulk Import Customers',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 580),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Header (Image 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
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
                          ],
                        ),
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

                    // Ratio Cards Side-by-Side (Image 4)
                    Row(
                      children: [
                        // Card 1: Earning Ratio
                        Expanded(
                          child: Container(
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
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Card 2: Money Value Ratio
                        Expanded(
                          child: Container(
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
                          ),
                        ),
                      ],
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
                              Text(
                                'Interactive Points-to-Money Converter',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Left: Purchase Amount
                              Expanded(
                                flex: 4,
                                child: Column(
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
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(LucideIcons.arrowRight, size: 16, color: Color(0xFF166534)),
                              const SizedBox(width: 10),
                              // Right: Points Earned & Cashback
                              Expanded(
                                flex: 5,
                                child: Column(
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
                                      child: Text(
                                        '+$points pts (₹$cashback)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        Column(
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
                      ],
                    ),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(width: 10),
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
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: const InputDecoration(
          hintText: 'Search by name, business or phone...',
          hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    );

    final dropdownAndFilter = Row(
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
        children: [
          searchBox,
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: dropdownAndFilter),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = math.max(constraints.maxWidth, 1140.0);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
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
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      children: [
                        _buildTableHeaderCell('CUSTOMER NAME ▽'),
                        _buildTableHeaderCell('BUSINESS / EMAIL ▽'),
                        _buildTableHeaderCell('GSTIN / TYPE ▽'),
                        _buildTableHeaderCell('CREDIT LIMIT ▽'),
                        _buildTableHeaderCell('OUTSTANDING ▽'),
                        _buildTableHeaderCell('LOYALTY PTS ▽'),
                        _buildTableHeaderCell('ACTIONS', alignment: Alignment.center),
                      ],
                    ),

                    // Customer Rows (Image 2)
                    ...filtered.map((cust) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                        ),
                        children: [
                          // Col 0: Customer Name + Avatar + Code + Status
                          _buildTableCell(
                            Row(
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cust.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (cust.code != null) ...[
                                            Text(
                                              'Code: ${cust.code}',
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                            ),
                                            const SizedBox(width: 5),
                                          ] else ...[
                                            const Text(
                                              'Code:',
                                              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                            ),
                                            const SizedBox(width: 5),
                                          ],
                                          Flexible(
                                            child: Text(
                                              cust.statusText,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: cust.statusFg,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Col 1: Business / Email / Phone / Supplier Pill (Image 2)
                          _buildTableCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cust.business,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  cust.email,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2563EB),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (cust.phone != null) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    cust.phone!,
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
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
                              ],
                            ),
                          ),

                          // Col 2: GSTIN / Type
                          _buildTableCell(
                            Text(
                              cust.gstin,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),

                          // Col 3: Credit Limit
                          _buildTableCell(
                            Text(
                              cust.creditLimit > 0 ? '₹${cust.creditLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'), (m) => '${m[1]},')}' : '₹0',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),

                          // Col 4: Outstanding
                          _buildTableCell(
                            Text(
                              '₹${cust.outstanding.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),

                          // Col 5: Loyalty Pts / View Ledger Button (Image 2)
                          _buildTableCell(
                            Align(
                              alignment: Alignment.centerLeft,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                ),
                              ),
                            ),
                          ),

                          // Col 6: More Actions Menu (⋯)
                          _buildTableCell(
                            Center(
                              child: PopupMenuButton<String>(
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
                            ),
                            alignment: Alignment.center,
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

  Widget _buildTableHeaderCell(String text, {Alignment alignment = Alignment.centerLeft}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child, {Alignment alignment = Alignment.centerLeft}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                children: const [
                  Icon(LucideIcons.alertTriangle, color: Color(0xFFEA580C), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Outstanding Receivables Ledger',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'No overdue receivables logged. All customer accounts are settled and in good standing.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Card 2: Outstanding Aging Reports (Image 3)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                children: const [
                  Icon(LucideIcons.clock, color: Color(0xFF0D9488), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Outstanding Aging Reports',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // 3 Aging stat boxes (Image 3)
              Row(
                children: [
                  Expanded(
                    child: _buildAgingPill(
                      label: '0 - 15 Days',
                      value: '₹0',
                      textColor: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildAgingPill(
                      label: '16 – 30 Days Overdue',
                      value: '₹0',
                      textColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildAgingPill(
                      label: '31+ Days Critical',
                      value: '₹0',
                      textColor: const Color(0xFFDC2626),
                      bgColor: const Color(0xFFFEE2E2),
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            children: [
              const Text(
                'Collection Efficiency Rate',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              // Radial ring gauge with 0% in center (Image 3)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 0.0,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
                  const Text(
                    '0%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Collection efficiency indicates recovered payments out of overall credit sales.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Card 2: Top Customer Sales Contribution (Image 3)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                children: const [
                  Icon(LucideIcons.trendingUp, color: Color(0xFF7C3AED), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Top Customer Sales Contribution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 6 Ranked Sales Contribution bars (Image 3)
              _buildContributionRow('sanjay123', '₹5,90,06,15,376', 1.0, const Color(0xFF8B5CF6)),
              _buildContributionRow('Varshini', '₹2,36,61,23,372', 0.45, const Color(0xFF06B6D4)),
              _buildContributionRow('Ravi kumar', '₹2,36,11,03,466', 0.44, const Color(0xFF06B6D4)),
              _buildContributionRow('ravikumar', '₹5,20,241', 0.08, const Color(0xFFA78BFA)),
              _buildContributionRow('ravikumar', '₹5,20,241', 0.08, const Color(0xFFA78BFA)),
              _buildContributionRow('ravikumar', '₹4,65,161', 0.07, const Color(0xFFA78BFA)),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftColumn,
          const SizedBox(height: 18),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionRow(String name, String amount, double progress, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4338CA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
