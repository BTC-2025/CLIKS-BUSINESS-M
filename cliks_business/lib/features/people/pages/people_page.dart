import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/enroll_contact_dialog.dart';

/// People Network & Escrow Page
/// Mobile-fit UI styled like TransactionPage with gradient hero summary,
/// clean segmented tabs, card-based records (NO tables), and zero reload issues.
class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  int _activeTab =
      0; // 0: Active Directory, 1: Global Ledger, 2: Repayment Alerts
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sub-page navigation: if non-null, shows full Contact Ldger detail view
  Map<String, dynamic>? _selectedContactForDetail;

  // Initial State populated with real data matching user screenshots
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': 'c_1',
      'name': 'Rahul tewatiya',
      'classification': 'FRIEND',
      'company': 'Tewatiya Corp',
      'phone': '+91 98765 43210',
      'email': 'rahul.t@example.com',
      'ledgerStand': 500056.0,
      'transactions': <Map<String, dynamic>>[
        {
          'id': 'tx_1',
          'isLent': true,
          'amount': 500000.0,
          'date': '18/9/2026',
          'memo': 'efnierfnijer',
          'classification': 'LENT',
        },
        {
          'id': 'tx_2',
          'isLent': true,
          'amount': 56.0,
          'date': '11/9/2026',
          'memo': 'Personal advance transfer',
          'classification': 'LENT',
        },
      ],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_2',
      'name': 'sridharan',
      'classification': 'CLIENT',
      'company': 'Sri Tech Solutions',
      'phone': '+91 98123 45678',
      'email': 'sridharan@example.com',
      'ledgerStand': 0.0,
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[
        {
          'id': 'alt_1',
          'date': '25/9/2026',
          'memo': 'new memo',
          'amount': 9000.0,
          'status': 'Pending',
        },
      ],
    },
    {
      'id': 'c_3',
      'name': 'Priya Sharma',
      'classification': 'VENDOR',
      'company': 'Sharma Logistics',
      'phone': '+91 91234 56789',
      'email': 'priya.s@example.com',
      'ledgerStand': 0.0,
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_4',
      'name': 'Amit Patel',
      'classification': 'FRIEND',
      'company': 'Patel Consulting',
      'phone': '+91 94567 89012',
      'email': 'amit.p@example.com',
      'ledgerStand': 0.0,
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
    {
      'id': 'c_5',
      'name': 'Vikram Singh',
      'classification': 'CLIENT',
      'company': 'Singh & Sons Corp',
      'phone': '+91 97890 12345',
      'email': 'vikram.s@example.com',
      'ledgerStand': 0.0,
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculated Real-Time Aggregates
  int get _totalContacts => _contacts.length;

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
      final classification = (t['classification'] as String? ?? '')
          .toLowerCase();
      return name.contains(q) ||
          memo.contains(q) ||
          date.contains(q) ||
          classification.contains(q);
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
      final memo = (a['memo'] as String? ?? a['purpose'] as String? ?? '')
          .toLowerCase();
      final date = (a['date'] as String? ?? '').toLowerCase();
      return name.contains(q) || memo.contains(q) || date.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedContactForDetail != null) {
      return _buildContactDetailView(_selectedContactForDetail!);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          paddingVal,
          isMobile ? 12 : 20,
          paddingVal,
          isMobile ? 100 : 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Summary Card (Gradient Card styled exactly like Transaction Page)
            isMacOS
                ? _buildHeroSummary(context, isMobile)
                : _buildHeroSummary(context, isMobile)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.04, end: 0),
            SizedBox(height: isMobile ? 14 : 24),

            // 2. Segment Tabs Row (Pills styled like Transaction Page)
            isMacOS
                ? _buildTabsRow(isMobile)
                : _buildTabsRow(isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms),
            SizedBox(height: isMobile ? 12 : 18),

            // 3. Search & Contextual Action Bar
            isMacOS
                ? _buildSearchBar(isMobile)
                : _buildSearchBar(isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 120.ms),
            SizedBox(height: isMobile ? 14 : 20),

            // 4. Card-Based Content Records (NO Tables)
            isMacOS
                ? _buildActiveContent(isMobile)
                : _buildActiveContent(isMobile)
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 160.ms),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Hero Summary (Gradient Card like Transaction Page, NO long wordings)
  // ===========================================================================
  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final logTxBtn = OutlinedButton.icon(
      onPressed: () => _openGeneralLogModal(isMobile),
      icon: const Icon(LucideIcons.repeat, size: 14),
      label: const Text(
        'Log Transaction',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final addContactBtn = ElevatedButton.icon(
      onPressed: _openAddContactDialog,
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text(
        'Add Contact',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.stylishDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    final actionsWidget = isMobile
        ? Row(
            children: [
              Expanded(child: logTxBtn),
              const SizedBox(width: 8),
              Expanded(child: addContactBtn),
            ],
          )
        : Row(children: [logTxBtn, const SizedBox(width: 8), addContactBtn]);

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
                      'NET RECEIVABLES',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.65),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹ ${_fmt(_netReceivables)}',
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) actionsWidget,
            ],
          ),
          if (isMobile) const SizedBox(height: 14),
          if (isMobile) actionsWidget,
          const SizedBox(height: 14),
          // 3 Stat Chips inside gradient
          Row(
            children: [
              _buildHeroChip('Total Contacts', '$_totalContacts', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip(
                'Receivables',
                '₹ ${_fmt(_netReceivables)}',
                isMobile,
              ),
              const SizedBox(width: 8),
              _buildHeroChip('Payables', '₹ ${_fmt(_netPayables)}', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 8 : 10,
        ),
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
                color: Colors.white.withValues(alpha: 0.6),
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

  // ===========================================================================
  // 2. Segment Tabs Row (Pills styled like Transaction Page)
  // ===========================================================================
  Widget _buildTabsRow(bool isMobile) {
    final tabs = [
      {
        'title': 'Active Directory',
        'count': _filteredContacts.length,
        'icon': LucideIcons.users,
      },
      {
        'title': 'Global Ledger',
        'count': _allGlobalTransactions.length,
        'icon': LucideIcons.repeat,
      },
      {
        'title': 'Repayment Alerts',
        'count': _allRepaymentAlerts.length,
        'icon': LucideIcons.bell,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTab == index;
          final tab = tabs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF166534) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF166534)
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF166534,
                            ).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 13,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.22)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${tab['count']}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
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

  // ===========================================================================
  // 3. Search & Contextual Action Bar
  // ===========================================================================
  Widget _buildSearchBar(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  color: Color(0xFF9CA3AF),
                  size: 15,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      LucideIcons.x,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_activeTab == 2) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openDispatchAlertModal(isMobile),
            icon: const Icon(LucideIcons.bell, size: 13, color: Colors.white),
            label: const Text(
              'Dispatch Alert',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // 4. Card-Based Content Records (NO Tables)
  // ===========================================================================
  Widget _buildActiveContent(bool isMobile) {
    if (_activeTab == 0) {
      return _buildActiveDirectoryCards(isMobile);
    } else if (_activeTab == 1) {
      return _buildGlobalLedgerCards(isMobile);
    } else {
      return _buildRepaymentAlertCards(isMobile);
    }
  }

  // ---------------------------------------------------------------------------
  // Tab 0: Active Directory Cards
  // ---------------------------------------------------------------------------
  Widget _buildActiveDirectoryCards(bool isMobile) {
    final list = _filteredContacts;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.userPlus,
        title: 'No Contacts Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'Try clearing your search keyword.'
            : 'Enrol your first peer contact to start logging transactions.',
        actionLabel: 'Add People Contact',
        onAction: _openAddContactDialog,
      );
    }

    return Column(
      children: list.map((contact) {
        final stand = (contact['ledgerStand'] as num).toDouble();
        final standText = stand == 0
            ? '₹0 SETTLED'
            : (stand > 0
                  ? '+₹${_fmt(stand)} RECEIVABLE'
                  : '-₹${_fmt(stand.abs())} PAYABLE');
        final standColor = stand == 0
            ? const Color(0xFF64748B)
            : (stand > 0 ? const Color(0xFF059669) : const Color(0xFFEF4444));
        final standBg = stand == 0
            ? const Color(0xFFF1F5F9)
            : (stand > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedContactForDetail = contact),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Name + Category + Stand Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFD1FAE5),
                        child: Text(
                          (contact['name'] as String).isNotEmpty
                              ? (contact['name'] as String)[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF047857),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    contact['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    (contact['classification'] as String? ??
                                            'PEER')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${contact['company']} • ${contact['phone']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: standBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: standColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          standText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: standColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 7),

                  // Bottom Action Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.mail,
                              size: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                contact['email'] as String? ?? 'No email',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _selectedContactForDetail = contact,
                            ),
                            icon: const Icon(
                              LucideIcons.bookOpen,
                              size: 12,
                              color: Color(0xFF0F5B2E),
                            ),
                            label: const Text(
                              'Ledger',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F5B2E),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Global Ledger Cards (Matches Screenshot 1 Data with Mobile Cards)
  // ---------------------------------------------------------------------------
  Widget _buildGlobalLedgerCards(bool isMobile) {
    final list = _allGlobalTransactions;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.repeat,
        title: 'Zero Transactions Recorded',
        subtitle: _searchQuery.isNotEmpty
            ? 'No transaction matches your search filter.'
            : 'Log your first friendly loan or advance transaction.',
        actionLabel: 'Log Transaction',
        onAction: () => _openGeneralLogModal(isMobile),
      );
    }

    return Column(
      children: list.map((tx) {
        final isLent = tx['isLent'] == true;
        final color = isLent
            ? const Color(0xFF059669)
            : const Color(0xFFEF4444);
        final bgColor = isLent
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEF2F2);
        final classification =
            (tx['classification'] as String? ?? (isLent ? 'LENT' : 'BORROWED'))
                .toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        isLent
                            ? LucideIcons.arrowUpRight
                            : LucideIcons.arrowDownLeft,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tx['contactName'] as String? ??
                                      'Peer Contact',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  classification,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tx['memo'] as String? ?? 'Peer transfer activity',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${isLent ? '+' : '-'}₹${_fmt((tx['amount'] as num).toDouble())}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 7),

                // Bottom Meta Row: Date + Delete Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Execution Date: ${tx['date']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _confirmDeleteTransaction(tx),
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                      tooltip: 'Delete Transaction',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Repayment Alert Cards (Matches Screenshot 2 Data with Mobile Cards)
  // ---------------------------------------------------------------------------
  Widget _buildRepaymentAlertCards(bool isMobile) {
    final list = _allRepaymentAlerts;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.bellRing,
        title: 'Zero Pending Repayment Alerts',
        subtitle: _searchQuery.isNotEmpty
            ? 'No alert matched your search keyword.'
            : 'Set repayment maturity alerts to receive scheduled reminder prompts.',
      );
    }

    return Column(
      children: list.map((alert) {
        final amt = (alert['amount'] as num).toDouble();
        final contactName = alert['contactName'] as String? ?? 'Peer Contact';
        final memo =
            alert['memo'] as String? ??
            alert['purpose'] as String? ??
            'Repayment Reminder';
        final date = alert['date'] as String? ?? '25/9/2026';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Bell Icon + Target Contact + Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        LucideIcons.bellRing,
                        color: Color(0xFFD97706),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  contactName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: const Text(
                                  'PENDING',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            memo,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '₹${_fmt(amt)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 7),

                // Bottom Action Buttons Strip (Send, Settle, Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 11,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Maturity: $date',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Send Reminder Action
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.send,
                                  size: 11,
                                  color: Color(0xFF059669),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Mark Settled
                        IconButton(
                          onPressed: () => _confirmSettleAlert(alert),
                          icon: const Icon(
                            LucideIcons.checkCircle,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          tooltip: 'Mark Settled',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        // Delete
                        IconButton(
                          onPressed: () => _confirmDeleteAlert(alert),
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                          tooltip: 'Delete Alert',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // 5. Dedicated Sub-Page Navigation: Contact Ledger View
  // ===========================================================================
  Widget _buildContactDetailView(Map<String, dynamic> contact) {
    final stand = (contact['ledgerStand'] as num).toDouble();
    final transactions = contact['transactions'] as List<Map<String, dynamic>>;
    final alerts = contact['repaymentAlerts'] as List<Map<String, dynamic>>;
    final standText = stand == 0
        ? '₹0 SETTLED'
        : (stand > 0
              ? '+₹${_fmt(stand)} RECEIVABLE'
              : '-₹${_fmt(stand.abs())} PAYABLE');
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
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: Color(0xFF111827),
            size: 20,
          ),
          onPressed: () => setState(() => _selectedContactForDetail = null),
        ),
        title: Text(
          '${contact['name']} • Ledger',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.plus,
              color: Color(0xFF0F5B2E),
              size: 20,
            ),
            tooltip: 'Log Transaction',
            onPressed: () => _openLogForSpecificContact(contact),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Profile Overview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFD1FAE5),
                            child: Text(
                              (contact['name'] as String).isNotEmpty
                                  ? (contact['name'] as String)[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${contact['company']} • ${contact['phone']}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  contact['email'] as String? ?? 'No email',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TOTAL LENT',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+₹${_fmt(totalLent)}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
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
                                  'TOTAL BORROWED',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '-₹${_fmt(totalBorrowed)}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'NET STANDING',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  standText,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: standColor,
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
                const SizedBox(height: 18),

                // Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions (${transactions.length})',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openLogForSpecificContact(contact),
                      icon: const Icon(
                        LucideIcons.plus,
                        size: 13,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Entry',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5B2E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Transactions List
                if (transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Center(
                      child: Text(
                        'No transactions recorded yet with this contact.',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: transactions.map((tx) {
                      final isLent = tx['isLent'] == true;
                      final color = isLent
                          ? const Color(0xFF059669)
                          : const Color(0xFFEF4444);
                      final bgColor = isLent
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isLent
                                    ? LucideIcons.arrowUpRight
                                    : LucideIcons.arrowDownLeft,
                                color: color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx['memo'] as String? ?? 'Peer transfer',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx['date'] as String? ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${isLent ? '+' : '-'}₹${_fmt((tx['amount'] as num).toDouble())}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  final amt = (tx['amount'] as num).toDouble();
                                  transactions.removeWhere(
                                    (item) => item['id'] == tx['id'],
                                  );
                                  contact['ledgerStand'] = isLent
                                      ? stand - amt
                                      : stand + amt;
                                });
                                AppSnackbar.show(
                                  context,
                                  'Transaction removed',
                                  type: SnackType.info,
                                );
                              },
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 14,
                                color: Color(0xFFEF4444),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Active Alerts (${alerts.length})',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: alerts.map((alt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alt['memo'] as String? ??
                                      'Repayment Reminder',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Due: ${alt['date']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${_fmt((alt['amount'] as num).toDouble())}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Empty State Widget
  // ===========================================================================
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
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5B2E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8.5,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // Modals & Action Handlers
  // ===========================================================================
  void _openAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => EnrollContactDialog(
        onContactCreated: (newContact) {
          setState(() {
            _contacts.insert(0, newContact);
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
    String targetUser = _contacts.isNotEmpty
        ? _contacts.first['name']
        : 'Select contact';
    String entryDirection = 'I Lent Assets / Money';
    DateTime selectedDate = DateTime.now();

    final userList = _contacts.map((c) => c['name'] as String).toList();

    final content = StatefulBuilder(
      builder: (context, setModalState) {
        void submit() {
          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
          if (amt <= 0) {
            AppSnackbar.show(
              context,
              'Please enter a valid amount greater than ₹0',
              type: SnackType.warning,
            );
            return;
          }
          if (amt > kMaxAllowedAmount) {
            AppSnackbar.show(
              context,
              'Amount cannot exceed $kMaxAllowedAmountText',
              type: SnackType.warning,
            );
            return;
          }
          final isLent = entryDirection.contains('Lent');
          final memo = memoCtrl.text.trim().isEmpty
              ? 'Direct peer transfer'
              : memoCtrl.text.trim();

          if (_contacts.isNotEmpty) {
            final contact = _contacts.firstWhere(
              (c) =>
                  (c['name'] as String).toLowerCase() ==
                  targetUser.toLowerCase(),
              orElse: () => _contacts.first,
            );
            final stand = (contact['ledgerStand'] as num).toDouble();
            setState(() {
              contact['ledgerStand'] = isLent ? stand + amt : stand - amt;
              (contact['transactions'] as List<Map<String, dynamic>>).insert(0, {
                'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
                'isLent': isLent,
                'amount': amt,
                'date':
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                'memo': memo,
                'classification': isLent ? 'LENT' : 'BORROWED',
              });
            });
          }

          Navigator.pop(context);
          AppSnackbar.show(
            context,
            "Transaction of ₹${_fmt(amt)} logged for '$targetUser'!",
            type: SnackType.success,
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Record Peer Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5B2E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),

              const Text(
                'Target Contact',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: userList.contains(targetUser)
                        ? targetUser
                        : (userList.isNotEmpty ? userList.first : ''),
                    isExpanded: true,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    items: userList.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => targetUser = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entry Direction',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: entryDirection,
                              isExpanded: true,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              items:
                                  [
                                    'I Lent Assets / Money',
                                    'I Borrowed Assets / Money',
                                  ].map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: const TextStyle(fontSize: 11.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => entryDirection = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                'Amount (₹)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  const CurrencyInputFormatter(
                    integerDigits: 12,
                    decimalDigits: 2,
                  ),
                  LengthLimitingTextInputFormatter(15),
                ],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 5000',
                  prefixIcon: const Icon(
                    LucideIcons.indianRupee,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F5B2E),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Memo / Description',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: memoCtrl,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Advance for inventory supplier',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F5B2E),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5B2E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Authorize Entry',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: content,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(22),
            child: content,
          ),
        ),
      );
    }
  }

  void _openLogForSpecificContact(Map<String, dynamic> contact) {
    final amountCtrl = TextEditingController();
    final memoCtrl = TextEditingController();
    String entryDirection = 'I Lent Assets / Money';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void submit() {
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (amt <= 0) {
                AppSnackbar.show(
                  context,
                  'Please enter a valid amount greater than ₹0',
                  type: SnackType.warning,
                );
                return;
              }
              if (amt > kMaxAllowedAmount) {
                AppSnackbar.show(
                  context,
                  'Amount cannot exceed $kMaxAllowedAmountText',
                  type: SnackType.warning,
                );
                return;
              }
              final isLent = entryDirection.contains('Lent');
              final memo = memoCtrl.text.trim().isEmpty
                  ? 'Direct peer transfer'
                  : memoCtrl.text.trim();
              final stand = (contact['ledgerStand'] as num).toDouble();

              setState(() {
                contact['ledgerStand'] = isLent ? stand + amt : stand - amt;
                (contact['transactions'] as List<Map<String, dynamic>>).insert(
                  0,
                  {
                    'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
                    'isLent': isLent,
                    'amount': amt,
                    'date':
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    'memo': memo,
                    'classification': isLent ? 'LENT' : 'BORROWED',
                  },
                );
              });

              Navigator.pop(context);
              AppSnackbar.show(
                context,
                "Transaction of ₹${_fmt(amt)} logged for '${contact['name']}'!",
                type: SnackType.success,
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entry for ${contact['name']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5B2E),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            LucideIcons.x,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Entry Direction',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: entryDirection,
                                    isExpanded: true,
                                    icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                    items:
                                        [
                                          'I Lent Assets / Money',
                                          'I Borrowed Assets / Money',
                                        ].map((d) {
                                          return DropdownMenuItem(
                                            value: d,
                                            child: Text(
                                              d,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => entryDirection = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const Icon(
                                        LucideIcons.calendar,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Amount (₹)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        const CurrencyInputFormatter(
                          integerDigits: 12,
                          decimalDigits: 2,
                        ),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000',
                        prefixIcon: const Icon(
                          LucideIcons.indianRupee,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F5B2E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Memo / Description',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: memoCtrl,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. Payment for invoice',
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F5B2E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5B2E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Record Transaction',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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

  void _openDispatchAlertModal(bool isMobile) {
    final amountCtrl = TextEditingController();
    final memoCtrl = TextEditingController();
    String targetUser = _contacts.isNotEmpty
        ? _contacts.first['name']
        : 'Select contact';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    final userList = _contacts.map((c) => c['name'] as String).toList();

    final content = StatefulBuilder(
      builder: (context, setModalState) {
        void submit() {
          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
          if (amt <= 0) {
            AppSnackbar.show(
              context,
              'Please enter a valid claim cap amount',
              type: SnackType.warning,
            );
            return;
          }
          if (amt > kMaxAllowedAmount) {
            AppSnackbar.show(
              context,
              'Amount cannot exceed $kMaxAllowedAmountText',
              type: SnackType.warning,
            );
            return;
          }
          final memo = memoCtrl.text.trim().isEmpty
              ? 'Repayment Due'
              : memoCtrl.text.trim();

          if (_contacts.isNotEmpty) {
            final contact = _contacts.firstWhere(
              (c) =>
                  (c['name'] as String).toLowerCase() ==
                  targetUser.toLowerCase(),
              orElse: () => _contacts.first,
            );
            setState(() {
              (contact['repaymentAlerts'] as List<Map<String, dynamic>>).insert(
                0,
                {
                  'id': 'alt_${DateTime.now().millisecondsSinceEpoch}',
                  'date':
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  'memo': memo,
                  'amount': amt,
                  'status': 'Pending',
                },
              );
            });
          }

          Navigator.pop(context);
          AppSnackbar.show(
            context,
            "Repayment alert set for '$targetUser' due on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}!",
            type: SnackType.success,
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dispatch Repayment Alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5B2E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),

              const Text(
                'Target Contact',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: userList.contains(targetUser)
                        ? targetUser
                        : (userList.isNotEmpty ? userList.first : ''),
                    isExpanded: true,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    items: userList.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => targetUser = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Claim Cap (₹)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            const CurrencyInputFormatter(
                              integerDigits: 12,
                              decimalDigits: 2,
                            ),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 9000',
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF0F5B2E),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maturity Due Date',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                'Memo Label / Notes',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: memoCtrl,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Expected loan repayment settlement',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F5B2E),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5B2E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Schedule Repayment Alert',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: content,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(22),
            child: content,
          ),
        ),
      );
    }
  }

  void _confirmDeleteTransaction(Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Transaction?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete this transaction of ₹${_fmt((tx['amount'] as num).toDouble())}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final isLent = tx['isLent'] == true;
                final amt = (tx['amount'] as num).toDouble();
                for (var c in _contacts) {
                  final list = c['transactions'] as List<Map<String, dynamic>>;
                  final idx = list.indexWhere((item) => item['id'] == tx['id']);
                  if (idx != -1) {
                    list.removeAt(idx);
                    final stand = (c['ledgerStand'] as num).toDouble();
                    c['ledgerStand'] = isLent ? stand - amt : stand + amt;
                    break;
                  }
                }
              });
              AppSnackbar.show(
                context,
                'Transaction removed and balance recalculated',
                type: SnackType.info,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlert(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Repayment Alert?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Delete alert for '${alert['contactName']}' of ₹${_fmt((alert['amount'] as num).toDouble())}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (var c in _contacts) {
                  final list =
                      c['repaymentAlerts'] as List<Map<String, dynamic>>;
                  list.removeWhere((item) => item['id'] == alert['id']);
                }
              });
              AppSnackbar.show(
                context,
                'Repayment alert deleted',
                type: SnackType.info,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSettleAlert(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Mark Alert as Settled?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Confirm receipt/settlement of ₹${_fmt((alert['amount'] as num).toDouble())} from '${alert['contactName']}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (var c in _contacts) {
                  final list =
                      c['repaymentAlerts'] as List<Map<String, dynamic>>;
                  list.removeWhere((item) => item['id'] == alert['id']);
                }
              });
              AppSnackbar.show(
                context,
                'Alert marked as settled & cleared!',
                type: SnackType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              elevation: 0,
            ),
            child: const Text(
              'Settle',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indian currency formatting helper: 500056 -> 5,00,056
  String _fmt(double val) {
    if (val == 0) return '0';
    final isNegative = val < 0;
    final clampedVal =
        val.abs() > 999999999999.99 ? 999999999999.99 : val.abs();
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
