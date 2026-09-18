import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/enroll_contact_dialog.dart';

class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  int _activeTab = 0; // 0: Active Directory, 1: Global Ledger, 2: Repayment Alerts
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Persistent Contacts List matching Screenshot 1
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': 'c_1',
      'name': 'knjdkfvn',
      'classification': 'FRIEND',
      'company': 'ajkdcnajdf',
      'phone': '+916374943436',
      'email': 'divyachannnn1234@gmail.com',
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
      return name.contains(q) || company.contains(q) || phone.contains(q) || email.contains(q) || cat.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _allGlobalTransactions {
    final List<Map<String, dynamic>> list = [];
    for (var c in _contacts) {
      final txs = c['transactions'] as List<Map<String, dynamic>>;
      for (var t in txs) {
        list.add({
          ...t,
          'contactName': c['name'],
          'classification': c['classification'],
        });
      }
    }
    return list;
  }

  List<Map<String, dynamic>> get _allRepaymentAlerts {
    final List<Map<String, dynamic>> list = [];
    for (var c in _contacts) {
      final alerts = c['repaymentAlerts'] as List<Map<String, dynamic>>;
      for (var a in alerts) {
        list.add({
          ...a,
          'contactName': c['name'],
        });
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final paddingVal = isMobile ? 14.0 : 32.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Summary (Gradient Stats & Actions)
            _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            SizedBox(height: isMobile ? 14 : 28),

            // Tabs and Actions Row
            _buildNetworkTabsRow(isMobile).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            SizedBox(height: isMobile ? 14 : 20),

            // Tab View Content
            _buildTabContent(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final netBalance = _netReceivables - _netPayables;

    final logButton = ElevatedButton.icon(
      onPressed: () => _openGeneralLogModal(isMobile),
      icon: const Icon(LucideIcons.repeat, size: 14),
      label: const Text('Log Tx', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F5B2E),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    final addContactButton = ElevatedButton.icon(
      onPressed: _openAddContactDialog,
      icon: const Icon(LucideIcons.userPlus, size: 14),
      label: const Text('Add Contact', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F5B2E), Color(0xFF1A7A42), Color(0xFF22905A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5B2E).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL OUTSTANDING',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_fmt(netBalance.abs())}',
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
              if (!isMobile)
                Row(
                  children: [
                    logButton,
                    const SizedBox(width: 8),
                    addContactButton,
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(child: logButton),
                const SizedBox(width: 8),
                Expanded(child: addContactButton),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Contacts', '$_totalContacts', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Receivables', '₹${_fmt(_netReceivables)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Payables', '₹${_fmt(_netPayables)}', isMobile),
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
  void _openAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => EnrollContactDialog(
        onContactCreated: (newContact) {
          setState(() {
            _contacts.add(newContact);
          });
          AppSnackbar.show(
            context,
            "Contact '${newContact['name']}' enrolled successfully!",
            type: SnackType.success,
          );
        },
      ),
    );
  }

  Widget _buildNetworkTabsRow(bool isMobile) {
    final tabs = ['Active Directory', 'Global Ledger', 'Repayment Alerts'];
    final icons = [LucideIcons.users, LucideIcons.repeat, LucideIcons.bell];

    final tabsRow = SingleChildScrollView(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[index], size: 14, color: isSelected ? Colors.white : AppColors.secondaryText),
                    const SizedBox(width: 6),
                    Text(
                      tabs[index],
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

    final searchBar = Container(
      width: isMobile ? double.infinity : 260,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, color: AppColors.secondaryText, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search people, notes...',
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(LucideIcons.x, size: 14, color: AppColors.secondaryText),
            ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tabsRow,
          const SizedBox(height: 12),
          searchBar,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: tabsRow),
        const SizedBox(width: 16),
        searchBar,
      ],
    );
  }

  Widget _buildTabContent(bool isMobile) {
    if (_activeTab == 0) {
      return _buildActiveDirectoryView(isMobile);
    } else if (_activeTab == 1) {
      return _buildGlobalLedgerView(isMobile);
    } else {
      return _buildRepaymentAlertsView(isMobile);
    }
  }

  Widget _buildActiveDirectoryView(bool isMobile) {
    if (_filteredContacts.isEmpty) {
      return _buildEmptyCard('Zero network contacts found. Start adding people!', LucideIcons.userPlus);
    }

    return Column(
      children: _filteredContacts.map((contact) {
        final stand = (contact['ledgerStand'] as num).toDouble();
        final standText = stand == 0
            ? '₹0 RECEIVABLE'
            : (stand > 0 ? '₹${_fmt(stand)} RECEIVABLE' : '₹${_fmt(stand.abs())} PAYABLE');
        final standColor = stand == 0
            ? const Color(0xFF059669)
            : (stand > 0 ? const Color(0xFF059669) : const Color(0xFFEF4444));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: InkWell(
            onTap: () => _openContactLedgerModal(contact, isMobile),
            borderRadius: BorderRadius.circular(16),
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFD1FAE5),
                            child: Text(
                              (contact['name'] as String).isNotEmpty ? (contact['name'] as String)[0].toUpperCase() : 'C',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contact['name'] as String,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        contact['classification'] as String,
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${contact['company']} • ${contact['phone']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            standText,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: standColor),
                          ),
                          IconButton(
                            onPressed: () => _openContactLedgerModal(contact, isMobile),
                            icon: const Icon(LucideIcons.moreVertical, size: 16, color: AppColors.secondaryText),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFD1FAE5),
                        child: Text(
                          (contact['name'] as String).isNotEmpty ? (contact['name'] as String)[0].toUpperCase() : 'C',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Text(
                          contact['name'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              contact['classification'] as String,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          contact['company'] as String,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['phone'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                            Text(contact['email'] as String, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              standText,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: standColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openContactLedgerModal(contact, isMobile),
                        icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlobalLedgerView(bool isMobile) {
    final list = _allGlobalTransactions;
    if (list.isEmpty) {
      return _buildEmptyCard('No logged P2P activities found.', LucideIcons.repeat);
    }

    return Column(
      children: list.map((tx) {
        final isLent = tx['isLent'] == true;
        final color = isLent ? const Color(0xFF059669) : const Color(0xFFEF4444);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isLent ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['memo'] ?? 'P2P Transfer',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'With ${tx['contactName']} • ${tx['date']}',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              Text(
                '${isLent ? '+' : '-'}₹${_fmt((tx['amount'] as num).toDouble())}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRepaymentAlertsView(bool isMobile) {
    final list = _allRepaymentAlerts;
    if (list.isEmpty) {
      return _buildEmptyCard('Zero pending alerts scheduled.', LucideIcons.bell);
    }

    return Column(
      children: list.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bell, color: Color(0xFFD97706), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['purpose'] ?? 'Repayment Alert',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${alert['contactName']} • Due: ${alert['date']}',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${_fmt((alert['amount'] as num).toDouble())}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.hoverBackground, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.secondaryText, size: 36),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // CONTACT LEDGER STAND MODAL (Screenshots 2, 3, & 4)
  void _openContactLedgerModal(Map<String, dynamic> contact, bool isMobile) {
    int activeForm = 0; // 0: View Stand, 1: Record Tx Form, 2: Maturity Alarm Form

    // Form 1 Controllers (Record Tx)
    String direction = 'I Borrowed Money (-)';
    final amountCtrl = TextEditingController();
    final memoCtrl = TextEditingController(text: 'Registry note...');
    DateTime selectedTxDate = DateTime.now();

    // Form 2 Controllers (Set Maturity Alarm)
    final purposeCtrl = TextEditingController(text: 'Handloan Repayment Date');
    final expectedAmountCtrl = TextEditingController();
    DateTime selectedAlarmDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          final stand = (contact['ledgerStand'] as num).toDouble();
          final transactions = contact['transactions'] as List<Map<String, dynamic>>;
          final alerts = contact['repaymentAlerts'] as List<Map<String, dynamic>>;

          void submitTransaction() {
            final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
            final isLent = direction.contains('Lent');

            setState(() {
              contact['ledgerStand'] = isLent ? stand + amt : stand - amt;
              transactions.add({
                'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
                'isLent': isLent,
                'amount': amt,
                'date': '${selectedTxDate.day}-${selectedTxDate.month}-${selectedTxDate.year}',
                'memo': memoCtrl.text.trim().isEmpty ? 'P2P Transfer' : memoCtrl.text.trim(),
              });
            });

            AppSnackbar.show(
              context,
              "Transaction logged for '${contact['name']}'!",
              type: SnackType.success,
            );
            setModalState(() => activeForm = 0);
          }

          void submitAlarm() {
            final amt = double.tryParse(expectedAmountCtrl.text.trim()) ?? 0.0;

            setState(() {
              alerts.add({
                'id': 'alarm_${DateTime.now().millisecondsSinceEpoch}',
                'purpose': purposeCtrl.text.trim().isEmpty ? 'Repayment Alert' : purposeCtrl.text.trim(),
                'amount': amt,
                'date': '${selectedAlarmDate.day}-${selectedAlarmDate.month}-${selectedAlarmDate.year}',
              });
            });

            AppSnackbar.show(
              context,
              "Maturity alarm set for '${contact['name']}'!",
              type: SnackType.success,
            );
            setModalState(() => activeForm = 0);
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
              maxWidth: 580,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header Profile Banner
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFD1FAE5),
                        child: Text(
                          (contact['name'] as String).isNotEmpty ? (contact['name'] as String)[0].toUpperCase() : 'K',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  (contact['name'] as String).toUpperCase(),
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.darkText),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    contact['classification'] as String,
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${contact['company']} • ${contact['phone']} • ${contact['email']}',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AppSnackbar.show(context, "Sharing contact info...", type: SnackType.info);
                        },
                        icon: const Icon(LucideIcons.share2, size: 16, color: AppColors.secondaryText),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Consolidated Ledger Stand Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CONSOLIDATED LEDGER STAND',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF047857), letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_fmt(stand.abs())}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            stand >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                            color: stand >= 0 ? const Color(0xFF047857) : const Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // View Mode vs Form View
                  if (activeForm == 0) ...[
                    // Split Section: Direct Activity & Maturity Alerts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Direct Ledger Activity
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DIRECT LEDGER ACTIVITY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                const SizedBox(height: 10),
                                if (transactions.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: Text('Zero financial assets logged.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.secondaryText))),
                                  )
                                else
                                  ...transactions.map((tx) {
                                    final isLent = tx['isLent'] == true;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        '${isLent ? '+' : '-'}₹${tx['amount']} (${tx['date']})',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLent ? Colors.green : Colors.red),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Right: Maturity Due Alerts
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('MATURITY DUE ALERTS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                const SizedBox(height: 10),
                                if (alerts.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: Text('All accounts cleared.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.secondaryText))),
                                  )
                                else
                                  ...alerts.map((al) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        '🔔 ₹${al['amount']} (${al['date']})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons at Bottom
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setModalState(() => activeForm = 1),
                            icon: const Icon(LucideIcons.plus, size: 14),
                            label: const Text('Record Transaction', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: AppColors.darkText,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setModalState(() => activeForm = 2),
                            icon: const Icon(LucideIcons.bell, size: 14),
                            label: const Text('Set Maturity Due', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF3C7),
                              foregroundColor: const Color(0xFFD97706),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (activeForm == 1) ...[
                    // FORM 1: LOG NEW ENTRY
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('LOG NEW ENTRY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                              IconButton(
                                onPressed: () => setModalState(() => activeForm = 0),
                                icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('DIRECTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: direction,
                            items: ['I Borrowed Money (-)', 'I Lent Money (+)'].map((d) {
                              return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => direction = val);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('AMOUNT (₹)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: amountCtrl,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
                                    const Text('DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedTxDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null) {
                                          setModalState(() => selectedTxDate = picked);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${selectedTxDate.day}-${selectedTxDate.month}-${selectedTxDate.year}', style: const TextStyle(fontSize: 12)),
                                            const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('MEMO / NARRATIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: memoCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Registry note...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: submitTransaction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Submit Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: TextButton(
                              onPressed: () => setModalState(() => activeForm = 0),
                              child: const Text('Cancel Entry', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (activeForm == 2) ...[
                    // FORM 2: SET MATURITY ALARM
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('SET MATURITY ALARM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                              IconButton(
                                onPressed: () => setModalState(() => activeForm = 0),
                                icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('PURPOSE / DETAILS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                          const SizedBox(height: 4),
                          TextField(
                            controller: purposeCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'e.g. Handloan Repayment Date',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFDE68A))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('EXPECTED (₹)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: expectedAmountCtrl,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFDE68A))),
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
                                    const Text('DUE MATURITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedAlarmDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null) {
                                          setModalState(() => selectedAlarmDate = picked);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFFDE68A)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${selectedAlarmDate.day}-${selectedAlarmDate.month}-${selectedAlarmDate.year}', style: const TextStyle(fontSize: 12)),
                                            const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: submitAlarm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Enable Alarm 🔔', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: TextButton(
                              onPressed: () => setModalState(() => activeForm = 0),
                              child: const Text('Cancel Alarm', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _openGeneralLogModal(bool isMobile) {
    final amountCtrl = TextEditingController(text: '0.00');
    final memoCtrl = TextEditingController();
    String targetUser = _contacts.isNotEmpty ? _contacts.first['name'] : 'Select contact from registry...';
    String entryDirection = 'I Lent Assets / Money';
    DateTime selectedDate = DateTime.now();

    final userList = _contacts.map((c) => c['name'] as String).toList();
    if (!userList.contains('Select contact from registry...')) {
      userList.insert(0, 'Select contact from registry...');
    }

    final content = StatefulBuilder(builder: (context, setModalState) {
      void submit() {
        final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
        final isLent = entryDirection.contains('Lent');
        final memo = memoCtrl.text.trim().isEmpty ? 'Advance for marketing services' : memoCtrl.text.trim();

        if (_contacts.isNotEmpty) {
          final contact = _contacts.firstWhere(
            (c) => (c['name'] as String).toLowerCase() == targetUser.toLowerCase(),
            orElse: () => _contacts.first,
          );
          final stand = (contact['ledgerStand'] as num).toDouble();
          setState(() {
            contact['ledgerStand'] = isLent ? stand + amt : stand - amt;
            (contact['transactions'] as List<Map<String, dynamic>>).add({
              'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
              'isLent': isLent,
              'amount': amt,
              'date': '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
              'memo': memo,
            });
          });
        }

        Navigator.pop(context);
        AppSnackbar.show(
          context,
          "Peer transaction of ₹${amt.toInt()} authorized successfully!",
          type: SnackType.success,
        );
      }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Record Peer Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF084421)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),

            // Target Network User
            const Text('Target Network User', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5EAF4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: userList.contains(targetUser) ? targetUser : userList.first,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF5A7184)),
                  items: userList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 12, color: AppColors.darkText, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => targetUser = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Entry Direction (Left) & Ledger Date (Right)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Entry Direction', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5EAF4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: entryDirection,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF5A7184)),
                            items: ['I Lent Assets / Money', 'I Borrowed Assets / Money'].map((d) {
                              return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => entryDirection = v);
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
                      const Text('Ledger Date', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.5)),
                      const SizedBox(height: 4),
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
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5EAF4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}', style: const TextStyle(fontSize: 12)),
                              const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF5A7184)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Value Cap Amount (₹)
            const Text('Value Cap Amount (₹)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.5)),
            const SizedBox(height: 4),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF084421), width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),

            // Asset narrative / Memo
            const Text('Asset narrative / Memo', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.5)),
            const SizedBox(height: 4),
            TextField(
              controller: memoCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. , Advance for marketing services',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF084421), width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF084421),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Authorize Entry Log', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: content,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(width: 460, padding: const EdgeInsets.all(24), child: content),
        ),
      );
    }
  }

  String _fmt(double val) {
    return val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
