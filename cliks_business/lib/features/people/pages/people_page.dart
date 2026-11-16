import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/enroll_contact_dialog.dart';

/// People Network & Escrow Page
/// Pixel-perfect matching of the Modern Escrow & People Network UI
/// Supporting all operating systems (macOS, Windows, Linux, Web, Android, iOS).
class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  // Active Tab Index:
  // 0: Contacts, 1: Financial Groups (1), 2: Requests, 3: Global Ledger, 4: Repayment Alerts
  int _activeTab = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  // Sub-page navigation: if non-null, shows full Contact Ledger detail view
  Map<String, dynamic>? _selectedContactForDetail;

  // ───────────────────────────────────────────────────────────────────────────
  // CONTACTS DATASET (Exactly matching Image 2)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': 'c_kamesh',
      'name': 'kamesh',
      'connected': true,
      'classification': 'COLLEAGUE',
      'company': 'kamesh mmotors',
      'phone': '8124512392',
      'email': 'itsokletssee123@bnxmail.com',
      'ledgerStand': 20000.0,
      'avatarBg': const Color(0xFFF3E8FF),
      'avatarColor': const Color(0xFF7C3AED),
      'transactions': <Map<String, dynamic>>[
        {
          'id': 'tx_k1',
          'isLent': true,
          'amount': 20000.0,
          'date': '12/11/2026',
          'memo': 'advance for super market',
          'classification': 'LENT',
        },
      ],
      'repaymentAlerts': <Map<String, dynamic>>[
        {
          'id': 'alt_k1',
          'date': '12/11/2026',
          'memo': 'loan which is gave you 20iuiw',
          'amount': 20000.0,
          'status': 'Pending',
        },
      ],
    },
    {
      'id': 'c_sridharan',
      'name': 'sridharan',
      'connected': true,
      'classification': 'COLLEAGUE',
      'company': 'dsfsadfasasdfasdsdff',
      'phone': '+919360521158',
      'email': 'sridharan@bnxmail.com',
      'ledgerStand': 0.0,
      'avatarBg': const Color(0xFFFCE7F3),
      'avatarColor': const Color(0xFFDB2777),
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_virat',
      'name': 'virat kholi',
      'connected': true,
      'classification': 'CHITHAPPA',
      'company': 'cricket RCB',
      'phone': '8984724747',
      'email': 'aruntest@bnxmail.com',
      'ledgerStand': 0.0,
      'avatarBg': const Color(0xFFFEF3C7),
      'avatarColor': const Color(0xFFD97706),
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_monica_1',
      'name': 'monica',
      'connected': true,
      'classification': 'COLLEAGUE',
      'company': 'dfd',
      'phone': '9090909033',
      'email': 'monica@bnxmail.com',
      'ledgerStand': 0.0,
      'avatarBg': const Color(0xFFFFE4E6),
      'avatarColor': const Color(0xFFE11D48),
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_monica_2',
      'name': 'monica',
      'connected': true,
      'classification': 'COLLEAGUE',
      'company': 'dsfdsf',
      'phone': '9090909033',
      'email': 'monica@bnxmail.com',
      'ledgerStand': 0.0,
      'avatarBg': const Color(0xFFFFE4E6),
      'avatarColor': const Color(0xFFE11D48),
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_rahul',
      'name': 'Rahul tewatiya',
      'connected': false,
      'classification': 'FRIEND',
      'company': 'rahul bats',
      'phone': '8072960208',
      'email': 'connectwithravi2004@gmail.com',
      'ledgerStand': 500056.0,
      'avatarBg': const Color(0xFFD1FAE5),
      'avatarColor': const Color(0xFF059669),
      'transactions': <Map<String, dynamic>>[
        {
          'id': 'tx_r1',
          'isLent': true,
          'amount': 500000.0,
          'date': '18/9/2026',
          'memo': 'efnierfnijer',
          'classification': 'LENT',
        },
        {
          'id': 'tx_r2',
          'isLent': true,
          'amount': 56.0,
          'date': '11/9/2026',
          'memo': '',
          'classification': 'LENT',
        },
      ],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // FINANCIAL GROUPS DATASET (Exactly matching Images 3, 4, 5)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _financialGroups = [
    {
      'id': 'grp_1',
      'tag': 'PROJECT OUTLAYS',
      'activeMembers': 2,
      'name': 'new grp',
      'description': 'lets see its working correctly',
      'targetPool': 50000.0,
      'contributed': 10000.0,
      'expenses': 0.0,
      'netFundInHand': 10000.0,
      'toGivePrivate': 0.0,
      'members': [
        {
          'name': 'ravinew2004',
          'email': 'ravinew2004@bnxmail.com',
          'role': 'admin',
          'status': 'Active',
          'totalPaid': 0.0,
          'contributed': 5000.0,
          'owed': 0.0,
          'netBalance': 5000.0,
        },
        {
          'name': 'kamesh',
          'email': 'itsokletssee123@bnxmail.com',
          'role': 'manager',
          'status': 'Active',
          'totalPaid': 0.0,
          'contributed': 5000.0,
          'owed': 0.0,
          'netBalance': 5000.0,
        },
      ],
      'transactions': [
        {
          'id': 'tx_g1',
          'date': '10 Nov 2026',
          'member': 'ravinew2004',
          'amount': 5000.0,
          'type': 'Initial Capital Contribution',
          'memo': 'Seed pool deposit',
        },
        {
          'id': 'tx_g2',
          'date': '12 Nov 2026',
          'member': 'kamesh',
          'amount': 5000.0,
          'type': 'Partner Pool Contribution',
          'memo': 'Syndicate share buy-in',
        },
      ],
    },
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // REQUESTS DATASET (Direct Requests matching Image 5)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _requests = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculated Real-Time Aggregates
  double get _netReceivables => _contacts
      .where((c) => (c['ledgerStand'] as num).toDouble() > 0)
      .fold(0.0, (sum, c) => sum + (c['ledgerStand'] as num).toDouble());

  double get _netPayables => _contacts
      .where((c) => (c['ledgerStand'] as num).toDouble() < 0)
      .fold(0.0, (sum, c) => sum + (c['ledgerStand'] as num).toDouble().abs());

  List<Map<String, dynamic>> get _filteredContacts {
    if (_searchQuery.trim().isEmpty) return _contacts;
    final q = _searchQuery.toLowerCase();
    return _contacts.where((c) {
      final name = (c['name'] as String).toLowerCase();
      final company = (c['company'] as String).toLowerCase();
      final phone = (c['phone'] as String).toLowerCase();
      final email = (c['email'] as String).toLowerCase();
      final cat = (c['classification'] as String).toLowerCase();
      return name.contains(q) ||
          company.contains(q) ||
          phone.contains(q) ||
          email.contains(q) ||
          cat.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _allGlobalTransactions {
    final List<Map<String, dynamic>> list = [];
    for (var c in _contacts) {
      final txs = c['transactions'] as List<Map<String, dynamic>>;
      for (var t in txs) {
        list.add({
          ...t,
          'contactId': c['id'],
          'contactName': c['name'],
          'contactClassification': c['classification'],
        });
      }
    }
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((t) {
      final name = (t['contactName'] as String? ?? '').toLowerCase();
      final memo = (t['memo'] as String? ?? '').toLowerCase();
      final date = (t['date'] as String? ?? '').toLowerCase();
      final classification = (t['classification'] as String? ?? '').toLowerCase();
      return name.contains(q) || memo.contains(q) || date.contains(q) || classification.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _allRepaymentAlerts {
    final List<Map<String, dynamic>> list = [];
    for (var c in _contacts) {
      final alerts = c['repaymentAlerts'] as List<Map<String, dynamic>>;
      for (var a in alerts) {
        list.add({...a, 'contactId': c['id'], 'contactName': c['name']});
      }
    }
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((a) {
      final name = (a['contactName'] as String? ?? '').toLowerCase();
      final memo = (a['memo'] as String? ?? a['purpose'] as String? ?? '').toLowerCase();
      final date = (a['date'] as String? ?? '').toLowerCase();
      return name.contains(q) || memo.contains(q) || date.contains(q);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_selectedContactForDetail != null) {
      return _buildContactDetailView(_selectedContactForDetail!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 850;
        final double horizontalPadding = availableWidth >= 1200
            ? 32.0
            : (availableWidth >= 800 ? 24.0 : 16.0);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                isMobile ? 100 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Row (Matching Image 2)
                  _buildHeaderRow(context, isMobile),
                  const SizedBox(height: 22),

                  // 2. Top Metric KPI Cards (TO RECEIVE / TO PAY)
                  _buildTopMetricsRow(availableWidth),
                  const SizedBox(height: 22),

                  // 3. Segmented Tabs Row + Search Icon Button
                  _buildTabsRow(isMobile),
                  const SizedBox(height: 18),

                  // Search Bar if expanded
                  if (_isSearchVisible) ...[
                    _buildExpandedSearchBar(),
                    const SizedBox(height: 14),
                  ],

                  // 4. Tab Content Body
                  _buildTabContent(availableWidth, isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. HEADER ROW (Matching Image 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderRow(BuildContext context, bool isMobile) {
    final titleWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF166534), // Forest Green
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24166534),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.users,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'People Network & Escrow',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Track peer-to-peer relationships, log personal advances, track friendly loans, and set ledger alerts.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Outlined "Log Transaction" Button
        OutlinedButton.icon(
          onPressed: () => _openGeneralLogModal(isMobile),
          icon: const Icon(
            LucideIcons.arrowLeftRight,
            size: 14,
            color: Color(0xFF166534),
          ),
          label: const Text(
            'Log Transaction',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Color(0xFF166534),
              letterSpacing: -0.2,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 10),

        // Solid "+ Add People Contact" Button
        ElevatedButton.icon(
          onPressed: _openAddContactDialog,
          icon: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
          label: const Text(
            'Add People Contact',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF166534),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: const Color(0x33166534),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. TOP METRICS ROW (Matching Image 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopMetricsRow(double availableWidth) {
    final cardReceive = _buildKpiCard(
      label: 'TO RECEIVE',
      badgeText: '0% Collected',
      badgeBg: const Color(0xFFDCFCE7),
      badgeFg: const Color(0xFF15803D),
      amount: '₹${_fmt(_netReceivables)}',
      totalText: 'Total: ₹${_fmt(_netReceivables)}',
      subText: 'Received: ₹0',
      subColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFECFDF5),
      iconWidget: const Icon(
        LucideIcons.trendingUp,
        color: Color(0xFF10B981),
        size: 18,
      ),
    );

    final cardPay = _buildKpiCard(
      label: 'TO PAY',
      badgeText: '0% Settled',
      badgeBg: const Color(0xFFFEE2E2),
      badgeFg: const Color(0xFFDC2626),
      amount: '₹${_fmt(_netPayables)}',
      totalText: 'Total: ₹${_fmt(_netPayables)}',
      subText: 'Paid: ₹0',
      subColor: const Color(0xFFEF4444),
      iconBg: const Color(0xFFFEE2E2),
      iconWidget: const Icon(
        LucideIcons.trendingDown,
        color: Color(0xFFEF4444),
        size: 18,
      ),
    );

    if (availableWidth >= 750) {
      return Row(
        children: [
          Expanded(child: cardReceive),
          const SizedBox(width: 16),
          Expanded(child: cardPay),
        ],
      );
    }

    return Column(
      children: [
        cardReceive,
        const SizedBox(height: 12),
        cardPay,
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String amount,
    required String totalText,
    required String subText,
    required Color subColor,
    required Color iconBg,
    required Widget iconWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 14),

          // Center Label + Badge + Big Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Total & Settled Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                totalText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subColor,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. SEGMENTED TABS ROW (Matching Images 2 & 3)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabsRow(bool isMobile) {
    final tabs = [
      {'label': 'Contacts', 'icon': LucideIcons.users},
      {'label': 'Financial Groups (${_financialGroups.length})', 'icon': LucideIcons.walletCards},
      {'label': 'Requests', 'icon': LucideIcons.userPlus},
      {'label': 'Global Ledger', 'icon': LucideIcons.arrowLeftRight},
      {'label': 'Repayment Alerts', 'icon': LucideIcons.bell},
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = _activeTab == index;
                final t = tabs[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166534) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF166534)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF166534).withValues(alpha: 0.22),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t['label'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Search Action Icon Button (Far Right)
        InkWell(
          onTap: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible;
              if (!_isSearchVisible) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isSearchVisible ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Icon(
                _isSearchVisible ? LucideIcons.x : LucideIcons.search,
                size: 16,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedSearchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search people, classification, phone or email...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. TAB CONTENT ROUTING
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabContent(double availableWidth, bool isMobile) {
    switch (_activeTab) {
      case 0:
        return _buildContactsTableCard(availableWidth);
      case 1:
        return _buildFinancialGroupsView(availableWidth, isMobile);
      case 2:
        return _buildRequestsView(availableWidth, isMobile);
      case 3:
        return _buildGlobalLedgerView(availableWidth, isMobile);
      case 4:
        return _buildRepaymentAlertsView(availableWidth, isMobile);
      default:
        return _buildContactsTableCard(availableWidth);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0: CONTACTS TABLE CARD (Matching Image 2 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContactsTableCard(double availableWidth) {
    final list = _filteredContacts;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Layout with horizontal scroll support for narrower screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: availableWidth >= 900 ? availableWidth - 64 : 880,
              ),
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                horizontalMargin: 20,
                columnSpacing: 24,
                dividerThickness: 1,
                border: const TableBorder(
                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
                columns: [
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('PROFILE CONTACT'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.arrowUpDown, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('CLASSIFICATION'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('COMPANY / LINK'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('PHONE / EMAIL'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('NET EXPOSURE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.arrowUpDown, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  const DataColumn(label: SizedBox(width: 24)),
                ],
                rows: list.map((c) {
                  final name = c['name'] as String;
                  final connected = c['connected'] == true;
                  final classification = c['classification'] as String;
                  final company = c['company'] as String;
                  final phone = c['phone'] as String;
                  final email = c['email'] as String;
                  final stand = (c['ledgerStand'] as num).toDouble();
                  final avatarBg = (c['avatarBg'] as Color?) ?? const Color(0xFFF1F5F9);
                  final avatarFg = (c['avatarColor'] as Color?) ?? const Color(0xFF475569);
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                  return DataRow(
                    cells: [
                      // 1. Profile Contact (Avatar + Name + ✓ Connected Badge)
                      DataCell(
                        InkWell(
                          onTap: () => setState(() => _selectedContactForDetail = c),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: avatarBg,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color: avatarFg,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (connected) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            LucideIcons.check,
                                            size: 11,
                                            color: Color(0xFF16A34A),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Connected',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF16A34A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 2. Classification Pill
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Soft Blue
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            classification.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      // 3. Company / Link
                      DataCell(
                        Text(
                          company,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 4. Phone / Email
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 5. Net Exposure (Amount + RECEIVABLE)
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${_fmt(stand)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'RECEIVABLE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 6. Action 3-dots Menu
                      DataCell(
                        PopupMenuButton<String>(
                          icon: const Icon(
                            LucideIcons.ellipsisVertical,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (val) {
                            if (val == 'ledger') {
                              setState(() => _selectedContactForDetail = c);
                            } else if (val == 'log') {
                              _openLogForSpecificContact(c);
                            } else if (val == 'delete') {
                              setState(() {
                                _contacts.removeWhere((item) => item['id'] == c['id']);
                              });
                              AppSnackbar.show(
                                context,
                                "Contact '$name' removed from registry",
                                type: SnackType.info,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'ledger',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.bookOpen, size: 14, color: Color(0xFF166534)),
                                  SizedBox(width: 8),
                                  Text('View Ledger', style: TextStyle(fontSize: 12.5)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'log',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.plus, size: 14, color: Color(0xFF2563EB)),
                                  SizedBox(width: 8),
                                  Text('Log Transaction', style: TextStyle(fontSize: 12.5)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                                  SizedBox(width: 8),
                                  Text('Delete Contact', style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: FINANCIAL GROUPS & SYNDICATES (Matching Images 3 & 4)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFinancialGroupsView(double availableWidth, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Sub-Action Row (+ New Financial Group & Search)
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _openNewGroupModal,
              icon: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
              label: const Text(
                'New Financial Group',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Main Financial Groups Card Container (Images 3 & 4)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
              // Header Row of the Container
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.walletCards,
                              color: Color(0xFF166534),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Financial Groups & Syndicates',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Collaborative ledgers, joint business pools, and shared credit circles with verified @bnxmail.com partners.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: _openNewGroupModal,
                    icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                    label: const Text(
                      'Create Group',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Group Cards List / Grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _financialGroups.map((grp) {
                  final targetPool = (grp['targetPool'] as num).toDouble();
                  final contributed = (grp['contributed'] as num).toDouble();
                  final expenses = (grp['expenses'] as num).toDouble();
                  final double pct = targetPool > 0
                      ? (contributed / targetPool).clamp(0.0, 1.0)
                      : 0.0;
                  final pctString = '${(pct * 100).toInt()}%';

                  return Container(
                    width: isMobile ? double.infinity : 360,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Top Row (Tag + 2 active)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF), // Purple Tint
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                grp['tag'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7C3AED),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.users,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${grp['activeMembers']} active',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title & Note
                        Text(
                          grp['name'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          grp['description'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Progress Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pool Goal (₹${_fmt(targetPool)})',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Text(
                              pctString,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Metrics Box (Contributed / Expenses)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CONTRIBUTED',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${_fmt(contributed)}',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'EXPENSES',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${_fmt(expenses)}',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons: Open Ledger & Trash
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openGroupLedgerModal(grp),
                                icon: const Icon(
                                  LucideIcons.bookOpen,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Open Ledger',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF166534),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _financialGroups.removeWhere((g) => g['id'] == grp['id']);
                                });
                                AppSnackbar.show(
                                  context,
                                  "Financial group '${grp['name']}' deleted",
                                  type: SnackType.info,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFEE2E2)),
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.trash2,
                                    size: 15,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OPEN GROUP LEDGER MODAL DIALOG (Matching Images 1 & 2 exactly with Zero Overflows)
  // ══════════════════════════════════════════════════════════════════════════
  void _openGroupLedgerModal(Map<String, dynamic> grp) {
    int subTab = 0; // 0: Net Balances, 1: Transactions, 2: Members

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final targetPool = (grp['targetPool'] as num).toDouble();
            final contributed = (grp['contributed'] as num).toDouble();
            final expenses = (grp['expenses'] as num).toDouble();
            final netFund = (grp['netFundInHand'] as num).toDouble();
            final toGive = (grp['toGivePrivate'] as num).toDouble();
            final members = (grp['members'] as List<dynamic>?) ?? [];
            final transactions = (grp['transactions'] as List<dynamic>?) ?? [];

            final screenWidth = MediaQuery.of(context).size.width;
            final modalWidth = screenWidth >= 960 ? 880.0 : (screenWidth - 32.0).clamp(320.0, 880.0);

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                width: modalWidth,
                constraints: const BoxConstraints(maxHeight: 700),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar (Dark Green - Matching Images 1, 2, 5)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF166534), // Forest Green
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.fileSpreadsheet,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        grp['name'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'PROJECT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    grp['description'] as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Header Action Buttons
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _openRecordGroupEntryModal(grp, () {
                                    setModalState(() {});
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                                label: const Text(
                                  'Record Entry',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _openInviteMemberModal(grp, () {
                                    setModalState(() {});
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(LucideIcons.userPlus, size: 13, color: Colors.white),
                                label: const Text(
                                  'Invite Member',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                icon: const Icon(LucideIcons.x, color: Colors.white, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Sub Tabs Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          _buildModalTabItem('Net Balances & Overview', LucideIcons.clock, subTab == 0, () {
                            setModalState(() => subTab = 0);
                          }),
                          const SizedBox(width: 20),
                          _buildModalTabItem('Transactions (${transactions.length})', LucideIcons.arrowLeftRight, subTab == 1, () {
                            setModalState(() => subTab = 1);
                          }),
                          const SizedBox(width: 20),
                          _buildModalTabItem('Members (${members.length})', LucideIcons.users, subTab == 2, () {
                            setModalState(() => subTab = 2);
                          }),
                        ],
                      ),
                    ),

                    // Body Scrollable Area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        child: subTab == 0
                            ? _buildModalOverviewTab(
                                contributed: contributed,
                                expenses: expenses,
                                netFund: netFund,
                                targetPool: targetPool,
                                toGive: toGive,
                                members: members,
                                onNoteToGiveTap: () {
                                  _openNoteToGiveModal(grp, () {
                                    setModalState(() {});
                                    setState(() {});
                                  });
                                },
                              )
                            : (subTab == 1
                                ? _buildModalTransactionsTab(transactions)
                                : _buildModalMembersTab(members)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalTabItem(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF166534) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOverviewTab({
    required double contributed,
    required double expenses,
    required double netFund,
    required double targetPool,
    required double toGive,
    required List<dynamic> members,
    required VoidCallback onNoteToGiveTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 KPI Summary Cards Row (Matching Images 1, 2, 5)
        Row(
          children: [
            Expanded(
              child: _buildModalStatCard(
                label: 'TOTAL CONTRIBUTED',
                value: '₹${_fmt(contributed)}',
                valueColor: const Color(0xFF15803D),
                borderColor: const Color(0xFF86EFAC),
                bgColor: const Color(0xFFF0FDF4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModalStatCard(
                label: 'TOTAL EXPENSES',
                value: '₹${_fmt(expenses)}',
                valueColor: const Color(0xFFDC2626),
                borderColor: const Color(0xFFFECDD3),
                bgColor: const Color(0xFFFEF2F2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModalStatCard(
                label: 'NET FUND IN HAND',
                value: '₹${_fmt(netFund)}',
                valueColor: const Color(0xFF2563EB),
                borderColor: const Color(0xFFBFDBFE),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModalStatCard(
                label: 'TARGET POOL',
                value: '₹${_fmt(targetPool)}',
                valueColor: const Color(0xFF1E293B),
                borderColor: const Color(0xFFE2E8F0),
                bgColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 5th Card Below: TO GIVE (PRIVATE)
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TO GIVE (PRIVATE)',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.lock, size: 9, color: Color(0xFF15803D)),
                        SizedBox(width: 2),
                        Text(
                          'Only You',
                          style: TextStyle(fontSize: 8.5, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '₹${_fmt(toGive)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF15803D),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Section: Member Financial Positions & Net Dues
        Row(
          children: const [
            Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF475569)),
            SizedBox(width: 8),
            Text(
              'Member Financial Positions & Net Dues',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Members Dues Table wrapped with horizontal scroll and safe flex widths
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 820),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(2.6),
                  1: FlexColumnWidth(1.8),
                  2: FlexColumnWidth(1.1),
                  3: FlexColumnWidth(1.3),
                  4: FlexColumnWidth(1.0),
                  5: FlexColumnWidth(1.3),
                  6: FlexColumnWidth(1.6),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: [
                      _buildTableHeadCell('Member'),
                      _buildTableHeadCell('Role / Status'),
                      _buildTableHeadCell('Total Paid'),
                      _buildTableHeadCell('Contributed'),
                      _buildTableHeadCell('Owed'),
                      _buildTableHeadCell('Net Balance'),
                      _buildTableHeadCell('🔒 Money to Give'),
                    ],
                  ),
                  // Member Rows
                  ...members.map((m) {
                    final net = (m['netBalance'] as num).toDouble();
                    final netStr = net >= 0 ? '+₹${_fmt(net)}' : '-₹${_fmt(net.abs())}';

                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      children: [
                        // 1. Member (Name + Email on 1 line with ellipsis)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m['name'] as String,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                m['email'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),

                        // 2. Role / Status (Wrap so it never overflows)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m['role'] as String,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m['status'] as String,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Total Paid
                        _buildTableTextCell('₹${_fmt((m['totalPaid'] as num).toDouble())}'),

                        // 4. Contributed
                        _buildTableTextCell('₹${_fmt((m['contributed'] as num).toDouble())}'),

                        // 5. Owed
                        _buildTableTextCell('₹${_fmt((m['owed'] as num).toDouble())}'),

                        // 6. Net Balance
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text(
                            netStr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),

                        // 7. + Note to Give button (FittedBox to prevent any wrap/overflow)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutlinedButton(
                                onPressed: onNoteToGiveTap,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF86EFAC)),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '+ Note to Give',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeadCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTableTextCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildModalStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalTransactionsTab(List<dynamic> txs) {
    if (txs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No group transactions logged yet.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }
    return Column(
      children: txs.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['type'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${t['member']} • ${t['date']} • ${t['memo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text(
                '₹${_fmt((t['amount'] as num).toDouble())}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF15803D)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModalMembersTab(List<dynamic> members) {
    return Column(
      children: members.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Text(
                      (m['name'] as String)[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(m['email'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (m['role'] as String).toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: REQUESTS VIEW (Matching Image 5 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRequestsView(double availableWidth, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // Header Row (Incoming Requests & Invitations + 0 Pending badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Incoming Requests & Invitations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Contact connections and financial group invitations sent to your @bnxmail.com address.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft Blue
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '0 Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Sub-heading: Direct Contact Requests (0)
          Row(
            children: const [
              Icon(LucideIcons.userPlus, size: 15, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text(
                'Direct Contact Requests (0)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Empty State Box (Matching Image 5)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.userPlus,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Pending Requests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'When someone adds your @bnxmail.com address or invites you to a financial group, you can accept or decline here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: GLOBAL LEDGER VIEW (Matching Image 1)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGlobalLedgerView(double availableWidth, bool isMobile) {
    final list = _allGlobalTransactions;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.arrowLeftRight,
        title: 'Zero Transactions Recorded',
        subtitle: _searchQuery.isNotEmpty
            ? 'No transaction matches your search query.'
            : 'Log your first friendly loan or advance transaction.',
        actionLabel: 'Log Transaction',
        onAction: () => _openGeneralLogModal(isMobile),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: availableWidth >= 900 ? availableWidth - 64 : 880,
          ),
          child: DataTable(
            headingRowHeight: 48,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 64,
            horizontalMargin: 20,
            columnSpacing: 28,
            dividerThickness: 1,
            border: const TableBorder(
              bottom: BorderSide(color: Color(0xFFF1F5F9)),
            ),
            headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
            columns: [
              DataColumn(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('EXECUTION DATE'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('NETWORK CONTACT'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('ACTIVITY DESCRIPTION'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('CLASSIFICATION'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('LEDGER FLOW'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              const DataColumn(
                label: Text(''),
              ),
            ],
            rows: list.map((tx) {
              final isLent = tx['isLent'] == true;
              final classification = (tx['classification'] as String? ?? (isLent ? 'LENT' : 'BORROWED')).toUpperCase();
              final flowSign = isLent ? '+' : '-';
              final flowColor = isLent ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
              final amt = (tx['amount'] as num).toDouble();

              return DataRow(
                cells: [
                  // 1. EXECUTION DATE
                  DataCell(
                    Text(
                      tx['date'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),

                  // 2. NETWORK CONTACT
                  DataCell(
                    Text(
                      tx['contactName'] as String? ?? 'Peer Contact',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // 3. ACTIVITY DESCRIPTION
                  DataCell(
                    Text(
                      tx['memo'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),

                  // 4. CLASSIFICATION (soft mint pill badge with LENT in green)
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        classification,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // 5. LEDGER FLOW (+₹20,000 in green)
                  DataCell(
                    Text(
                      '$flowSign₹${_fmt(amt)}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: flowColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),

                  // 6. Action: Delete Trash
                  DataCell(
                    IconButton(
                      onPressed: () => _confirmDeleteTransaction(tx),
                      icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFF94A3B8)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: REPAYMENT ALERTS VIEW (Matching Image 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRepaymentAlertsView(double availableWidth, bool isMobile) {
    final list = _allRepaymentAlerts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Action Row: Search Icon button + Dispatch Alert Button (Matching Image 2)
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _openDispatchAlertModal(isMobile),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.bell, size: 14, color: Color(0xFF065F46)),
                    SizedBox(width: 6),
                    Text(
                      'Dispatch Alert',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (list.isEmpty)
          _buildEmptyState(
            icon: LucideIcons.bellRing,
            title: 'Zero Pending Repayment Alerts',
            subtitle: _searchQuery.isNotEmpty
                ? 'No alert matched your search keyword.'
                : 'Set repayment maturity alerts to receive scheduled reminder prompts.',
            actionLabel: 'Dispatch Alert',
            onAction: () => _openDispatchAlertModal(isMobile),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: availableWidth >= 900 ? availableWidth - 64 : 880,
                ),
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  horizontalMargin: 20,
                  columnSpacing: 28,
                  dividerThickness: 1,
                  border: const TableBorder(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                  columns: [
                    DataColumn(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('MATURITY / DUE DATE'),
                          SizedBox(width: 4),
                          Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    DataColumn(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('TARGET CONTACT'),
                          SizedBox(width: 4),
                          Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    DataColumn(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('MEMO LABEL'),
                          SizedBox(width: 4),
                          Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    DataColumn(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('CLAIM CAP'),
                          SizedBox(width: 4),
                          Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    const DataColumn(
                      label: Text(''),
                    ),
                  ],
                  rows: list.map((alert) {
                    final amt = (alert['amount'] as num).toDouble();
                    final contactName = alert['contactName'] as String? ?? 'Peer Contact';
                    final memo = alert['memo'] as String? ?? 'Repayment Reminder';
                    final date = alert['date'] as String? ?? '12/11/2026';

                    return DataRow(
                      cells: [
                        // 1. MATURITY / DUE DATE (Red calendar icon + red date)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.calendar, size: 14, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. TARGET CONTACT (Bold black text)
                        DataCell(
                          Text(
                            contactName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        // 3. MEMO LABEL
                        DataCell(
                          Text(
                            memo,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),

                        // 4. CLAIM CAP
                        DataCell(
                          Text(
                            '₹${_fmt(amt)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),

                        // 5. Actions: Send button + Trash icon + Circle check icon
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  AppSnackbar.show(
                                    context,
                                    "Payment reminder dispatched to '$contactName'!",
                                    type: SnackType.success,
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Send',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _confirmDeleteAlert(alert),
                                icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFF94A3B8)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _confirmSettleAlert(alert),
                                icon: const Icon(LucideIcons.circleCheck, size: 16, color: Color(0xFF10B981)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEDICATED CONTACT DETAIL / LEDGER SUB-VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContactDetailView(Map<String, dynamic> contact) {
    final stand = (contact['ledgerStand'] as num).toDouble();
    final transactions = contact['transactions'] as List<Map<String, dynamic>>;
    final standText = stand == 0
        ? '₹0 SETTLED'
        : (stand > 0 ? '+₹${_fmt(stand)} RECEIVABLE' : '-₹${_fmt(stand.abs())} PAYABLE');
    final standColor = stand == 0
        ? const Color(0xFF64748B)
        : (stand > 0 ? const Color(0xFF059669) : const Color(0xFFEF4444));

    final totalLent = transactions
        .where((t) => t['isLent'] == true)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
    final totalBorrowed = transactions
        .where((t) => t['isLent'] == false)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF111827), size: 20),
          onPressed: () => setState(() => _selectedContactForDetail = null),
        ),
        title: Text(
          '${contact['name']} • Ledger',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: Color(0xFF166534), size: 20),
            tooltip: 'Log Transaction',
            onPressed: () => _openLogForSpecificContact(contact),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Profile Overview Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: (contact['avatarBg'] as Color?) ?? const Color(0xFFDCFCE7),
                            child: Text(
                              (contact['name'] as String).isNotEmpty
                                  ? (contact['name'] as String)[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: (contact['avatarColor'] as Color?) ?? const Color(0xFF166534),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact['name'] as String,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${contact['company']} • ${contact['phone']}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  contact['email'] as String? ?? 'No email',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL LENT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text('+₹${_fmt(totalLent)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL BORROWED', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text('-₹${_fmt(totalBorrowed)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('NET STANDING', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(standText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: standColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions (${transactions.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openLogForSpecificContact(contact),
                      icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                      label: const Text('Add Entry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transactions List
                if (transactions.isEmpty)
                  _buildEmptyState(
                    icon: LucideIcons.bookOpen,
                    title: 'No Transactions for this Contact',
                    subtitle: 'Log your first friendly loan or advance entry above.',
                  )
                else
                  ...transactions.map((t) {
                    final isLent = t['isLent'] == true;
                    final color = isLent ? const Color(0xFF059669) : const Color(0xFFEF4444);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['memo'] as String? ?? 'Peer transfer', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Date: ${t['date']} • ${t['classification']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                          Text(
                            '${isLent ? '+' : '-'}₹${_fmt((t['amount'] as num).toDouble())}',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: color),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER MODALS & HANDLERS
  // ══════════════════════════════════════════════════════════════════════════
  void _openAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => EnrollContactDialog(
        onContactCreated: (newContact) {
          setState(() {
            _contacts.insert(0, {
              ...newContact,
              'connected': false,
              'avatarBg': const Color(0xFFD1FAE5),
              'avatarColor': const Color(0xFF059669),
              'ledgerStand': 0.0,
              'transactions': <Map<String, dynamic>>[],
              'repaymentAlerts': <Map<String, dynamic>>[],
            });
          });
          AppSnackbar.show(
            context,
            "Contact '${newContact['name']}' added to registry!",
            type: SnackType.success,
          );
        },
      ),
    );
  }

  void _openGeneralLogModal(bool isMobile) {
    final amountCtrl = TextEditingController();
    final memoCtrl = TextEditingController();
    String targetUser = _contacts.isNotEmpty ? _contacts.first['name'] : 'Select contact';
    String entryDirection = 'I Lent Assets / Money';
    DateTime selectedDate = DateTime.now();

    final userList = _contacts.map((c) => c['name'] as String).toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void submit() {
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (amt <= 0) {
                AppSnackbar.show(context, 'Please enter a valid amount greater than ₹0', type: SnackType.warning);
                return;
              }
              final isLent = entryDirection.contains('Lent');
              final memo = memoCtrl.text.trim().isEmpty ? 'Direct peer transfer' : memoCtrl.text.trim();

              if (_contacts.isNotEmpty) {
                final contact = _contacts.firstWhere(
                  (c) => (c['name'] as String).toLowerCase() == targetUser.toLowerCase(),
                  orElse: () => _contacts.first,
                );
                final stand = (contact['ledgerStand'] as num).toDouble();
                setState(() {
                  contact['ledgerStand'] = isLent ? stand + amt : stand - amt;
                  (contact['transactions'] as List<Map<String, dynamic>>).insert(0, {
                    'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
                    'isLent': isLent,
                    'amount': amt,
                    'date': '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    'memo': memo,
                    'classification': isLent ? 'LENT' : 'BORROWED',
                  });
                });
              }

              Navigator.pop(context);
              AppSnackbar.show(context, "Transaction of ₹${_fmt(amt)} logged for '$targetUser'!", type: SnackType.success);
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Record Peer Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 18)),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),

                    const Text('Target Contact', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1)), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: userList.contains(targetUser) ? targetUser : (userList.isNotEmpty ? userList.first : ''),
                          isExpanded: true,
                          items: userList.map((String item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12.5)))).toList(),
                          onChanged: (v) { if (v != null) setModalState(() => targetUser = v); },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Amount (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 5),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Memo / Notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 5),
                    TextField(
                      controller: memoCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Supply credit advance',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
                        child: const Text('Record Transaction'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openLogForSpecificContact(Map<String, dynamic> contact) {
    final amountCtrl = TextEditingController();
    final memoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Entry for ${contact['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: memoCtrl,
              decoration: const InputDecoration(labelText: 'Memo / Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (amt <= 0) return;
              final stand = (contact['ledgerStand'] as num).toDouble();
              setState(() {
                contact['ledgerStand'] = stand + amt;
                (contact['transactions'] as List<Map<String, dynamic>>).insert(0, {
                  'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
                  'isLent': true,
                  'amount': amt,
                  'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  'memo': memoCtrl.text.trim().isEmpty ? 'Direct peer transfer' : memoCtrl.text.trim(),
                  'classification': 'LENT',
                });
              });
              Navigator.pop(context);
              AppSnackbar.show(context, 'Transaction recorded successfully!', type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _openNewGroupModal() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetPoolCtrl = TextEditingController(text: '50000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Financial Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group Name', hintText: 'e.g. Project Syndicates')),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Shared capital pool')),
            const SizedBox(height: 10),
            TextField(controller: targetPoolCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Target Pool Goal (₹)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final target = double.tryParse(targetPoolCtrl.text.trim()) ?? 50000.0;
              setState(() {
                _financialGroups.add({
                  'id': 'grp_${DateTime.now().millisecondsSinceEpoch}',
                  'tag': 'PROJECT OUTLAYS',
                  'activeMembers': 1,
                  'name': name,
                  'description': descCtrl.text.trim().isEmpty ? 'Collaborative enterprise syndicate pool' : descCtrl.text.trim(),
                  'targetPool': target,
                  'contributed': 0.0,
                  'expenses': 0.0,
                  'netFundInHand': 0.0,
                  'toGivePrivate': 0.0,
                  'members': [
                    {
                      'name': 'ravinew2004',
                      'email': 'ravinew2004@bnxmail.com',
                      'role': 'admin',
                      'status': 'Active',
                      'totalPaid': 0.0,
                      'contributed': 0.0,
                      'owed': 0.0,
                      'netBalance': 0.0,
                    },
                  ],
                  'transactions': [],
                });
              });
              Navigator.pop(ctx);
              AppSnackbar.show(context, "Group '$name' created successfully!", type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECORD GROUP TRANSACTION MODAL (Matching Image 4 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  void _openRecordGroupEntryModal(Map<String, dynamic> grp, VoidCallback onDone) {
    String entryType = 'Group Expense';
    final amtCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General');
    DateTime selectedDate = DateTime(2026, 11, 16);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Group Transaction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 1: Entry Type & Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Entry Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: entryType,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: const [
                                      DropdownMenuItem(value: 'Group Expense', child: Text('Group Expense', style: TextStyle(fontSize: 12.5))),
                                      DropdownMenuItem(value: 'Pool Contribution', child: Text('Pool Contribution', style: TextStyle(fontSize: 12.5))),
                                      DropdownMenuItem(value: 'Vendor Payout', child: Text('Vendor Payout', style: TextStyle(fontSize: 12.5))),
                                      DropdownMenuItem(value: 'Partner Advance', child: Text('Partner Advance', style: TextStyle(fontSize: 12.5))),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => entryType = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Amount *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: amtCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 2: Title / Description *
                    const Text('Title / Description *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. Supplier Batch Payment or Initial Capital',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Category & Date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: categoryCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final p = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (p != null) {
                                    setModalState(() => selectedDate = p);
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                                      ),
                                      const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                              final desc = titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Group Transaction';
                              if (amt <= 0) {
                                AppSnackbar.show(context, 'Please enter a valid amount', type: SnackType.warning);
                                return;
                              }
                              final isContribution = entryType == 'Pool Contribution';
                              if (isContribution) {
                                grp['contributed'] = (grp['contributed'] as num).toDouble() + amt;
                                grp['netFundInHand'] = (grp['netFundInHand'] as num).toDouble() + amt;
                              } else {
                                grp['expenses'] = (grp['expenses'] as num).toDouble() + amt;
                                grp['netFundInHand'] = (grp['netFundInHand'] as num).toDouble() - amt;
                              }

                              (grp['transactions'] as List<dynamic>).insert(0, {
                                'id': 'gtx_${DateTime.now().millisecondsSinceEpoch}',
                                'date': '${selectedDate.day} Nov ${selectedDate.year}',
                                'member': 'ravinew2004',
                                'amount': amt,
                                'type': entryType,
                                'memo': desc,
                              });

                              Navigator.pop(ctx);
                              onDone();
                              AppSnackbar.show(context, 'Transaction saved successfully!', type: SnackType.success);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Save Entry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INVITE PARTNER TO GROUP MODAL (Matching Image 3 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  void _openInviteMemberModal(Map<String, dynamic> grp, VoidCallback onDone) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'Member (Can view ledger & contribute)';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Invite Partner to Group',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Partner Name
                    const Text(
                      'Partner Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. Ramesh Patel',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Partner Email
                    const Text(
                      'Partner @bnxmail.com Email *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'partner@bnxmail.com',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Only official @bnxmail.com accounts can receive financial invitations',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Assigned Access Role
                    const Text(
                      'Assigned Access Role',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(
                              value: 'Member (Can view ledger & contribute)',
                              child: Text('Member (Can view ledger & contribute)', style: TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                            ),
                            DropdownMenuItem(
                              value: 'Manager (Can manage group operations)',
                              child: Text('Manager (Can manage group operations)', style: TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                            ),
                            DropdownMenuItem(
                              value: 'Admin (Full ledger & pool control)',
                              child: Text('Admin (Full ledger & pool control)', style: TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setModalState(() => selectedRole = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final email = emailCtrl.text.trim();
                              final name = nameCtrl.text.trim().isNotEmpty
                                  ? nameCtrl.text.trim()
                                  : (email.isNotEmpty ? email.split('@').first : 'Partner');
                              if (email.isEmpty) {
                                AppSnackbar.show(context, 'Please enter a valid @bnxmail.com email', type: SnackType.warning);
                                return;
                              }
                              final roleShort = selectedRole.contains('Admin')
                                  ? 'admin'
                                  : (selectedRole.contains('Manager') ? 'manager' : 'member');
                              (grp['members'] as List<dynamic>).add({
                                'name': name,
                                'email': email,
                                'role': roleShort,
                                'status': 'Active',
                                'totalPaid': 0.0,
                                'contributed': 0.0,
                                'owed': 0.0,
                                'netBalance': 0.0,
                              });
                              grp['activeMembers'] = (grp['activeMembers'] as num).toInt() + 1;
                              Navigator.pop(ctx);
                              onDone();
                              AppSnackbar.show(context, "Invitation dispatched to '$email'!", type: SnackType.success);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Dispatch Invitation',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openNoteToGiveModal(Map<String, dynamic> grp, VoidCallback onDone) {
    final amtCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Private Note to Give', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amtCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Private Due Amount (₹)', hintText: 'Only visible to you'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
              grp['toGivePrivate'] = amt;
              Navigator.pop(ctx);
              onDone();
              AppSnackbar.show(context, 'Private due updated!', type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openDispatchAlertModal(bool isMobile) {
    String? selectedContact;
    final memoCtrl = TextEditingController();
    final claimCapCtrl = TextEditingController();
    DateTime selectedDate = DateTime(2026, 11, 16);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule Repayment Alert',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Target Contact *
                    const Text(
                      'Target Contact *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedContact,
                          hint: const Text(
                            'Select contact...',
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                          items: _contacts.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['name'] as String,
                              child: Text(
                                c['name'] as String,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setModalState(() => selectedContact = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row: Memo Label * & Claim Cap (₹)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Memo Label *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: memoCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Loan Repayment Due',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Claim Cap (₹)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: claimCapCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Maturity / Due Date *
                    const Text(
                      'Maturity / Due Date *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF0F172A)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bottom Solid Action: Dispatch Repayment Alert (Matching Image 3)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final target = selectedContact ?? (_contacts.isNotEmpty ? _contacts.first['name'] as String : 'kamesh');
                          final memo = memoCtrl.text.trim().isEmpty ? 'loan which is gave you 20iuiw' : memoCtrl.text.trim();
                          final amt = double.tryParse(claimCapCtrl.text.trim()) ?? 0.0;
                          final dateStr = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

                          final contact = _contacts.firstWhere(
                            (c) => c['name'] == target,
                            orElse: () => _contacts.first,
                          );
                          setState(() {
                            (contact['repaymentAlerts'] as List<Map<String, dynamic>>).insert(0, {
                              'id': 'alt_${DateTime.now().millisecondsSinceEpoch}',
                              'date': dateStr,
                              'memo': memo,
                              'amount': amt > 0 ? amt : 20000.0,
                              'status': 'Pending',
                            });
                          });

                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            "Repayment alert scheduled for '$target'!",
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Dispatch Repayment Alert',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTransaction(Map<String, dynamic> tx) {
    setState(() {
      for (var c in _contacts) {
        (c['transactions'] as List<Map<String, dynamic>>).removeWhere((t) => t['id'] == tx['id']);
      }
    });
    AppSnackbar.show(context, 'Transaction removed from ledger', type: SnackType.info);
  }

  void _confirmDeleteAlert(Map<String, dynamic> alert) {
    setState(() {
      for (var c in _contacts) {
        (c['repaymentAlerts'] as List<Map<String, dynamic>>).removeWhere((a) => a['id'] == alert['id']);
      }
    });
    AppSnackbar.show(context, 'Alert cleared', type: SnackType.info);
  }

  void _confirmSettleAlert(Map<String, dynamic> alert) {
    setState(() {
      for (var c in _contacts) {
        (c['repaymentAlerts'] as List<Map<String, dynamic>>).removeWhere((a) => a['id'] == alert['id']);
      }
    });
    AppSnackbar.show(context, 'Alert marked as settled & cleared!', type: SnackType.success);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 26),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), height: 1.35)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
              label: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Indian currency formatting helper: 500056 -> 5,00,056
  String _fmt(double val) {
    if (val == 0) return '0';
    final isNegative = val < 0;
    final clampedVal = val.abs() > 999999999999.99 ? 999999999999.99 : val.abs();
    final absVal = clampedVal.round();
    final s = absVal.toString();
    if (s.length <= 3) {
      return isNegative ? '-$s' : s;
    }
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    final result = '$formattedRest,$last3';
    return isNegative ? '-$result' : result;
  }
}
