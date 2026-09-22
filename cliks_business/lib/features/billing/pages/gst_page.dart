import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/modals/finance_modals.dart';

class GstPage extends ConsumerStatefulWidget {
  const GstPage({super.key});

  @override
  ConsumerState<GstPage> createState() => _GstPageState();
}

class _GstPageState extends ConsumerState<GstPage> {
  int _activeTab = 0; // 0: GSTR-1 (Sales), 1: GSTR-2 (Purchase), 2: GSTR-3B (Liability), 3: GSTR-9 (Annual), 4: e-Invoice, 5: e-Way Logistics

  final List<Map<String, dynamic>> _tabsInfo = [
    {'label': 'GSTR-1 (Sales)', 'icon': LucideIcons.fileText, 'color': const Color(0xFFD63384)},
    {'label': 'GSTR-2 (Purchase)', 'icon': LucideIcons.refreshCw, 'color': const Color(0xFF2563EB)},
    {'label': 'GSTR-3B (Liability)', 'icon': LucideIcons.xCircle, 'color': const Color(0xFF7C3AED)},
    {'label': 'GSTR-9 (Annual)', 'icon': LucideIcons.award, 'color': const Color(0xFFD97706)},
    {'label': 'e-Invoice', 'icon': LucideIcons.qrCode, 'color': const Color(0xFF0D9488)},
    {'label': 'e-Way Logistics', 'icon': LucideIcons.truck, 'color': const Color(0xFF1E40AF)},
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFy = 'FY 2024-25';
  bool _gstr3bFiled = false;
  String _gstr3bAckNo = '';
  bool _gstr9cCertified = false;

  // State Data Lists
  final List<Map<String, String>> _gstr1Invoices = [
    {
      'invNo': 'BILL-228060',
      'date': '2026-08-08',
      'customer': 'Ravi',
      'gstin': 'N/A',
      'type': 'B2B',
      'pos': 'N/A',
      'taxable': '4237.29',
      'cgstSgst': '0.00',
      'igst': '762.71',
      'totalGst': '762.71',
      'status': 'READY',
    },
  ];

  final List<Map<String, String>> _vendorInvoices = [
    {
      'gstin': 'URD-UNREGISTERED',
      'vendor': 'Ravi',
      'invNo': 'BILL-228060',
      'date': '2026-08-08',
      'totalVal': '5000',
      'gstAmt': '762.71',
      'taxSplit': 'I: ₹762.71',
      'eligibleItc': '762.71',
      'status': 'PENDING',
    },
  ];

  final List<Map<String, String>> _eInvoices = [
    {
      'irn': '89f1a2938471bc890192837492817492019',
      'invNo': 'BILL-228060',
      'ackNo': '122091823901',
      'ackDate': '2026-08-08',
      'customer': 'Ravi',
      'amount': '₹5,000.00',
      'status': 'AUTHENTICATED',
    },
  ];

  final List<Map<String, String>> _eWayBills = [
    {
      'ewbNo': '381029301923',
      'invNo': 'BILL-228060',
      'transporter': 'BlueDart Express',
      'vehicle': 'MH-12-AB-1234',
      'distance': '145 Kms',
      'route': 'Mumbai - Pune',
      'status': 'ACTIVE',
    },
  ];

  final List<Map<String, String>> _monthlyFilingHistory = [
    {'month': 'April 2024', 'taxable': '₹0', 'outputGst': '₹0', 'eligibleItc': '₹0', 'gstPaid': '₹0', 'gstr1': 'FILED', 'gstr3b': 'FILED'},
    {'month': 'May 2024', 'taxable': '₹0', 'outputGst': '₹0', 'eligibleItc': '₹0', 'gstPaid': '₹0', 'gstr1': 'FILED', 'gstr3b': 'FILED'},
    {'month': 'June 2024', 'taxable': '₹0', 'outputGst': '₹0', 'eligibleItc': '₹0', 'gstPaid': '₹0', 'gstr1': 'FILED', 'gstr3b': 'FILED'},
    {'month': 'July 2024', 'taxable': '₹0', 'outputGst': '₹0', 'eligibleItc': '₹0', 'gstPaid': '₹0', 'gstr1': 'FILED', 'gstr3b': 'FILED'},
    {'month': 'August 2024', 'taxable': '₹4,237.29', 'outputGst': '₹762.71', 'eligibleItc': '₹0', 'gstPaid': '₹762.71', 'gstr1': 'READY', 'gstr3b': 'PENDING'},
  ];

  // Dynamic Calculated Metrics
  double get _totalTaxableSales {
    return _gstr1Invoices.fold(0.0, (sum, item) => sum + (double.tryParse(item['taxable'] ?? '0') ?? 0.0));
  }

  double get _totalOutputGst {
    return _gstr1Invoices.fold(0.0, (sum, item) => sum + (double.tryParse(item['totalGst'] ?? '0') ?? 0.0));
  }

  double get _totalIgst {
    return _gstr1Invoices.fold(0.0, (sum, item) => sum + (double.tryParse(item['igst'] ?? '0') ?? 0.0));
  }

  double get _claimedItc {
    return _vendorInvoices
        .where((inv) => inv['status'] == 'VERIFIED' || inv['status'] == 'MATCHED')
        .fold(0.0, (sum, item) => sum + (double.tryParse(item['eligibleItc'] ?? '0') ?? 0.0));
  }

  double get _netGstPayable {
    final net = _totalOutputGst - _claimedItc;
    return net < 0 ? 0.0 : net;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGenerateEWayBillModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GenerateEWayBillModal(
        onGenerated: (newEwb) {
          setState(() {
            _eWayBills.insert(0, newEwb);
            _activeTab = 5; // Automatically navigate to e-Way Logistics tab to display new bill
          });
        },
      ),
    );
  }

