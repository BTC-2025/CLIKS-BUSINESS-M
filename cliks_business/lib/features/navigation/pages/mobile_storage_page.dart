import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';

// ─── Storage Tabs ───────────────────────────────────────────────────────────
enum _MobileStorageTab {
  overview,
  cliksBusiness,
  usage,
  recycleBin,
  manageApps,
  settings,
}

class MobileStoragePage extends ConsumerStatefulWidget {
  const MobileStoragePage({super.key});

  @override
  ConsumerState<MobileStoragePage> createState() => _MobileStoragePageState();
}

class _MobileStoragePageState extends ConsumerState<MobileStoragePage>
    with SingleTickerProviderStateMixin {
  _MobileStorageTab _activeTab = _MobileStorageTab.cliksBusiness;
  String _lastUpdatedText = 'Just now';
  bool _isRefreshing = false;

  // Recycle Bin state
  String _selectedRecycleFilter = 'ALL';
  final TextEditingController _recycleSearchController = TextEditingController();
  String _recycleSearchQuery = '';

  // Settings state
  bool _showUsagePercentage = true;
  bool _showAvailableStorage = true;
  bool _showAppStatus = true;
  bool _showStorageAlerts = true;
  String _selectedTheme = 'System';
  String _storageAccess = 'only_me';

  late List<_RecycleItem> _recycleItems;

  @override
  void initState() {
    super.initState();
    _recycleItems = [
      _RecycleItem(name: 'Invoice_March_2024.pdf', size: '2.1 MB', type: 'PDF', app: 'Cliks Business', deletedOn: '2 days ago'),
      _RecycleItem(name: 'Expense_Receipts_Q1.zip', size: '14.5 MB', type: 'ZIP', app: 'Cliks Business', deletedOn: '5 days ago'),
      _RecycleItem(name: 'Staff_Payslip_Feb.pdf', size: '0.8 MB', type: 'PDF', app: 'Cliks Business', deletedOn: '1 week ago'),
      _RecycleItem(name: 'Product_Images_Batch.zip', size: '38.2 MB', type: 'ZIP', app: 'Cliks Business', deletedOn: '2 weeks ago'),
      _RecycleItem(name: 'GSTReport_2023_Q4.xlsx', size: '1.3 MB', type: 'XLS', app: 'Cliks Business', deletedOn: '3 weeks ago'),
      _RecycleItem(name: 'BNXMail_Archive.mbox', size: '55.0 MB', type: 'MBOX', app: 'BNX Mail', deletedOn: '1 month ago'),
    ];
  }

  @override
  void dispose() {
    _recycleSearchController.dispose();
    super.dispose();
  }

  void _triggerRefresh() {
    setState(() => _isRefreshing = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _isRefreshing = false;
          _lastUpdatedText = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTopTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            ref.read(navigationProvider.notifier).setRoute(AppRoute.dashboard);
          }
        },
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(LucideIcons.cloud, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Storage',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.3),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: _triggerRefresh,
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isRefreshing ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: const Icon(LucideIcons.refreshCw, size: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 5),
                Text(
                  _isRefreshing ? '...' : _lastUpdatedText,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildTopTabBar() {
    final tabs = [
      (icon: LucideIcons.home, label: 'Overview', tab: _MobileStorageTab.overview),
      (icon: LucideIcons.briefcase, label: 'Cliks Biz', tab: _MobileStorageTab.cliksBusiness),
      (icon: LucideIcons.barChart2, label: 'Usage', tab: _MobileStorageTab.usage),
      (icon: LucideIcons.trash2, label: 'Bin', tab: _MobileStorageTab.recycleBin),
      (icon: LucideIcons.layoutGrid, label: 'Apps', tab: _MobileStorageTab.manageApps),
      (icon: LucideIcons.settings, label: 'Settings', tab: _MobileStorageTab.settings),
    ];

    return Container(
      color: Colors.white,
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: tabs.map((t) {
            final isActive = _activeTab == t.tab;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = t.tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryGreen : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon, size: 13, color: isActive ? Colors.white : const Color(0xFF475569)),
                    const SizedBox(width: 5),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_activeTab) {
      _MobileStorageTab.overview => _buildOverviewTab(),
      _MobileStorageTab.cliksBusiness => _buildCliksBusinessTab(),
      _MobileStorageTab.usage => _buildUsageTab(),
      _MobileStorageTab.recycleBin => _buildRecycleBinTab(),
      _MobileStorageTab.manageApps => _buildManageAppsTab(),
      _MobileStorageTab.settings => _buildSettingsTab(),
    };
  }

  // ─── OVERVIEW TAB ────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.cloud, size: 15, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('TOTAL STORAGE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.6)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('921', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5, height: 1)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 4),
                      child: Text('MB used', style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: CustomPaint(
                        painter: _DonutPainter(progress: 0.90, color: Colors.white, bg: Colors.white24),
                        child: const Center(child: Text('90%', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: const LinearProgressIndicator(value: 0.90, minHeight: 6, backgroundColor: Colors.white24, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('103 MB free', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    Text('1.00 GB total', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Critical warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFECACA))),
            child: const Row(
              children: [
                Icon(LucideIcons.alertTriangle, size: 15, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Expanded(child: Text('Storage critically full. Review and free up space.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('APPLICATION STORAGE'),
          const SizedBox(height: 8),
          _appStorageCard('Cliks Business', LucideIcons.briefcase, 0.90, '921 MB', const Color(0xFF7C3AED)),
          const SizedBox(height: 8),
          _appStorageCard('BNX Mail', LucideIcons.mail, 0.06, '61 MB', const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          _appStorageCard('Cliks', LucideIcons.shoppingCart, 0.02, '20 MB', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBAE6FD))),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 10),
                Expanded(child: Text('Keep storage light! Review cache logs and large attachments inside Cliks Business.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0369A1)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appStorageCard(String name, IconData icon, double progress, String used, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 5),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: const Color(0xFFF1F5F9), color: color)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(used, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── CLIKS BUSINESS TAB ──────────────────────────────────────────────────
  Widget _buildCliksBusinessTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.briefcase, size: 17, color: Color(0xFF7C3AED))),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliks Business Storage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.3)),
                    Text('Track how your 1.00 GB storage is used', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            children: [
              Expanded(child: _statCard('921 MB', 'USED', const Color(0xFF7C3AED))),
              const SizedBox(width: 8),
              Expanded(child: _statCard('103 MB', 'FREE', const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _statCard('1.00 GB', 'TOTAL', const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 14),
          // Donut card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: _DonutPainter(progress: 0.90, color: const Color(0xFF6366F1), bg: const Color(0xFFF1F5F9)),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('90%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1)),
                          Text('USED', style: TextStyle(fontSize: 8, color: Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dotLegend(const Color(0xFF6366F1), '921 MB used (90%)'),
                      const SizedBox(height: 6),
                      _dotLegend(const Color(0xFF10B981), '103 MB free (10%)'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFECACA))),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.alertTriangle, size: 11, color: Color(0xFFEF4444)),
                            SizedBox(width: 4),
                            Text('Critical', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('STORAGE BY CATEGORY'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _categoryRow(const Color(0xFF2563EB), 'Audit & Tax (FIN-PRO)', '9%', const Color(0xFF2563EB), 'PDFs, XLS, Certificates'),
                const Divider(height: 1, color: Color(0xFFF8FAFC)),
                _categoryRow(const Color(0xFF10B981), 'Sales & Purchases', '25%', const Color(0xFF059669), 'PDF Invoices, Vendor Bills'),
                const Divider(height: 1, color: Color(0xFFF8FAFC)),
                _categoryRow(const Color(0xFF7C3AED), 'Expenses', '14%', const Color(0xFF7C3AED), 'Receipt Scans, Images'),
                const Divider(height: 1, color: Color(0xFFF8FAFC)),
                _categoryRow(const Color(0xFFF59E0B), 'HR & Payroll', '0%', const Color(0xFFD97706), 'ID Documents, Payslips'),
                const Divider(height: 1, color: Color(0xFFF8FAFC)),
                _categoryRow(const Color(0xFF0284C7), 'Inventory & Media', '42%', const Color(0xFF0D9488), 'Product Photos, Barcodes'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBAE6FD))),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 10),
                Expanded(child: Text('Review cache logs, large attachments, or database backups to free up space.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0369A1)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _dotLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _categoryRow(Color dot, String name, String percent, Color badgeColor, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                Text(type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: badgeColor.withValues(alpha: 0.3))),
            child: Text(percent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
        ],
      ),
    );
  }

  // ─── USAGE TAB ───────────────────────────────────────────────────────────
  Widget _buildUsageTab() {
    final items = [
      ('Cliks Business', 0.90, const Color(0xFF7C3AED), '921 MB'),
      ('BNX Mail', 0.06, const Color(0xFF2563EB), '61 MB'),
      ('Cliks', 0.02, const Color(0xFF10B981), '20 MB'),
      ('System Cache', 0.01, const Color(0xFFF59E0B), '10 MB'),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('STORAGE USAGE OVERVIEW'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1.00 GB Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text('103 MB Free', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(6), child: const LinearProgressIndicator(value: 0.90, minHeight: 10, backgroundColor: Color(0xFFF1F5F9), color: Color(0xFF7C3AED))),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('921 MB Used', style: TextStyle(fontSize: 11.5, color: Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                    Text('90% Used', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('BY APPLICATION'),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.$1, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          Text(item.$4, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: item.$3)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: item.$2, minHeight: 7, backgroundColor: const Color(0xFFF1F5F9), color: item.$3)),
                      const SizedBox(height: 4),
                      Text('${(item.$2 * 100).round()}% of total', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ─── RECYCLE BIN TAB ─────────────────────────────────────────────────────
  Widget _buildRecycleBinTab() {
    final filters = ['ALL', 'PDF', 'ZIP', 'XLS', 'MBOX'];
    final filtered = _recycleItems.where((item) {
      final matchFilter = _selectedRecycleFilter == 'ALL' || item.type == _selectedRecycleFilter;
      final matchSearch = _recycleSearchQuery.isEmpty || item.name.toLowerCase().contains(_recycleSearchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            children: [
              TextField(
                controller: _recycleSearchController,
                onChanged: (v) => setState(() => _recycleSearchQuery = v),
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search files...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                  suffixIcon: _recycleSearchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () { setState(() { _recycleSearchQuery = ''; _recycleSearchController.clear(); }); },
                          child: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF166534))),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: filters.map((f) {
                    final isActive = _selectedRecycleFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRecycleFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryGreen : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? AppColors.primaryGreen : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(f, style: TextStyle(fontSize: 11.5, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF475569))),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.trash2, size: 40, color: Colors.grey[300]), const SizedBox(height: 12), Text('No files found', style: TextStyle(color: Colors.grey[400], fontSize: 14))]))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _recycleItemCard(filtered[i]),
                ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(14, 8, 14, 88 + MediaQuery.of(context).padding.bottom),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _recycleItems.clear());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recycle Bin emptied'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(LucideIcons.trash2, size: 15),
            label: const Text('Empty Recycle Bin'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ],
    );
  }

  Widget _recycleItemCard(_RecycleItem item) {
    final typeColors = {'PDF': const Color(0xFFEF4444), 'ZIP': const Color(0xFFF59E0B), 'XLS': const Color(0xFF10B981), 'MBOX': const Color(0xFF2563EB)};
    final color = typeColors[item.type] ?? AppColors.primaryGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(item.type, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${item.size} · ${item.app} · ${item.deletedOn}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _recycleItems.remove(item)),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MANAGE APPS TAB ─────────────────────────────────────────────────────
  Widget _buildManageAppsTab() {
    final apps = [
      (name: 'Cliks Business', icon: LucideIcons.briefcase, color: const Color(0xFF7C3AED), used: '921 MB'),
      (name: 'BNX Mail', icon: LucideIcons.mail, color: const Color(0xFF2563EB), used: '61 MB'),
      (name: 'Cliks', icon: LucideIcons.shoppingCart, color: const Color(0xFF10B981), used: '20 MB'),
    ];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('CONNECTED APPLICATIONS'),
          const SizedBox(height: 8),
          ...apps.map((app) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: app.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(app.icon, size: 20, color: app.color)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(app.used, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFDCF2E4), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          _sectionHeader('SYSTEM PREFERENCES'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _prefRow('Pool Size', '5 connections'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _prefRow('Storage Unit', 'GB'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _prefRow('Decimal Precision', '2 digits'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ],
    );
  }

  // ─── SETTINGS TAB ────────────────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('DISPLAY'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _switchTile('Show Usage Percentage', _showUsagePercentage, (v) => setState(() => _showUsagePercentage = v)),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _switchTile('Show Available Storage', _showAvailableStorage, (v) => setState(() => _showAvailableStorage = v)),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _switchTile('Show App Status', _showAppStatus, (v) => setState(() => _showAppStatus = v)),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _switchTile('Storage Alerts', _showStorageAlerts, (v) => setState(() => _showStorageAlerts = v)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionHeader('APPEARANCE'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Theme', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Row(
                  children: ['Light', 'System', 'Dark'].map((t) {
                    final isActive = _selectedTheme == t;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTheme = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: isActive ? AppColors.primaryGreen : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF475569))),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionHeader('STORAGE ACCESS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _radioTile('Only Me', 'Private - only you can view', 'only_me'),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _radioTile('Connected Apps', 'Connected apps can read usage data', 'connected'),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _radioTile('Shared Access', 'Team members can view storage stats', 'shared'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully'), backgroundColor: Color(0xFF166634), behavior: SnackBarBehavior.floating)); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _radioTile(String title, String subtitle, String value) {
    final isActive = _storageAccess == value;
    return InkWell(
      onTap: () => setState(() => _storageAccess = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isActive ? AppColors.primaryGreen : const Color(0xFFCBD5E1), width: 2)),
              child: isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle))) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.6));
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────
class _RecycleItem {
  final String name, size, type, app, deletedOn;
  _RecycleItem({required this.name, required this.size, required this.type, required this.app, required this.deletedOn});
}

// ─── Donut Painter ────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color, bg;
  const _DonutPainter({required this.progress, required this.color, required this.bg});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 6;
    const sw = 8.0;
    final bPaint = Paint()..color = bg..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round;
    final fPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fPaint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}
