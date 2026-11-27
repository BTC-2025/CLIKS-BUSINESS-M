import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../data/models/people_models.dart';
import '../providers/people_providers.dart';
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
  // 0: Contacts, 1: Financial Groups, 2: Requests, 3: Global Ledger, 4: Repayment Alerts
  int _activeTab = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  // Sub-page navigation: if non-null, shows full Contact Ledger detail view
  PersonContact? _selectedContactForDetail;

  @override
  void initState() {
    super.initState();
    // Load live data from the backend APIs on page initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(peopleProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILTERED GETTERS FROM RIVERPOD LIVE STATE
  // ══════════════════════════════════════════════════════════════════════════

  List<PersonContact> _getFilteredContacts(List<PersonContact> contacts) {
    if (_searchQuery.trim().isEmpty) return contacts;
    final q = _searchQuery.toLowerCase();
    return contacts.where((c) {
      final name = c.name.toLowerCase();
      final company = (c.company ?? '').toLowerCase();
      final phone = c.phone.toLowerCase();
      final email = c.email.toLowerCase();
      final cat = c.classification.toLowerCase();
      final role = c.roleType.toLowerCase();
      return name.contains(q) ||
          company.contains(q) ||
          phone.contains(q) ||
          email.contains(q) ||
          cat.contains(q) ||
          role.contains(q);
    }).toList();
  }

  List<PersonTransaction> _getFilteredTransactions(List<PersonTransaction> txs) {
    if (_searchQuery.trim().isEmpty) return txs;
    final q = _searchQuery.toLowerCase();
    return txs.where((t) {
      final name = t.personName.toLowerCase();
      final memo = (t.notes ?? '').toLowerCase();
      final date = t.date.toLowerCase();
      final type = t.type.toLowerCase();
      return name.contains(q) || memo.contains(q) || date.contains(q) || type.contains(q);
    }).toList();
  }

  List<RepaymentAlert> _getFilteredAlerts(List<RepaymentAlert> alerts) {
    if (_searchQuery.trim().isEmpty) return alerts;
    final q = _searchQuery.toLowerCase();
    return alerts.where((a) {
      final name = a.targetContact.toLowerCase();
      final memo = a.memoLabel.toLowerCase();
      final date = a.maturityDate.toLowerCase();
      final status = a.status.toLowerCase();
      return name.contains(q) || memo.contains(q) || date.contains(q) || status.contains(q);
    }).toList();
  }

  List<FinancialGroup> _getFilteredGroups(List<FinancialGroup> groups) {
    if (_searchQuery.trim().isEmpty) return groups;
    final q = _searchQuery.toLowerCase();
    return groups.where((g) {
      final name = g.name.toLowerCase();
      final desc = (g.description ?? '').toLowerCase();
      final tag = g.groupType.toLowerCase();
      return name.contains(q) || desc.contains(q) || tag.contains(q);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final peopleState = ref.watch(peopleProvider);

    if (_selectedContactForDetail != null) {
      return _buildContactDetailView(_selectedContactForDetail!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 850;
        final groupInvs = peopleState.groups.where((g) => g.isPendingInvitation).toList();
        final directReqs = peopleState.incomingRequests;
        final double horizontalPadding = availableWidth >= 1200
            ? 32.0
            : (availableWidth >= 800 ? 24.0 : 16.0);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.read(peopleProvider.notifier).loadAll(isRefresh: true),
              color: const Color(0xFF166534),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    _buildHeaderRow(context, isMobile, peopleState),
                    const SizedBox(height: 22),

                    // 2. Top Metric KPI Cards (TO RECEIVE / TO PAY)
                    _buildTopMetricsRow(availableWidth, peopleState),
                    const SizedBox(height: 20),

                    // Pending Invitations Banner (Matching Image 1, 2, 3)
                    if (groupInvs.isNotEmpty || directReqs.isNotEmpty) ...[
                      _buildPendingInvitationsBanner(directReqs, groupInvs, isMobile),
                      const SizedBox(height: 20),
                    ],

                    // 3. Segmented Tabs Row + Search Icon Button
                    _buildTabsRow(isMobile, peopleState),
                    const SizedBox(height: 18),

                    // Search Bar if expanded
                    if (_isSearchVisible) ...[
                      _buildExpandedSearchBar(),
                      const SizedBox(height: 14),
                    ],

                    // Global Error Notification Banner (if any)
                    if (peopleState.errorMessage != null &&
                        peopleState.contacts.isEmpty &&
                        !peopleState.isLoading) ...[
                      _buildErrorBanner(peopleState.errorMessage!),
                      const SizedBox(height: 14),
                    ],

                    // 4. Tab Content Body
                    if (peopleState.isLoading && peopleState.contacts.isEmpty)
                      _buildLoadingIndicator()
                    else
                      _buildTabContent(availableWidth, isMobile, peopleState),
                  ],
                ),
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
  Widget _buildHeaderRow(BuildContext context, bool isMobile, PeopleState state) {
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
  // 2. TOP METRICS ROW (Matching Image 2 - Dynamic Backend Values)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopMetricsRow(double availableWidth, PeopleState state) {
    final summary = state.summary;
    final toReceive = summary.totalReceivables;
    final toPay = summary.totalPayables;
    final totalLent = summary.totalLent > 0 ? summary.totalLent : toReceive;
    final totalBorrowed = summary.totalBorrowed > 0 ? summary.totalBorrowed : toPay;
    final received = (totalLent - toReceive).clamp(0.0, totalLent);
    final paid = (totalBorrowed - toPay).clamp(0.0, totalBorrowed);

    final cardReceive = _buildKpiCard(
      label: 'TO RECEIVE',
      badgeText: '${summary.collectionPercentage.toStringAsFixed(0)}% Collected',
      badgeBg: const Color(0xFFDCFCE7),
      badgeFg: const Color(0xFF15803D),
      amount: '₹${_fmt(toReceive)}',
      totalText: 'Total: ₹${_fmt(totalLent)}',
      subText: 'Received: ₹${_fmt(received)}',
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
      badgeText: '${summary.settlementPercentage.toStringAsFixed(0)}% Settled',
      badgeBg: const Color(0xFFFEE2E2),
      badgeFg: const Color(0xFFDC2626),
      amount: '₹${_fmt(toPay)}',
      totalText: 'Total: ₹${_fmt(totalBorrowed)}',
      subText: 'Paid: ₹${_fmt(paid)}',
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
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: subColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENDING INVITATIONS BANNER (Matching Image 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPendingInvitationsBanner(
    List<ConnectionRequest> requests,
    List<FinancialGroup> groupInvitations,
    bool isMobile,
  ) {
    if (requests.isEmpty && groupInvitations.isEmpty) return const SizedBox.shrink();

    final totalCount = requests.length + groupInvitations.length;
    final String subtitle;
    if (groupInvitations.isNotEmpty && requests.isEmpty) {
      subtitle = '${groupInvitations.length} financial group invitation(s) sent to your @bnxmail.com address.';
    } else if (requests.isNotEmpty && groupInvitations.isEmpty) {
      subtitle = '${requests.length} contact request(s) sent to your @bnxmail.com address.';
    } else {
      subtitle = '$totalCount invitation(s) sent to your @bnxmail.com address.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF), // Soft pleasant light blue tint from Image 2
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.userPlus,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Invitations ($totalCount)',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _activeTab = 2; // Switch to Requests Tab
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Review All ($totalCount)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Group Invitations cards inside banner (Matching Image 1 & 3)
          ...groupInvitations.map((grp) {
            final inviter = grp.invitedByName ?? (grp.members.isNotEmpty ? grp.members.first.name : 'Partner');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5), // Indigo matching Image 1
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.walletCards,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          grp.groupType.isEmpty ? grp.name : grp.groupType,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Invited by $inviter',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(peopleProvider.notifier).joinFinancialGroup(grp.id);
                        if (mounted) {
                          AppSnackbar.show(context, "Joined '${grp.name}' group successfully!", type: SnackType.success);
                        }
                      } catch (e) {
                        if (mounted) {
                          AppSnackbar.show(context, e.toString(), type: SnackType.error);
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                    label: const Text(
                      'Join',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), // Purple/indigo matching Image 1
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(peopleProvider.notifier).declineFinancialGroup(grp.id);
                        if (mounted) {
                          AppSnackbar.show(context, "Declined invitation to '${grp.name}'", type: SnackType.info);
                        }
                      } catch (e) {
                        if (mounted) {
                          AppSnackbar.show(context, e.toString(), type: SnackType.error);
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.0),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Request cards inside banner
          ...requests.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF), // Deep Blue from screenshot
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        req.fromName.isNotEmpty ? req.fromName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          req.fromName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          req.fromEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _handleRespondRequest(req, 'accept'),
                    icon: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                    label: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _handleRespondRequest(req, 'reject'),
                    icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.0),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handleRespondRequest(ConnectionRequest req, String action) async {
    try {
      final success = await ref
          .read(peopleProvider.notifier)
          .respondConnectionRequest(req.id, action);
      if (success && mounted) {
        if (action == 'accept') {
          AppSnackbar.show(
            context,
            "Connected with ${req.fromName}!",
            type: SnackType.success,
          );
        } else {
          AppSnackbar.show(
            context,
            "Declined connection request",
            type: SnackType.info,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
          type: SnackType.error,
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. SEGMENTED TABS ROW + SEARCH BUTTON (Matching Image 1, 2, 3)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabsRow(bool isMobile, PeopleState state) {
    final groupInvitations = state.groups.where((g) => g.isPendingInvitation).toList();
    final totalPendingCount = groupInvitations.length + state.incomingRequests.length;

    final tabs = [
      const _TabDef(
        title: 'Contacts',
        icon: LucideIcons.user,
      ),
      _TabDef(
        title: state.groups.isNotEmpty ? 'Financial Groups (${state.groups.length})' : 'Financial Groups',
        icon: LucideIcons.walletCards,
      ),
      _TabDef(
        title: totalPendingCount > 0 ? 'Requests ($totalPendingCount)' : 'Requests',
        icon: LucideIcons.userPlus,
        hasNotificationBadge: totalPendingCount > 0,
      ),
      const _TabDef(
        title: 'Global Ledger',
        icon: LucideIcons.arrowLeftRight,
      ),
      const _TabDef(
        title: 'Repayment Alerts',
        icon: LucideIcons.bell,
      ),
    ];

    final tabsListWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (idx) {
          final t = tabs[idx];
          final isSelected = _activeTab == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeTab = idx;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9.5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF166534) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x20166534),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.icon,
                      size: 14.5,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      t.title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (t.hasNotificationBadge) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626), // Red notification dot from Image 2
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );

    // Search Toggle Button (Matching Image 1, 2, 3)
    final searchButton = InkWell(
      onTap: () {
        setState(() {
          _isSearchVisible = !_isSearchVisible;
          if (!_isSearchVisible) {
            _searchQuery = '';
            _searchController.clear();
          }
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
        child: Center(
          child: Icon(
            _isSearchVisible ? LucideIcons.x : LucideIcons.search,
            size: 16,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tabsListWidget,
          const SizedBox(height: 8),
          searchButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: tabsListWidget),
        const SizedBox(width: 12),
        searchButton,
      ],
    );
  }

  Widget _buildExpandedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Search people, groups, alerts, or ledger records...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(peopleProvider.notifier).loadAll(),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF166534)),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. TAB CONTENT ROUTING
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabContent(double availableWidth, bool isMobile, PeopleState state) {
    switch (_activeTab) {
      case 0:
        return _buildContactsTableCard(availableWidth, state);
      case 1:
        return _buildFinancialGroupsView(availableWidth, isMobile, state);
      case 2:
        return _buildRequestsView(availableWidth, isMobile, state);
      case 3:
        return _buildGlobalLedgerView(availableWidth, isMobile, state);
      case 4:
        return _buildRepaymentAlertsView(availableWidth, isMobile, state);
      default:
        return _buildContactsTableCard(availableWidth, state);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0: CONTACTS TABLE CARD (Matching Image 2 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContactsTableCard(double availableWidth, PeopleState state) {
    final list = _getFilteredContacts(state.contacts);

    if (list.isEmpty) {
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: availableWidth >= 900 ? availableWidth - 64 : 880,
                ),
                child: DataTable(
                  headingRowHeight: 48,
                  horizontalMargin: 20,
                  columnSpacing: 24,
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
                  rows: const [],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              alignment: Alignment.center,
              child: Text(
                _searchQuery.isNotEmpty
                    ? "No contact matches '$_searchQuery'. Try clearing the search."
                    : 'Zero network contacts found. Start adding!',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
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
                  final name = c.name;
                  final connected = c.isConnected;
                  final classification = c.classification;
                  final company = (c.company != null && c.company!.isNotEmpty) ? c.company! : (c.displayCompany != '-' ? c.displayCompany : 'Individual');
                  final phone = c.formattedPhone;
                  final email = c.email;
                  final stand = c.netBalance;
                  final avatarBg = c.avatarBg;
                  final avatarFg = c.avatarColor;
                  final initial = c.initials;

                  final exposureColor = stand < 0 ? const Color(0xFFDC2626) : const Color(0xFF15803D);
                  final exposureLabel = stand < 0 ? 'PAYABLE' : 'RECEIVABLE';

                  return DataRow(
                    cells: [
                      // 1. Profile Contact (Avatar + Name + Status Badge)
                      DataCell(
                        InkWell(
                          onTap: () async {
                            final detail = await ref.read(peopleProvider.notifier).selectContactForDetail(c.id);
                            setState(() => _selectedContactForDetail = detail ?? c);
                          },
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
                                    ] else ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(LucideIcons.clock, size: 9, color: Color(0xFFB45309)),
                                            SizedBox(width: 3),
                                            Text(
                                              'Pending Request',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFB45309),
                                              ),
                                            ),
                                          ],
                                        ),
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

                      // 5. Net Exposure (Amount + RECEIVABLE/PAYABLE)
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${_fmt(stand.abs())}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: exposureColor,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              exposureLabel,
                              style: const TextStyle(
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
                          onSelected: (val) async {
                            if (val == 'ledger') {
                              final detail = await ref.read(peopleProvider.notifier).selectContactForDetail(c.id);
                              setState(() => _selectedContactForDetail = detail ?? c);
                            } else if (val == 'edit') {
                              _openEditContactDialog(c);
                            } else if (val == 'delete') {
                              _confirmDeletePerson(c);
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
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.pencil, size: 14, color: Color(0xFF2563EB)),
                                  SizedBox(width: 8),
                                  Text('Edit Contact', style: TextStyle(fontSize: 12.5)),
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
  Widget _buildFinancialGroupsView(double availableWidth, bool isMobile, PeopleState state) {
    final list = _getFilteredGroups(state.groups);

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

              if (list.isEmpty)
                _buildEmptyState(
                  icon: LucideIcons.walletCards,
                  title: 'No Financial Groups Yet',
                  subtitle: _searchQuery.isNotEmpty
                      ? "No group matches '$_searchQuery'."
                      : 'Create your first joint pool or shared syndicate to manage peer expenses.',
                  actionLabel: 'Create Group',
                  onAction: _openNewGroupModal,
                )
              else
                // Group Cards List / Grid
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: list.map((grp) {
                    final targetPool = grp.targetAmount;
                    final contributed = grp.totalContributed;
                    final expenses = grp.totalExpenses;
                    final double pct = grp.completionPercentage / 100.0;
                    final pctString = '${grp.completionPercentage.toStringAsFixed(0)}%';

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
                          // Card Top Row (Tag + members active)
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
                                  (grp.groupType.isEmpty ? 'PROJECT OUTLAYS' : grp.groupType.replaceAll('_', ' ')).toUpperCase(),
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
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${grp.memberCount} active',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        if (grp.pendingMemberCount > 0) ...[
                                          const TextSpan(text: ' '),
                                          TextSpan(
                                            text: '(${grp.pendingMemberCount} pending)',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title & Note
                          Text(
                            grp.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            grp.description ?? 'Shared business capital and collaborative expense pool',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Metrics Row (Contributed / Expenses in 2 separate cards)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
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
                                      const SizedBox(height: 3),
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
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
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
                                      const SizedBox(height: 3),
                                      Text(
                                        '₹${_fmt(expenses)}',
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFDC2626),
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                                onTap: () => _confirmDeleteGroup(grp),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
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
  // OPEN GROUP LEDGER MODAL DIALOG (Matching Images 1 & 2 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _openGroupLedgerModal(FinancialGroup initialGroup) async {
    // Fetch full group details (with members, splits, transactions) from backend
    final detailedGroup = await ref.read(peopleProvider.notifier).selectGroupForDetail(initialGroup.id);
    final grp = detailedGroup ?? initialGroup;

    if (!mounted) return;

    int subTab = 0; // 0: Net Balances, 1: Transactions, 2: Members

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, cRef, _) {
            final activeGrp = cRef.watch(peopleProvider).selectedGroup ?? grp;

            final targetPool = activeGrp.targetAmount;
            final contributed = activeGrp.totalContributed;
            final expenses = activeGrp.totalExpenses;
            final netFund = activeGrp.netFundInHand;
            final members = activeGrp.members;
            final transactions = activeGrp.transactions;

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
                                        activeGrp.name,
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
                                        child: Text(
                                          activeGrp.groupType.toUpperCase(),
                                          style: const TextStyle(
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
                                    activeGrp.description ?? 'Shared business capital and collaborative expense pool',
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
                                onPressed: () => _openRecordGroupEntryModal(activeGrp),
                                icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                                label: const Text(
                                  'Record Entry',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981), // Emerald green from Image 1
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _openInviteMemberModal(activeGrp),
                                icon: const Icon(LucideIcons.userPlus, size: 13, color: Colors.white),
                                label: const Text(
                                  'Invite Member',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => Navigator.pop(dialogCtx),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.x, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Segmented Sub-Tabs Strip (Immediately below header - Matching Image 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          _buildModalTabItem('Net Balances & Overview', LucideIcons.clock, subTab == 0, () {
                            subTab = 0;
                            (context as Element).markNeedsBuild();
                          }),
                          const SizedBox(width: 8),
                          _buildModalTabItem('Transactions (${transactions.length})', LucideIcons.arrowLeftRight, subTab == 1, () {
                            subTab = 1;
                            (context as Element).markNeedsBuild();
                          }),
                          const SizedBox(width: 8),
                          _buildModalTabItem('Members (${members.length})', LucideIcons.users, subTab == 2, () {
                            subTab = 2;
                            (context as Element).markNeedsBuild();
                          }),
                        ],
                      ),
                    ),

                    // Sub-Tab Content
                    Expanded(
                      child: subTab == 0
                          ? _buildModalOverviewTab(
                              members: members,
                              grp: activeGrp,
                            )
                          : (subTab == 1
                              ? _buildModalTransactionsTab(activeGrp, transactions)
                              : _buildModalMembersTab(activeGrp, members)),
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

  Widget _buildLedgerKpiCard({
    required String title,
    required String amount,
    required Color titleColor,
    required Color amountColor,
    required Color bgColor,
    required Color borderColor,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.4,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: amountColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupMetricItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalTabItem(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFFA7F3D0)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF065F46) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF065F46) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOverviewTab({
    required List<GroupMember> members,
    required FinancialGroup grp,
  }) {
    final targetPool = grp.targetAmount;
    final contributed = grp.totalContributed;
    final expenses = grp.totalExpenses;
    final netFund = grp.netFundInHand;
    final toGivePrivate = grp.totalPrivateMoneyToGive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: 4 Top KPI Cards (Matching Image 1)
          Row(
            children: [
              Expanded(
                child: _buildLedgerKpiCard(
                  title: 'TOTAL CONTRIBUTED',
                  amount: '₹${_fmt(contributed)}',
                  titleColor: const Color(0xFF15803D),
                  amountColor: const Color(0xFF15803D),
                  bgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFBBF7D0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLedgerKpiCard(
                  title: 'TOTAL EXPENSES',
                  amount: '₹${_fmt(expenses)}',
                  titleColor: const Color(0xFFDC2626),
                  amountColor: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFECACA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLedgerKpiCard(
                  title: 'NET FUND IN HAND',
                  amount: '₹${_fmt(netFund)}',
                  titleColor: const Color(0xFF2563EB),
                  amountColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLedgerKpiCard(
                  title: 'TARGET POOL',
                  amount: '₹${_fmt(targetPool)}',
                  titleColor: const Color(0xFF475569),
                  amountColor: const Color(0xFF0F172A),
                  bgColor: Colors.white,
                  borderColor: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: 5th Card - TO GIVE (PRIVATE) (Matching Image 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: _buildLedgerKpiCard(
              title: 'TO GIVE (PRIVATE)',
              amount: '₹${_fmt(toGivePrivate)}',
              titleColor: const Color(0xFF15803D),
              amountColor: const Color(0xFF15803D),
              bgColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFBBF7D0),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.lock, size: 9.5, color: Color(0xFF15803D)),
                    SizedBox(width: 3),
                    Text(
                      'Only You',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Row 3: Section Title: Member Financial Positions & Net Dues (Matching Image 1)
          Row(
            children: const [
              Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text(
                'Member Financial Positions & Net Dues',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 4: Member Table (Matching Image 1)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: members.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No members registered in this group yet.', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      horizontalMargin: 20,
                      columnSpacing: 28,
                      headingTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      columns: const [
                        DataColumn(label: Text('Member')),
                        DataColumn(label: Text('Role / Status')),
                        DataColumn(label: Text('Total Paid')),
                        DataColumn(label: Text('Contributed')),
                        DataColumn(label: Text('Owed')),
                        DataColumn(label: Text('Net Balance')),
                        DataColumn(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.lock, size: 12, color: Color(0xFF15803D)),
                              SizedBox(width: 4),
                              Text(
                                'Money to Give',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      rows: members.map((m) {
                        return DataRow(
                          cells: [
                            // 1. Member
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    m.name.isNotEmpty ? m.name : m.email.split('@').first,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    m.email,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 2. Role / Status (Matching Image 1 side by side pills)
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      m.role.toLowerCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: m.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      m.isActive ? 'Active' : 'Pending Invite',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: m.isActive ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 3. Total Paid
                            DataCell(
                              Text(
                                '₹${_fmt(m.totalPaid)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            // 4. Contributed
                            DataCell(
                              Text(
                                '₹${_fmt(m.totalContributed)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            // 5. Owed
                            DataCell(
                              Text(
                                '₹${_fmt(m.totalOwed)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            // 6. Net Balance
                            DataCell(
                              Text(
                                m.netBalance > 0
                                    ? '+₹${_fmt(m.netBalance)}'
                                    : (m.netBalance < 0 ? '-₹${_fmt(m.netBalance.abs())}' : '₹0'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: m.netBalance > 0
                                      ? const Color(0xFF15803D)
                                      : (m.netBalance < 0 ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
                                ),
                              ),
                            ),
                            // 7. Money to Give (+ Note to Give matching Image 1)
                            DataCell(
                              m.privateNote != null && m.privateNote!.amount > 0
                                  ? InkWell(
                                      onTap: () => _openNoteToGiveModal(grp, m),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '₹${_fmt(m.privateNote!.amount)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            if (m.privateNote!.notes.isNotEmpty) ...[
                                              const SizedBox(height: 1),
                                              Text(
                                                m.privateNote!.notes,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: Color(0xFF64748B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Edit Note',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () => _openNoteToGiveModal(grp, m),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFF86EFAC)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              '+ Note to Give',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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

  Widget _buildModalTransactionsTab(FinancialGroup grp, List<GroupTransaction> txs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Shared Financial Entries + button + Record Entry (Matching Image 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shared Financial Entries',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openRecordGroupEntryModal(grp),
                icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                label: const Text(
                  'Record Entry',
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Transactions Table Container (Matching Image 2)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: txs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No transactions recorded in this group yet.', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      horizontalMargin: 20,
                      columnSpacing: 28,
                      headingTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Title & Category')),
                        DataColumn(label: Text('Recorded By / Payer')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: SizedBox(width: 24)),
                      ],
                      rows: txs.map((t) {
                        final isContribution = t.type.toLowerCase() == 'contribution';
                        final typeColor = isContribution ? const Color(0xFF15803D) : const Color(0xFFDC2626);
                        final dateStr = t.createdAt != null
                            ? '${t.createdAt!.year}-${t.createdAt!.month.toString().padLeft(2, '0')}-${t.createdAt!.day.toString().padLeft(2, '0')}'
                            : '2026-11-26';

                        return DataRow(
                          cells: [
                            // 1. Date
                            DataCell(Text(dateStr, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)))),
                            // 2. Type (e.g. CONTRIBUTION in green)
                            DataCell(
                              Text(
                                t.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: typeColor,
                                ),
                              ),
                            ),
                            // 3. Title & Category
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    t.category ?? 'General',
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            // 4. Recorded By / Payer
                            DataCell(
                              Text(
                                (t.recordedBy != null && t.recordedBy!.isNotEmpty)
                                    ? t.recordedBy!
                                    : (grp.members.isNotEmpty ? grp.members.first.name : 'ravinew2004'),
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                              ),
                            ),
                            // 5. Amount
                            DataCell(
                              Text(
                                '₹${_fmt(t.amount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            // 6. Delete Action
                            DataCell(
                              InkWell(
                                onTap: () async {
                                  final ok = await ref.read(peopleProvider.notifier).deleteGroupTransaction(grp.id, t.id);
                                  if (ok && mounted) {
                                    AppSnackbar.show(context, 'Group transaction deleted', type: SnackType.info);
                                  }
                                },
                                child: const Icon(
                                  LucideIcons.trash2,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
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

  Widget _buildModalMembersTab(FinancialGroup grp, List<GroupMember> members) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Group Governance & Participants + button + Invite Partner (Matching Image 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Group Governance & Participants',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openInviteMemberModal(grp),
                icon: const Icon(LucideIcons.userPlus, size: 14, color: Colors.white),
                label: const Text(
                  'Invite Partner',
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Member Cards Grid (Matching Image 3)
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No members found', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 900
                    ? (constraints.maxWidth - 32) / 3
                    : (constraints.maxWidth >= 600 ? (constraints.maxWidth - 16) / 2 : double.infinity);

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: members.map((m) {
                    final hasPrivateNote = m.privateNote != null && m.privateNote!.amount > 0;

                    return Container(
                      width: cardWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header: Name + Role Badge (ADMIN / MEMBER)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  m.name.isNotEmpty ? m.name : m.email.split('@').first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m.role.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF475569),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 2. Email with icon
                          Row(
                            children: [
                              const Icon(LucideIcons.mail, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  m.email,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 3. Middle Note Box (Matching Image 3)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(LucideIcons.lock, size: 11, color: Color(0xFF15803D)),
                                        SizedBox(width: 4),
                                        Text(
                                          'My Private Note (Only for me)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () => _openNoteToGiveModal(grp, m),
                                      child: Text(
                                        hasPrivateNote ? 'Edit' : '+ Note to Give',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (hasPrivateNote) ...[
                                  Text(
                                    'I will give: ₹${_fmt(m.privateNote!.amount)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (m.privateNote!.notes.isNotEmpty) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      '"${m.privateNote!.notes}"',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ] else ...[
                                  const Text(
                                    'No private commitment set yet',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 4. Footer: Status (Active Member vs Pending Invite) & Remove
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    m.isActive ? LucideIcons.check : LucideIcons.clock,
                                    size: 13,
                                    color: m.isActive ? const Color(0xFF15803D) : const Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.isActive ? 'Active Member' : 'Pending Invite',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: m.isActive ? const Color(0xFF15803D) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                              if (!m.isActive || m.role.toLowerCase() != 'admin')
                                InkWell(
                                  onTap: () async {
                                    final ok = await ref.read(peopleProvider.notifier).removeGroupMember(grp.id, m.id);
                                    if (ok && mounted) {
                                      AppSnackbar.show(context, 'Member removed from group', type: SnackType.info);
                                    }
                                  },
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: REQUESTS VIEW (Matching Image 5 exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRequestsView(double availableWidth, bool isMobile, PeopleState state) {
    final directRequests = state.incomingRequests;
    final groupInvitations = state.groups.where((g) => g.isPendingInvitation).toList();
    final totalPendingCount = directRequests.length + groupInvitations.length;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Incoming Requests & Invitations + Pending badge from Image 2)
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Contact connections and financial group invitations sent to your @bnxmail.com address.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft Blue
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalPendingCount Pending',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Section 1: Financial Group Invitations (Matching Image 2) ──
          Row(
            children: [
              const Icon(LucideIcons.walletCards, size: 16, color: Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Text(
                'Financial Group Invitations (${groupInvitations.length})',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (groupInvitations.isNotEmpty)
            ...groupInvitations.map((grp) {
              final invName = grp.invitedByName ?? (grp.members.isNotEmpty ? grp.members.first.name : 'Partner');
              final invEmail = grp.invitedByEmail ?? (grp.members.isNotEmpty ? grp.members.first.email : 'partner@bnxmail.com');

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(20),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E40AF), // Deep Blue square from Image 2
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.walletCards, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    grp.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      grp.groupType.isEmpty ? 'Business_syndicate' : grp.groupType,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (grp.description != null && grp.description!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  grp.description!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 5),
                              Text(
                                'Invited by: $invName ($invEmail)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Role: ${(grp.myRole ?? 'ADMIN').toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Pool Goal: ₹${_fmt(grp.targetAmount)}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await ref.read(peopleProvider.notifier).joinFinancialGroup(grp.id);
                                  if (mounted) {
                                    AppSnackbar.show(context, "Joined '${grp.name}' group successfully!", type: SnackType.success);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                  }
                                }
                              },
                              icon: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                              label: const Text(
                                'Join Group',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5), // Purple/Indigo matching Image 2
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await ref.read(peopleProvider.notifier).declineFinancialGroup(grp.id);
                                if (mounted) {
                                  AppSnackbar.show(context, "Declined invitation to '${grp.name}'", type: SnackType.info);
                                }
                              } catch (e) {
                                if (mounted) {
                                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                }
                              }
                            },
                            icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFFDC2626)),
                            label: const Text(
                              'Decline',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),

          // ── Section 2: Direct Contact Requests (Image 2) ──
          Row(
            children: [
              const Icon(LucideIcons.userPlus, size: 16, color: Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Text(
                'Direct Contact Requests (${directRequests.length})',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (directRequests.isEmpty)
            // Empty State Box (Matching Image 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: const Text(
                'No direct contact requests pending.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            )
          else
            Column(
              children: directRequests.map((req) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
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
                      // Top Row: Avatar + Info + Badges (Image 3)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E40AF), // Deep Blue square from Image 3
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                req.fromName.isNotEmpty ? req.fromName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.fromName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.mail, size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 5),
                                    Text(
                                      req.fromEmail,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'COLLEAGUE',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(LucideIcons.clock, size: 10, color: Color(0xFFD97706)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Pending',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFD97706),
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
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Action Buttons Row (Image 3: Wide Accept button + Decline button)
                      Row(
                        children: [
                          Expanded(
                            flex: isMobile ? 1 : 3,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleRespondRequest(req, 'accept'),
                              icon: const Icon(LucideIcons.check, size: 15, color: Colors.white),
                              label: const Text(
                                'Accept Request',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981), // Vibrant Green from Image 3
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(0, 42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              onPressed: () => _handleRespondRequest(req, 'reject'),
                              icon: const Icon(LucideIcons.x, size: 15, color: Color(0xFFEF4444)),
                              label: const Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                minimumSize: const Size(0, 42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: GLOBAL LEDGER VIEW (Matching Image 1)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGlobalLedgerView(double availableWidth, bool isMobile, PeopleState state) {
    final list = _getFilteredTransactions(state.transactions);

    if (list.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.arrowLeftRight,
        title: 'Zero Transactions Recorded',
        subtitle: _searchQuery.isNotEmpty
            ? 'No transaction matches your search query.'
            : 'Transactions logged between peer network members will display in this centralized ledger.',
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
              final isLent = tx.isLent;
              final classification = (isLent ? 'LENT' : 'BORROWED').toUpperCase();
              final flowSign = isLent ? '+' : '-';
              final flowColor = isLent ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
              final amt = tx.amount;

              return DataRow(
                cells: [
                  // 1. EXECUTION DATE
                  DataCell(
                    Text(
                      tx.date,
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
                      tx.personName.isNotEmpty ? tx.personName : 'Peer Contact',
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
                      tx.notes ?? '-',
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
                        color: isLent ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        classification,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isLent ? const Color(0xFF15803D) : const Color(0xFFDC2626),
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

                  // 6. Action: Delete action
                  DataCell(
                    IconButton(
                      onPressed: () {
                        // Section 9 constraint: Backend does not expose DELETE /people/transactions
                        AppSnackbar.show(
                          context,
                          'People ledger transactions are immutable records and cannot be directly deleted.',
                          type: SnackType.info,
                        );
                      },
                      icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFCBD5E1)),
                      tooltip: 'Immutable ledger record',
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
  Widget _buildRepaymentAlertsView(double availableWidth, bool isMobile, PeopleState state) {
    final list = _getFilteredAlerts(state.reminders);

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
              onTap: () => _openDispatchAlertModal(isMobile, state.contacts),
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
            onAction: () => _openDispatchAlertModal(isMobile, state.contacts),
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
                    final amt = alert.claimCap;
                    final contactName = alert.targetContact;
                    final memo = alert.memoLabel;
                    final date = alert.maturityDate;

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

                        // 2. TARGET CONTACT
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
                              color: Color(0xFF475569),
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

                        // 5. Actions: Send + Trash + Settle
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Section 10 constraint: External message dispatch endpoint not exposed
                                  AppSnackbar.show(
                                    context,
                                    "Notification dispatch (SMS/Push) is not yet exposed by the backend for reminder ID ${alert.id}.",
                                    type: SnackType.info,
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
                                tooltip: 'Delete Reminder',
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _confirmSettleAlert(alert),
                                icon: Icon(
                                  alert.isSettled ? LucideIcons.checkCheck : LucideIcons.circleCheck,
                                  size: 16,
                                  color: const Color(0xFF10B981),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: alert.isSettled ? 'Already Settled' : 'Mark Settled',
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
  Widget _buildContactDetailView(PersonContact contact) {
    final stand = contact.netBalance;
    final transactions = contact.transactions;
    final standText = stand == 0
        ? '₹0 SETTLED'
        : (stand > 0 ? '+₹${_fmt(stand)} RECEIVABLE' : '-₹${_fmt(stand.abs())} PAYABLE');
    final standColor = stand == 0
        ? const Color(0xFF64748B)
        : (stand > 0 ? const Color(0xFF059669) : const Color(0xFFEF4444));

    final totalLent = contact.totalLent;
    final totalBorrowed = contact.totalBorrowed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF111827), size: 20),
          onPressed: () {
            ref.read(peopleProvider.notifier).clearSelectedContact();
            setState(() => _selectedContactForDetail = null);
          },
        ),
        title: Text(
          '${contact.name} • Ledger',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, color: Color(0xFF166534), size: 18),
            tooltip: 'Edit Contact',
            onPressed: () => _openEditContactDialog(contact),
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
                            backgroundColor: contact.avatarBg,
                            child: Text(
                              contact.initials,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: contact.avatarColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${contact.displayCompany} • ${contact.formattedPhone}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  contact.email,
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
                  ],
                ),
                const SizedBox(height: 12),

                // Transactions List
                if (transactions.isEmpty)
                  _buildEmptyState(
                    icon: LucideIcons.bookOpen,
                    title: 'No Transactions for this Contact',
                    subtitle: 'Transactions involving this contact will appear here in chronological order.',
                  )
                else
                  ...transactions.map((t) {
                    final isLent = t.isLent;
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
                              Text(t.notes ?? 'Peer transfer', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Date: ${t.date} • ${t.type.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                          Text(
                            '${isLent ? '+' : '-'}₹${_fmt(t.amount)}',
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
        onSubmit: (req) async {
          final created = await ref.read(peopleProvider.notifier).createContact(req);
          if (created != null && mounted) {
            AppSnackbar.show(
              context,
              "Contact '${created.name}' added to registry!",
              type: SnackType.success,
            );
          }
        },
      ),
    );
  }

  void _openEditContactDialog(PersonContact contact) {
    final phoneCtrl = TextEditingController(text: contact.phone);
    final relationCtrl = TextEditingController(text: contact.relationship ?? contact.roleType);
    final companyCtrl = TextEditingController(text: contact.company ?? '');
    final notesCtrl = TextEditingController(text: contact.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${contact.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: relationCtrl,
              decoration: const InputDecoration(labelText: 'Relationship / Role'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: companyCtrl,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final req = UpdatePersonRequest(
                phone: phoneCtrl.text.trim(),
                relationship: relationCtrl.text.trim(),
                company: companyCtrl.text.trim(),
                notes: notesCtrl.text.trim(),
              );
              try {
                final updated = await ref.read(peopleProvider.notifier).updateContact(contact.id, req);
                if (mounted) {
                  Navigator.pop(ctx);
                  if (_selectedContactForDetail?.id == contact.id) {
                    setState(() => _selectedContactForDetail = updated);
                  }
                  AppSnackbar.show(context, 'Contact updated successfully!', type: SnackType.success);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePerson(PersonContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Contact Deletion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
        content: Text(
          "Are you sure you want to permanently delete '${contact.name}'? This action will cascade delete all linked ledger transactions, activity records, and repayment reminders from the system.",
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final ok = await ref.read(peopleProvider.notifier).deleteContact(contact.id);
                if (ok && mounted) {
                  if (_selectedContactForDetail?.id == contact.id) {
                    setState(() => _selectedContactForDetail = null);
                  }
                  AppSnackbar.show(context, "Contact '${contact.name}' removed from registry", type: SnackType.info);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _openGeneralLogModal(bool isMobile) {
    // Section 6 restriction: The People API does not document POST /people/transactions
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.info, size: 20, color: Color(0xFF166534)),
            SizedBox(width: 8),
            Text('Log Transaction Notice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Individual People direct transaction creation is not currently exposed by the backend People API. Peer ledger movements are recorded through verified business settlements, order transactions, or group pools.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _openNewGroupModal() {
    final titleCtrl = TextEditingController();
    String selectedModel = 'Business Syndicate';
    final targetPoolCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // Invite Partner fields
    final partnerNameCtrl = TextEditingController();
    final partnerEmailCtrl = TextEditingController();
    String partnerRole = 'Member';
    final invitedPartners = <Map<String, String>>[];

    bool isSubmitting = false;

    final models = [
      'Business Syndicate',
      'Savings & Contribution Pool',
      'Project Expenses',
      'Lending & Credit Circle',
    ];

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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8FDF3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.walletCards,
                                      size: 18,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'New Financial Group',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Create a shared syndicate or pool with verified @bnxmail.com partners',
                                        style: TextStyle(
                                          fontSize: 11,
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
                          InkWell(
                            key: const Key('close_new_financial_group_dialog'),
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Group Title *
                      RichText(
                        text: const TextSpan(
                          text: 'Group Title ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleCtrl,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'e.g. Q4 Inventory Syndicate or Retail Expansion Pool',
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          filled: true,
                          fillColor: Colors.white,
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
                      const SizedBox(height: 14),

                      // Two Columns: Group Financial Model & Target Pool Amount (Optional)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Group Financial Model',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedModel,
                                      isExpanded: true,
                                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                                      selectedItemBuilder: (BuildContext context) {
                                        return models.map<Widget>((String item) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      items: models.map((m) {
                                        final isSel = m == selectedModel;
                                        return DropdownMenuItem(
                                          value: m,
                                          child: Text(
                                            isSel ? '✓ $m' : '   $m',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setModalState(() => selectedModel = v);
                                        }
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
                                const Text(
                                  'Target Pool Amount (Optional)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: targetPoolCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 500000',
                                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    filled: true,
                                    fillColor: Colors.white,
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
                      const SizedBox(height: 14),

                      // Description & Purpose
                      const Text(
                        'Description & Purpose',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Outline capital objectives, expense boundaries, or settlement frequency...',
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          filled: true,
                          fillColor: Colors.white,
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

                      // Invite Group Partners (Strictly @bnxmail.com)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Invite Group Partners (Strictly @bnxmail.com)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${invitedPartners.length} invited',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Input Row (Name, partner@bnxmail.com, Member, Add)
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextField(
                                      controller: partnerNameCtrl,
                                      style: const TextStyle(fontSize: 11.5),
                                      decoration: InputDecoration(
                                        hintText: 'Name',
                                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextField(
                                      controller: partnerEmailCtrl,
                                      style: const TextStyle(fontSize: 11.5),
                                      decoration: InputDecoration(
                                        hintText: 'partner@bnxmail.com',
                                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: partnerRole,
                                        isExpanded: true,
                                        icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Member',
                                            child: Text('Member', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Admin',
                                            child: Text('Admin', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setModalState(() => partnerRole = v);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final pEmail = partnerEmailCtrl.text.trim().toLowerCase();
                                      final pName = partnerNameCtrl.text.trim();
                                      if (pEmail.isEmpty || !pEmail.endsWith('@bnxmail.com')) {
                                        AppSnackbar.show(context, 'Partner email must end with @bnxmail.com', type: SnackType.error);
                                        return;
                                      }
                                      setModalState(() {
                                        invitedPartners.add({
                                          'name': pName.isNotEmpty ? pName : pEmail.split('@').first,
                                          'email': pEmail,
                                          'role': partnerRole,
                                        });
                                        partnerNameCtrl.clear();
                                        partnerEmailCtrl.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF064E3B),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),

                            if (invitedPartners.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: invitedPartners.map((p) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${p['name']} (${p['role']})',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () => setModalState(() => invitedPartners.remove(p)),
                                          child: const Icon(LucideIcons.x, size: 12, color: Color(0xFF64748B)),
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
                      const SizedBox(height: 22),

                      // Bottom Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        final title = titleCtrl.text.trim();
                                        if (title.isEmpty) {
                                          AppSnackbar.show(context, 'Group title is required', type: SnackType.error);
                                          return;
                                        }

                                        setModalState(() => isSubmitting = true);
                                        final target = double.tryParse(targetPoolCtrl.text.trim()) ?? 0.0;
                                        final typeSlug = selectedModel.toLowerCase().replaceAll(' ', '_').replaceAll('&_', '');
                                        final req = CreateFinancialGroupRequest(
                                          name: title,
                                          description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                                          targetAmount: target,
                                          currency: 'INR',
                                          groupType: typeSlug,
                                        );

                                        try {
                                          final grp = await ref.read(peopleProvider.notifier).createFinancialGroup(req);

                                          // Send invitations for invited partners if any
                                          for (final partner in invitedPartners) {
                                            try {
                                              await ref.read(peopleProvider.notifier).inviteGroupMember(
                                                grp.id,
                                                InviteGroupMemberRequest(
                                                  email: partner['email']!,
                                                  role: partner['role']?.toLowerCase() ?? 'member',
                                                ),
                                              );
                                            } catch (_) {}
                                          }

                                          if (mounted) {
                                            Navigator.pop(ctx);
                                            AppSnackbar.show(context, "Group '${grp.name}' created successfully!", type: SnackType.success);
                                          }
                                        } catch (e) {
                                          setModalState(() => isSubmitting = false);
                                          if (mounted) {
                                            AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF064E3B),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Create Group & Send Invites',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
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
      },
    );
  }

  void _confirmDeleteGroup(FinancialGroup grp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Financial Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
        content: Text("Are you sure you want to delete '${grp.name}'? All member pool records will be cleared."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final ok = await ref.read(peopleProvider.notifier).deleteFinancialGroup(grp.id);
                if (ok && mounted) {
                  AppSnackbar.show(context, "Financial group '${grp.name}' deleted", type: SnackType.info);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openRecordGroupEntryModal(FinancialGroup grp) {
    String entryType = 'expense';
    final amtCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General');

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Group Transaction',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Entry Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: entryType,
                                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                items: const [
                                  DropdownMenuItem(value: 'expense', child: Text('Group Expense')),
                                  DropdownMenuItem(value: 'contribution', child: Text('Capital Contribution')),
                                ],
                                onChanged: (v) => setModalState(() => entryType = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Amount (₹) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: amtCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '0.00', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Title / Description *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. Architectural Blueprint Fee', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. Design, Supply, Operations', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty || amt <= 0) {
                            AppSnackbar.show(context, 'Please enter a valid title and amount greater than 0', type: SnackType.warning);
                            return;
                          }
                          final req = AddGroupTransactionRequest(
                            title: title,
                            amount: amt,
                            type: entryType,
                            category: categoryCtrl.text.trim(),
                            splitType: 'equal',
                          );
                          try {
                            await ref.read(peopleProvider.notifier).addGroupTransaction(grp.id, req);
                            if (mounted) {
                              Navigator.pop(ctx);
                              AppSnackbar.show(context, 'Transaction saved successfully!', type: SnackType.success);
                            }
                          } catch (e) {
                            if (mounted) {
                              AppSnackbar.show(context, e.toString(), type: SnackType.error);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
                        child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _openInviteMemberModal(FinancialGroup grp) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'member';
    bool isSubmitting = false;

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
                width: 460,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Invite Partner to Group + Close X - Matching Images 2 & 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Invite Partner to Group',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Partner Name
                    const Text(
                      'Partner Name',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. Ramesh Patel',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: Colors.white,
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
                    const SizedBox(height: 14),

                    // Partner @bnxmail.com Email *
                    RichText(
                      text: const TextSpan(
                        text: 'Partner @bnxmail.com Email ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'partner@bnxmail.com',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: Colors.white,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Assigned Access Role (Matching Image 3)
                    const Text(
                      'Assigned Access Role',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(
                              value: 'member',
                              child: Text('Member (Can view ledger & contribute)', style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                            ),
                            DropdownMenuItem(
                              value: 'manager',
                              child: Text('Manager (Can record & edit transactions)', style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                            ),
                            DropdownMenuItem(
                              value: 'auditor',
                              child: Text('Auditor (Read-only financial auditor)', style: TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedRole = v);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons (Cancel / Dispatch Invitation)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final email = emailCtrl.text.trim().toLowerCase();
                                      if (email.isEmpty || !email.endsWith('@bnxmail.com')) {
                                        AppSnackbar.show(context, 'Please enter a valid @bnxmail.com email address', type: SnackType.warning);
                                        return;
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final req = InviteGroupMemberRequest(
                                        email: email,
                                        role: selectedRole,
                                      );

                                      try {
                                        await ref.read(peopleProvider.notifier).inviteGroupMember(grp.id, req);
                                        if (mounted) {
                                          Navigator.pop(ctx);
                                          AppSnackbar.show(context, "Invitation dispatched to '$email'!", type: SnackType.success);
                                        }
                                      } catch (e) {
                                        setModalState(() => isSubmitting = false);
                                        if (mounted) {
                                          AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF064E3B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Dispatch Invitation',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
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

  void _openNoteToGiveModal(FinancialGroup grp, GroupMember member) {
    final amtCtrl = TextEditingController(
      text: (member.privateNote?.amount ?? 0.0) > 0
          ? (member.privateNote!.amount == member.privateNote!.amount.toInt()
              ? member.privateNote!.amount.toInt().toString()
              : member.privateNote!.amount.toString())
          : '',
    );
    final memoCtrl = TextEditingController(text: member.privateNote?.notes ?? '');
    bool isSubmitting = false;

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
                width: 460,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Icon + Title + Subtitle + Close X - Matching Image 4)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.lock, size: 18, color: Color(0xFF10B981)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Private Member Note',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Only visible to you',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Target Member Box (Matching Image 4)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TARGET MEMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.name.isNotEmpty ? member.name : member.email.split('@').first,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            member.email,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 1: How much money will you give? *
                    RichText(
                      text: const TextSpan(
                        text: 'How much money will you give? ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amtCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: Colors.white,
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
                    const SizedBox(height: 14),

                    // Field 2: Private Memo / Reason (Optional)
                    const Text(
                      'Private Memo / Reason (Optional)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: memoCtrl,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. For raw materials share, to be settled next Tuesday...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: Colors.white,
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

                    // Green Disclaimer Box (Matching Image 4)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(LucideIcons.lock, size: 15, color: Color(0xFF059669)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This note and amount will NEVER be visible to any other group member or admin.',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF065F46),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Action Buttons (Cancel / Save Private Note)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                                      final memo = memoCtrl.text.trim();

                                      setModalState(() => isSubmitting = true);
                                      final req = SetPrivateNoteRequest(note: memo, amount: amt);

                                      try {
                                        await ref.read(peopleProvider.notifier).setPrivateMemberNote(grp.id, member.id, req);
                                        await ref.read(peopleProvider.notifier).selectGroupForDetail(grp.id);
                                        if (mounted) {
                                          Navigator.pop(ctx);
                                          AppSnackbar.show(context, 'Private note saved successfully!', type: SnackType.success);
                                        }
                                      } catch (e) {
                                        setModalState(() => isSubmitting = false);
                                        if (mounted) {
                                          AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF064E3B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Save Private Note',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
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

  void _openDispatchAlertModal(bool isMobile, List<PersonContact> contacts) {
    if (contacts.isEmpty) {
      AppSnackbar.show(context, 'Please enroll at least one contact before scheduling repayment alerts.', type: SnackType.warning);
      return;
    }

    PersonContact selected = contacts.first;
    final memoCtrl = TextEditingController(text: 'Q4 Short-term Bridge Repayment');
    final claimCapCtrl = TextEditingController(text: '25000.00');
    DateTime selectedDate = DateTime(2026, 12, 15);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule Repayment Alert',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Target Contact *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PersonContact>(
                      value: selected,
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: contacts.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selected = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Memo Label *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: memoCtrl,
                                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Claim Cap (₹) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: claimCapCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Maturity / Due Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                            Text('${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                            const Icon(LucideIcons.calendar, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          final memo = memoCtrl.text.trim();
                          final amt = double.tryParse(claimCapCtrl.text.trim()) ?? 0.0;
                          final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                          if (memo.isEmpty || amt <= 0) {
                            AppSnackbar.show(context, 'Please enter a valid memo and claim amount', type: SnackType.warning);
                            return;
                          }
                          final req = CreateRepaymentAlertRequest(
                            contactId: selected.id,
                            targetContact: selected.name,
                            claimCap: amt,
                            maturityDate: dateStr,
                            memoLabel: memo,
                            status: 'Pending',
                          );
                          try {
                            await ref.read(peopleProvider.notifier).createRepaymentAlert(req);
                            if (mounted) {
                              Navigator.pop(ctx);
                              AppSnackbar.show(context, "Repayment alert scheduled for '${selected.name}'!", type: SnackType.success);
                            }
                          } catch (e) {
                            if (mounted) {
                              AppSnackbar.show(context, e.toString(), type: SnackType.error);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
                        child: const Text('Dispatch Repayment Alert', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _confirmDeleteAlert(RepaymentAlert alert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Repayment Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
        content: Text("Are you sure you want to dismiss the repayment alert for '${alert.targetContact}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final ok = await ref.read(peopleProvider.notifier).deleteRepaymentAlert(alert.id);
                if (ok && mounted) {
                  AppSnackbar.show(context, 'Alert cleared', type: SnackType.info);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmSettleAlert(RepaymentAlert alert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Alert as Settled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
        content: Text("Mark repayment of ₹${_fmt(alert.claimCap)} from '${alert.targetContact}' as Settled on the server?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final ok = await ref.read(peopleProvider.notifier).updateAlertStatus(alert.id, 'Settled');
                if (ok && mounted) {
                  AppSnackbar.show(context, 'Alert marked as settled!', type: SnackType.success);
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.show(context, e.toString(), type: SnackType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Confirm Settle'),
          ),
        ],
      ),
    );
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

class _TabDef {
  final String title;
  final IconData icon;
  final bool hasNotificationBadge;
  const _TabDef({
    required this.title,
    required this.icon,
    this.hasNotificationBadge = false,
  });
}