  void _openGenerateEInvoiceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GenerateEInvoiceModal(
        onGenerated: (newEinvoice) {
          setState(() {
            _eInvoices.insert(0, newEinvoice);

            // Also insert into GSTR-1 Sales Invoices
            _gstr1Invoices.insert(0, {
              'invNo': newEinvoice['invNo'] ?? 'BILL-228061',
              'date': newEinvoice['ackDate'] ?? '2026-08-08',
              'customer': newEinvoice['customer'] ?? 'Saravana Stores',
              'gstin': newEinvoice['gstin'] ?? '33ABCDE1234F1Z5',
              'type': newEinvoice['type'] ?? 'B2B',
              'pos': '33 - Tamil Nadu',
              'taxable': newEinvoice['taxable'] ?? '5000.00',
              'cgstSgst': (double.parse(newEinvoice['gstAmt'] ?? '600') / 2).toStringAsFixed(2),
              'igst': '0.00',
              'totalGst': newEinvoice['gstAmt'] ?? '600.00',
              'status': 'AUTHENTICATED',
            });

            _activeTab = 4; // Automatically navigate to e-Invoice tab to display new IRN
          });
        },
      ),
    );
  }

  void _openVerifyVendorInvoiceModal([Map<String, String>? initialData, int? itemIndex]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VerifyVendorInvoiceModal(
        initialData: initialData,
        onSettle: (updatedData) {
          setState(() {
            final rawAmt = updatedData['amount']?.replaceAll('₹', '').replaceAll(',', '').trim() ?? '5000';
            final parsedAmt = double.tryParse(rawAmt) ?? 5000.0;
            final calculatedItc = (parsedAmt * 0.18).toStringAsFixed(2);

            if (itemIndex != null && itemIndex < _vendorInvoices.length) {
              _vendorInvoices[itemIndex] = {
                'gstin': updatedData['gstin'] ?? 'URD-UNREGISTERED',
                'vendor': updatedData['vendor'] ?? 'Vendor',
                'invNo': initialData?['invNo'] ?? 'BILL-228060',
                'date': initialData?['date'] ?? '2026-08-08',
                'totalVal': parsedAmt.toStringAsFixed(2),
                'gstAmt': calculatedItc,
                'taxSplit': "I: ₹$calculatedItc",
                'eligibleItc': calculatedItc,
                'status': updatedData['status'] ?? 'MATCHED',
              };
            } else {
              _vendorInvoices.insert(0, {
                'gstin': updatedData['gstin'] ?? '27AAAAA1111A1Z1',
                'vendor': updatedData['vendor'] ?? 'Acme Hardwares',
                'invNo': "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                'date': '2026-08-08',
                'totalVal': parsedAmt.toStringAsFixed(2),
                'gstAmt': calculatedItc,
                'taxSplit': "I: ₹$calculatedItc",
                'eligibleItc': calculatedItc,
                'status': updatedData['status'] ?? 'VERIFIED',
              });
            }
            _activeTab = 1; // Automatically navigate to GSTR-2 (Purchase) tab to display updated ITC
          });
        },
      ),
    );
  }

  void _fileGstr3bReturn() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('File GSTR-3B Return', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          "Confirm set-off of Outward Tax Liability (₹${_totalOutputGst.toStringAsFixed(2)}) against Eligible ITC (₹${_claimedItc.toStringAsFixed(2)}) for tax period August 2026?",
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _gstr3bFiled = true;
                _gstr3bAckNo = "GSTR3B-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
              });
              AppSnackbar.show(context, "GSTR-3B Return filed successfully! Ack: $_gstr3bAckNo", type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            child: const Text('Confirm & File Return', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _generateGstr9cAudit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('GSTR-9C Reconciliation Audit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          "Audit variance between Audited Financial Statements & GSTR-9 Annual Return is ₹0.00.\n\nProceed to attach Digital Signature Certificate (DSC) and generate certified GSTR-9C Report?",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _gstr9cCertified = true;
              });
              AppSnackbar.show(context, "GSTR-9C Reconciliation Audit Certified by CA/CMA successfully!", type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            child: const Text('Sign & Certify GSTR-9C', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Floating Action Button for GST Actions (matches AccountingPage FAB design)
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: _triggerPrimaryAction,
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(_getFABLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── FINANCIAL SUMMARY HERO CARD (Green Gradient) ───
          SliverToBoxAdapter(
            child: _buildHeroSummary(isMobile)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),
          ),

          SliverToBoxAdapter(
            child: const SizedBox(height: 6),
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

          SliverToBoxAdapter(
            child: const SizedBox(height: 8),
          ),

          // ─── TAB CONTENT ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 90 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGstinBanner(isMobile),
                  const SizedBox(height: 12),
                  _buildMainContent(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY (Green gradient card matching Accounting Page)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 8 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                    'GST & TAX COMPLIANCE',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_formatCurrency(_totalOutputGst)}',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
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
                    const Icon(LucideIcons.trendingUp, size: 13, color: Colors.greenAccent),
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
              _buildHeroChip('Taxable Sales', '₹${_formatCurrency(_totalTaxableSales)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Output Tax', '₹${_formatCurrency(_totalOutputGst)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Eligible ITC', '₹${_formatCurrency(_claimedItc)}', isMobile),
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
  // TAB NAVIGATION (matching Accounting Page pill tab style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabNav(bool isMobile) {
    return Container(
      height: isMobile ? 46 : 52,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 6),
        itemCount: _tabsInfo.length,
        itemBuilder: (context, index) {
          final isSelected = _activeTab == index;
          final tab = _tabsInfo[index];

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
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
                      ? [BoxShadow(color: const Color(0xFF166534).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: isMobile ? 13 : 15,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 11.5 : 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 10000000) {
      return '${(val / 10000000).toStringAsFixed(2)}Cr';
    } else if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(2)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}K';
    }
    return val.toStringAsFixed(0);
  }

  void _triggerPrimaryAction() {
    switch (_activeTab) {
      case 1:
        _openVerifyVendorInvoiceModal();
        break;
      case 2:
        _fileGstr3bReturn();
        break;
      case 3:
        _generateGstr9cAudit();
        break;
      case 5:
        _openGenerateEWayBillModal();
        break;
      default:
        _openGenerateEInvoiceModal();
        break;
    }
  }

  String _getFABLabel() {
    switch (_activeTab) {
      case 1:
        return 'Verify Vendor';
      case 2:
        return 'File GSTR-3B';
      case 3:
        return 'Certify 9C';
      case 5:
        return 'e-Way Bill';
      default:
        return 'e-Invoice';
    }
  }

  // --- GSTIN BANNER ---
  Widget _buildGstinBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.award, color: Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Government GSTIN Registered', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                SizedBox(height: 2),
                Text('Legal Name: | Type:', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
              ],
            ),
          ),
          if (!isMobile)
            const Text('Place of Supply Code: {}', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
        ],
      ),
    );
  }



  // --- DYNAMIC MAIN CONTENT VIEW ---
  Widget _buildMainContent(bool isMobile) {
    if (_activeTab == 1) return _buildGstr2View(isMobile);
    if (_activeTab == 2) return _buildGstr3bView(isMobile);
    if (_activeTab == 3) return _buildGstr9View(isMobile);
    if (_activeTab == 4) return _buildEInvoiceView(isMobile);
    if (_activeTab == 5) return _buildEWayView(isMobile);

    return _buildGstr1View(isMobile);
  }

  // --- TAB 0: GSTR-1 (SALES) VIEW ---
  Widget _buildGstr1View(bool isMobile) {
    final filtered = _gstr1Invoices.where((inv) {
      final q = _searchController.text.toLowerCase();
      return inv['invNo']!.toLowerCase().contains(q) || inv['customer']!.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? double.infinity : 320,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 11.5),
              decoration: InputDecoration(
                hintText: 'Search GST Invoices or state...',
                hintStyle: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                prefixIcon: const Icon(LucideIcons.search, size: 15, color: AppColors.secondaryText),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (isMobile) ...[
            if (filtered.isEmpty)
              _buildEmptyBox('No GST sales invoices found.')
            else
              Column(
                children: filtered.map((inv) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv['invNo']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                  const SizedBox(height: 2),
                                  Text("${inv['date']} • ${inv['customer']}", style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                              child: Text(inv['status']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Taxable: ₹${inv['taxable']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                            Text("Total GST: ₹${inv['totalGst']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ] else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: AppColors.isMacOS ? 1050 : 950,
                child: Column(
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.4),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.0),
                        3: FlexColumnWidth(0.9),
                        4: FlexColumnWidth(1.3),
                        5: FlexColumnWidth(1.3),
                        6: FlexColumnWidth(1.1),
                        7: FlexColumnWidth(1.1),
                        8: FlexColumnWidth(1.2),
                        9: FlexColumnWidth(1.0),
                        10: FlexColumnWidth(0.8),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2))),
                          children: ['INVOICE NO', 'CUSTOMER', 'GSTIN', 'TYPE', 'PLACE OF SUPPLY', 'TAXABLE VALUE', 'CGST/SGST', 'IGST', 'TOTAL GST', 'STATUS', 'ACTIONS'].map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    h,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(LucideIcons.chevronDown, size: 9, color: AppColors.secondaryText),
                              ],
                            ),
                          )).toList(),
                        ),
                        ...filtered.map((inv) => TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv['invNo']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                  Text(inv['date']!, style: const TextStyle(fontSize: 9.5, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv['customer']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                  Text(inv['gstin']!, style: const TextStyle(fontSize: 9.5, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(inv['gstin']!, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                child: Text(inv['type']!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(inv['pos']!, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("₹${inv['taxable']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("₹${inv['cgstSgst']}", style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("₹${inv['igst']}", style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("₹${inv['totalGst']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                child: Text(inv['status']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: IconButton(
                                onPressed: _openGenerateEInvoiceModal,
                                icon: const Icon(LucideIcons.moreVertical, size: 14, color: AppColors.secondaryText),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 1: GSTR-2 (PURCHASE) VIEW ---
  Widget _buildGstr2View(bool isMobile) {
    final titleWidget = const Text(
      'GSTR-2B Purchase ITC Reconciliations',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),

          if (isMobile) ...[
            if (_vendorInvoices.isEmpty)
              _buildEmptyBox('No vendor purchase invoices for ITC reconciliation.')
            else
              Column(
                children: _vendorInvoices.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isPending = item['status'] == 'PENDING';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['vendor']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                  const SizedBox(height: 2),
                                  Text("${item['gstin']} • ${item['invNo']}", style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['status']!,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPending ? const Color(0xFFD97706) : const Color(0xFF166534)),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ₹${item['totalVal']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                            Text("Eligible ITC: ₹${item['eligibleItc']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _openVerifyVendorInvoiceModal(item, idx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1D4ED8)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('Verify', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _vendorInvoices.removeAt(idx);
                                });
                                AppSnackbar.show(context, "Vendor invoice removed.", type: SnackType.info);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(LucideIcons.trash2, size: 15, color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ] else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 920,
                child: Column(
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(1.1),
                        2: FlexColumnWidth(1.2),
                        3: FlexColumnWidth(1.1),
                        4: FlexColumnWidth(1.1),
                        5: FlexColumnWidth(1.1),
                        6: FlexColumnWidth(1.2),
                        7: FlexColumnWidth(1.2),
                        8: FlexColumnWidth(1.0),
                        9: FlexColumnWidth(1.0),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2))),
                          children: ['Vendor GSTIN', 'Vendor Name', 'Invoice No', 'Date', 'Total Value', 'GST Amt', 'CGST/SGST/IGST', 'Eligible ITC', 'Status', 'Actions'].map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Text(h, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                          )).toList(),
                        ),
                        ..._vendorInvoices.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final isPending = item['status'] == 'PENDING';

                          return TableRow(
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(item['gstin']!, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(item['vendor']!, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(item['invNo']!, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(item['date']!, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text("₹${item['totalVal']}", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text("₹${item['gstAmt']}", style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text(item['taxSplit']!, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Text("₹${item['eligibleItc']}", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['status']!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isPending ? const Color(0xFFD97706) : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _openVerifyVendorInvoiceModal(item, idx),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF1D4ED8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      child: const Text('Verify', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _vendorInvoices.removeAt(idx);
                                        });
                                        AppSnackbar.show(context, "Vendor invoice removed.", type: SnackType.info);
                                      },
                                      icon: const Icon(LucideIcons.trash2, size: 13, color: Color(0xFFEF4444)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 2: GSTR-3B (LIABILITY) VIEW ---
  Widget _buildGstr3bView(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                          child: const Text('GSTR-3B COMPLIANCE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(_gstr3bFiled ? LucideIcons.checkCircle2 : LucideIcons.clock, size: 13, color: _gstr3bFiled ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              _gstr3bFiled ? 'Status: Filed & Verified' : 'Status: Ready to File',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _gstr3bFiled ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                          child: const Text('GSTR-3B COMPLIANCE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(_gstr3bFiled ? LucideIcons.checkCircle2 : LucideIcons.clock, size: 13, color: _gstr3bFiled ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              _gstr3bFiled ? 'Status: Filed & Verified' : 'Status: Ready to File',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _gstr3bFiled ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              const Text(
                'Self-Declared Summary Return (Monthly)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 2),
              Text(
                _gstr3bFiled
                    ? "GSTR-3B filed successfully. Acknowledgement Reference: $_gstr3bAckNo"
                    : 'Aggregate outward liabilities set off against eligible input tax credits.',
                style: TextStyle(fontSize: 11, color: _gstr3bFiled ? const Color(0xFF15803D) : AppColors.secondaryText, fontWeight: _gstr3bFiled ? FontWeight.bold : FontWeight.normal),
              ),
              const SizedBox(height: 16),

              if (isMobile) ...[
                _buildOutwardSuppliesCard(),
                const SizedBox(height: 12),
                _buildEligibleItcCard(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildOutwardSuppliesCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildEligibleItcCard()),
                  ],
                ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FINAL NET TAX LIABILITY PAYABLE (CASH OUTFLOW)',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBE123C), letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildNetPayableMiniCard('Net IGST Payable', "₹${_netGstPayable.toStringAsFixed(2)}")),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNetPayableMiniCard('Net CGST Payable', '₹0.00')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNetPayableMiniCard('Net SGST Payable', '₹0.00')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutwardSuppliesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OUTWARD TAXABLE SUPPLIES (SALES)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), letterSpacing: 0.3)),
          const SizedBox(height: 12),
          _buildRowDetail('Taxable Value:', "₹${_totalTaxableSales.toStringAsFixed(2)}", isBoldVal: true),
          _buildRowDetail('Integrated Tax (IGST):', "₹${_totalIgst.toStringAsFixed(2)}"),
          _buildRowDetail('Central Tax (CGST):', '₹0.00'),
          _buildRowDetail('State Tax (SGST):', '₹0.00'),
          const Divider(height: 16),
          _buildRowDetail('Total Liability:', "₹${_totalOutputGst.toStringAsFixed(2)}", isBoldTitle: true, isBoldVal: true, customColor: const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildEligibleItcCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ELIGIBLE INPUT TAX CREDIT (ITC)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D), letterSpacing: 0.3)),
          const SizedBox(height: 12),
          _buildRowDetail('Eligible IGST Available:', "₹${_claimedItc.toStringAsFixed(2)}", isBoldVal: true),
          _buildRowDetail('Eligible Central Tax (CGST):', '₹0.00'),
          _buildRowDetail('Eligible State Tax (SGST):', '₹0.00'),
          _buildRowDetail('Ineligible/Blocked Credit:', '₹0.00'),
          const Divider(height: 16),
          _buildRowDetail('Total Claimable ITC:', "₹${_claimedItc.toStringAsFixed(2)}", isBoldTitle: true, isBoldVal: true, customColor: const Color(0xFF15803D)),
        ],
      ),
    );
  }

  Widget _buildRowDetail(String title, String val, {bool isBoldTitle = false, bool isBoldVal = false, Color? customColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: isBoldTitle ? FontWeight.bold : FontWeight.w500, color: customColor ?? AppColors.darkText)),
          Text(val, style: TextStyle(fontSize: 11.5, fontWeight: isBoldVal ? FontWeight.bold : FontWeight.w600, color: customColor ?? AppColors.darkText)),
        ],
      ),
    );
  }

  Widget _buildNetPayableMiniCard(String title, String val) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFBE123C))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color iconColor, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: GSTR-9 (ANNUAL RETURN SUMMARY & RECONCILIATION) VIEW ---
  Widget _buildGstr9View(bool isMobile) {
    final annualStatCards = [
      _buildStatCard('TOTAL TAXABLE SALES', "₹${_totalTaxableSales.toStringAsFixed(2)}", LucideIcons.trendingUp, const Color(0xFFEC4899), const Color(0xFFFCE7F3)),
      _buildStatCard('TOTAL TAXABLE PURCHASES', "₹${_totalTaxableSales.toStringAsFixed(2)}", LucideIcons.trendingDown, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
      _buildStatCard('OUTPUT GST COLLECTED', "₹${_totalOutputGst.toStringAsFixed(2)}", LucideIcons.percent, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
      _buildStatCard('ELIGIBLE ITC CLAIMED', "₹${_claimedItc.toStringAsFixed(2)}", LucideIcons.checkCircle2, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GSTR-9 Annual Return', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    const SizedBox(height: 2),
                    Text("Financial Year Summary & Reconciliation ($_selectedFy)", style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFy,
                              isDense: true,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              items: ['FY 2024-25', 'FY 2023-24', 'FY 2022-23'].map((fy) => DropdownMenuItem(value: fy, child: Text(fy))).toList(),
                              onChanged: (val) => setState(() => _selectedFy = val!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => AppSnackbar.show(context, "Exporting Annual GSTR-9 PDF report for $_selectedFy...", type: SnackType.info),
                            icon: const Icon(LucideIcons.download, size: 13),
                            label: const Text('Export Annual PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GSTR-9 Annual Return', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                          const SizedBox(height: 2),
                          Text("Financial Year Summary & Reconciliation ($_selectedFy)", style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFy,
                                isDense: true,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                items: ['FY 2024-25', 'FY 2023-24', 'FY 2022-23'].map((fy) => DropdownMenuItem(value: fy, child: Text(fy))).toList(),
                                onChanged: (val) => setState(() => _selectedFy = val!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => AppSnackbar.show(context, "Exporting Annual GSTR-9 PDF report for $_selectedFy...", type: SnackType.info),
                            icon: const Icon(LucideIcons.download, size: 14),
                            label: const Text('Export Annual PDF', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              if (isMobile)
                Column(
                  children: [
                    annualStatCards[0],
                    const SizedBox(height: 8),
                    annualStatCards[1],
                    const SizedBox(height: 8),
                    annualStatCards[2],
                    const SizedBox(height: 8),
                    annualStatCards[3],
                  ],
                )
              else
                Row(children: annualStatCards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10.0), child: c))).toList()),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (isMobile) ...[
          _buildAnnualStatutoryCard(),
          const SizedBox(height: 14),
          _buildAnnualReconciliationCard(),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildAnnualStatutoryCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildAnnualReconciliationCard()),
            ],
          ),
        const SizedBox(height: 16),

        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monthly Filing History Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 14),

              if (isMobile)
                Column(
                  children: _monthlyFilingHistory.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['month']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                              child: Text(item['gstr1']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Sales: ${item['taxable']}", style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                            Text("GST Paid: ${item['gstPaid']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: 850,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.2),
                            5: FlexColumnWidth(1.2),
                            6: FlexColumnWidth(1.2),
                          },
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2))),
                              children: ['MONTH', 'TAXABLE SALES', 'OUTPUT GST', 'ELIGIBLE ITC', 'GST PAID', 'GSTR-1', 'GSTR-3B'].map((h) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Text(h, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                              )).toList(),
                            ),
                            ..._monthlyFilingHistory.map((item) => TableRow(
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                              children: [
                                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(item['month']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(item['taxable']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(item['outputGst']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(item['eligibleItc']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(item['gstPaid']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text(item['gstr1']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text(item['gstr3b']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualStatutoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Annual Statutory Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 14),
          _buildRowDetail('Total Taxable Sales (Outward)', "₹${_totalTaxableSales.toStringAsFixed(2)}", isBoldVal: true),
          _buildRowDetail('Exempt / Nil Rated Sales', '₹0.00'),
          _buildRowDetail('Zero Rated / Export Sales', '₹0.00'),
          _buildRowDetail('Total Taxable Purchases (Inward)', "₹${_totalTaxableSales.toStringAsFixed(2)}"),
          _buildRowDetail('Total Eligible ITC Availed', "₹${_claimedItc.toStringAsFixed(2)}"),
          _buildRowDetail('Total Output Tax Liability', "₹${_totalOutputGst.toStringAsFixed(2)}"),
          _buildRowDetail('Net GST Paid (Cash Ledger)', "₹${_gstr3bFiled ? _netGstPayable.toStringAsFixed(2) : '0.00'}"),
        ],
      ),
    );
  }

  Widget _buildAnnualReconciliationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Annual Reconciliation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
              if (_gstr9cCertified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                  child: const Text('CERTIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3E8FF))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DIFFERENCE IN SALES (BOOKS VS RETURNS)', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('MATCHED', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('₹0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3E8FF))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DIFFERENCE IN ITC (GSTR-2B VS 3B)', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('MATCHED', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('₹0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('LATE FILING INTERESTS / PENALTIES', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('NONE DUE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('₹0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: e-INVOICE VIEW ---
  Widget _buildEInvoiceView(bool isMobile) {
    final titleWidget = const Text(
      'Government e-Invoice Portal IRN Registry',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),
          ..._eInvoices.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCCFBF1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IRN: ${e['irn']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text("${e['invNo']} • ${e['customer']} • ${e['amount']}", style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(4)),
                  child: Text(e['status']!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // --- TAB 5: e-WAY LOGISTICS VIEW ---
  Widget _buildEWayView(bool isMobile) {
    final titleWidget = const Text(
      'Government e-Way Bills Transport tracking',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),

          if (isMobile) ...[
            if (_eWayBills.isEmpty)
              _buildEmptyBox('No active e-Way bills found.')
            else
              Column(
                children: _eWayBills.map((w) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("EWB: ${w['ewbNo']}", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                            child: Text(w['status']!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Carrier: ${w['transporter']} • ${w['vehicle']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      const SizedBox(height: 2),
                      Text("Route: ${w['route']} (${w['distance']})", style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                    ],
                  ),
                )).toList(),
              ),
          ] else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 950,
                child: Column(
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.4),
                        1: FlexColumnWidth(1.3),
                        2: FlexColumnWidth(1.4),
                        3: FlexColumnWidth(1.1),
                        4: FlexColumnWidth(1.4),
                        5: FlexColumnWidth(1.0),
                        6: FlexColumnWidth(0.8),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2)),
                          ),
                          children: [
                            'e-Way Bill No',
                            'Carrier Name',
                            'Vehicle Registration No',
                            'Distance (Kms)',
                            'Source - Destination',
                            'Status',
                            'Actions'
                          ].map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            child: Text(h, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                          )).toList(),
                        ),
                        ..._eWayBills.map((w) => TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(w['ewbNo']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(w['transporter']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(w['vehicle']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(w['distance']!, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), child: Text(w['route']!, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                                child: Text(w['status']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                              child: IconButton(
                                onPressed: _openGenerateEWayBillModal,
                                icon: const Icon(LucideIcons.moreVertical, size: 14, color: AppColors.secondaryText),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBox(String text) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.fileText, size: 36, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

// ─── Sticky Header Delegate ───
class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabNavDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

