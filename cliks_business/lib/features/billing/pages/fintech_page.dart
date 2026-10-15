import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';

class FintechPage extends StatefulWidget {
  const FintechPage({super.key});

  @override
  State<FintechPage> createState() => _FintechPageState();
}

class _FintechPageState extends State<FintechPage> {
  // ─── CHECKLIST STATE ───
  final List<Map<String, dynamic>> _checklistTasks = [
    {
      'task': 'ghhj',
      'dueDate': '2026-12-12',
      'priority': 'Medium',
      'status': 'In Progress',
      'uploaded': true,
    },
    {
      'task': 'gst file upload',
      'dueDate': '2026-08-29',
      'priority': 'Medium',
      'status': 'In Progress',
      'uploaded': true,
    },
    {
      'task': 'Desc , for the task',
      'dueDate': '2026-08-27',
      'priority': 'Medium',
      'status': 'Completed',
      'uploaded': true,
    },
  ];

  // ─── CREDENTIALS STATE ───
  String _selectedPortal = 'GST Portal';
  bool _showPassword = false;

  final Map<String, TextEditingController> _usernameControllers = {
    'GST Portal': TextEditingController(text: 'connectwithravi2004@gmail.com'),
    'Income Tax': TextEditingController(text: 'connectwithravi2004@gmail.com'),
    'TRACES': TextEditingController(text: 'connectwithravi2004@gmail.com'),
    'MCA Portal': TextEditingController(text: 'connectwithravi2004@gmail.com'),
    'EPFO / ESIC': TextEditingController(text: 'connectwithravi2004@gmail.com'),
  };

  final Map<String, TextEditingController> _passwordControllers = {
    'GST Portal': TextEditingController(text: 'RaviSecure@2026'),
    'Income Tax': TextEditingController(text: 'RaviSecure@2026'),
    'TRACES': TextEditingController(text: 'RaviSecure@2026'),
    'MCA Portal': TextEditingController(text: 'RaviSecure@2026'),
    'EPFO / ESIC': TextEditingController(text: 'RaviSecure@2026'),
  };

  final Map<String, bool> _sharedStatuses = {
    'GST Portal': false,
    'Income Tax': false,
    'TRACES': false,
    'MCA Portal': false,
    'EPFO / ESIC': false,
  };

  @override
  void dispose() {
    for (final controller in _usernameControllers.values) {
      controller.dispose();
    }
    for (final controller in _passwordControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 980;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: isMobile ? 12 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildComplianceChecklistCard(),
                        const SizedBox(height: 20),
                        _buildAccountantConnectionCard(),
                        const SizedBox(height: 20),
                        _buildPortalCredentialsCard(),
                        const SizedBox(height: 20),
                        _buildPaymentHistoryCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Compliance Checklist & Credentials)
                        Expanded(
                          flex: 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildComplianceChecklistCard(),
                              const SizedBox(height: 20),
                              _buildPortalCredentialsCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Column (Accountant Connection & Payment History)
                        Expanded(
                          flex: 9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAccountantConnectionCard(),
                              const SizedBox(height: 20),
                              _buildPaymentHistoryCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 1: FIN-PRO-Assigned Compliance Checklist
  // ═══════════════════════════════════════════════════════════════
  Widget _buildComplianceChecklistCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          const Row(
            children: [
              Icon(
                LucideIcons.circleCheck,
                color: Color(0xFF2563EB),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📋 FIN-PRO-Assigned Compliance Checklist',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "These are the live compliance and audit actions assigned to your account by your connected FIN-PRO. Mark them as 'Completed' or 'In Progress' to sync status in real time.",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Checklist Table with horizontal scroll protection and overflow-proof cells
          LayoutBuilder(
            builder: (context, constraints) {
              final double minWidth = 640;
              final double actualWidth = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: actualWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // Task details
                      1: FlexColumnWidth(1.5), // Due date
                      2: FlexColumnWidth(1.1), // Priority
                      3: FlexColumnWidth(3.2), // Filing status / action
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        children: [
                          _buildSortableTableHeader('TASK DETAILS'),
                          _buildSortableTableHeader('DUE DATE'),
                          _buildSortableTableHeader('PRIORITY'),
                          _buildSortableTableHeader('FILING STATUS / ACTION'),
                        ],
                      ),
                      // Data Rows
                      ...List.generate(_checklistTasks.length, (index) {
                        final task = _checklistTasks[index];
                        final isCompleted = task['status'] == 'Completed';

                        return TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: index == _checklistTasks.length - 1
                                    ? Colors.transparent
                                    : const Color(0xFFF1F5F9),
                              ),
                            ),
                          ),
                          children: [
                            // Task details
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: Text(
                                task['task'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            // Due date
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('📅', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Text(
                                      task['dueDate'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Priority badge
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task['priority'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Filing status / Action
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Status toggle button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          task['status'] = isCompleted ? 'In Progress' : 'Completed';
                                        });
                                        AppSnackbar.show(
                                          context,
                                          'Task "${task['task']}" status set to ${task['status']}.',
                                          type: SnackType.info,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? const Color(0xFFECFDF5)
                                              : const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isCompleted
                                                ? const Color(0xFFA7F3D0)
                                                : const Color(0xFFBFDBFE),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isCompleted ? LucideIcons.check : LucideIcons.zap,
                                              size: 12,
                                              color: isCompleted
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFF2563EB),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              task['status'] as String,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isCompleted
                                                    ? const Color(0xFF059669)
                                                    : const Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Uploaded indicator
                                    InkWell(
                                      onTap: () {
                                        AppSnackbar.show(
                                          context,
                                          'Filing document verified & uploaded for "${task['task']}".',
                                          type: SnackType.success,
                                        );
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.circleCheck,
                                            size: 13,
                                            color: Color(0xFF16A34A),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Uploaded',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF16A34A),
                                            ),
                                          ),
                                        ],
                                      ),
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
        ],
      ),
    );
  }

  Widget _buildSortableTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.filter, size: 10, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 2: Accountant Connection
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAccountantConnectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(LucideIcons.users, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              const Text('🤝', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Accountant\nConnection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ),
              // Connected Badge & Action Buttons wrapped in FittedBox
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.check, size: 12, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chat button
                    InkWell(
                      onTap: () {
                        _showChatDialog();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(LucideIcons.messageSquare, size: 14, color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Stopwatch button
                    InkWell(
                      onTap: () {
                        AppSnackbar.show(
                          context,
                          "Live session with beta@beta-softnet.com is active (42 mins).",
                          type: SnackType.info,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(LucideIcons.timer, size: 14, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Connected Accountant Partner Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.user, color: Color(0xFF16A34A), size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'beta@beta-softnet.com',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Authorized Accountant Partner • Connected since 29/09/2026',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Security Clearance Subtitle
          const Text(
            'Security Clearance & Shared Privileges:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Privileges
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPrivilegeTile(
                      title: 'Check GST & Tax Records',
                      subtitle: 'Validates input credit & filing status',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPrivilegeTile(
                      title: 'Analyze Invoices & Fraud Risks',
                      subtitle: 'Flags suspicious payments & variance scores',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPrivilegeTile(
                      title: 'Map International Accounts',
                      subtitle: 'IFRS / US GAAP layout mapping',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPrivilegeTile(
                      title: 'Reconcile Bank Feed Transactions',
                      subtitle: 'Matches inbound ledger payments',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeTile({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.check, size: 14, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 3: Government & Compliance Portal Credentials
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPortalCredentialsCard() {
    final portals = ['GST Portal', 'Income Tax', 'TRACES', 'MCA Portal', 'EPFO / ESIC'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          const Row(
            children: [
              Text('🔐', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Government & Compliance Portal Credentials (Private Sharing)',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Only your connected Chartered Accountant / Auditor can access these credentials after you choose to share them.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Portal Selectors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: portals.map((portal) {
                final isSelected = _selectedPortal == portal;

                final IconData icon = () {
                  switch (portal) {
                    case 'GST Portal':
                      return LucideIcons.shieldCheck;
                    case 'Income Tax':
                      return LucideIcons.folder;
                    case 'TRACES':
                      return LucideIcons.fileSpreadsheet;
                    case 'MCA Portal':
                      return LucideIcons.landmark;
                    default:
                      return LucideIcons.hardHat;
                  }
                }();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPortal = portal),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 13,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            portal,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Portal Username / Email
          Text(
            '$_selectedPortal Username / Email *',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usernameControllers[_selectedPortal],
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF15803D),
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 16),

          // Portal Password
          Text(
            '$_selectedPortal Password *',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordControllers[_selectedPortal],
            obscureText: !_showPassword,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 10),

          // Show Password & Status Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _showPassword,
                      activeColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _showPassword = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: const Text(
                      'Show Password',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Icon(
                    LucideIcons.circle,
                    size: 8,
                    color: _sharedStatuses[_selectedPortal] == true
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sharedStatuses[_selectedPortal] == true ? 'Shared with CA' : 'Not Shared',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _sharedStatuses[_selectedPortal] == true
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Save & Share Button
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _sharedStatuses[_selectedPortal] = true;
                });
                AppSnackbar.show(
                  context,
                  "$_selectedPortal credentials securely shared with your connected CA.",
                  type: SnackType.success,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save & Share $_selectedPortal with CA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Supported Portals Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('ℹ', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Compliance & Tax Portals Supported',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  title: 'Income Tax Portal:',
                  body: ' File income tax returns and view tax credits (Form 26AS/AIS).',
                ),
                SizedBox(height: 6),
                _InfoBullet(
                  title: 'TRACES Portal:',
                  body: ' Download official tax deduction (TDS) certificates.',
                ),
                SizedBox(height: 6),
                _InfoBullet(
                  title: 'MSFC / State GST Portals:',
                  body: ' Check state-level taxes or industrial loans if applicable.',
                ),
                SizedBox(height: 6),
                _InfoBullet(
                  title: 'MCA Portal:',
                  body: ' File company annual returns, ROC compliance & Director Identification (DIN).',
                ),
                SizedBox(height: 6),
                _InfoBullet(
                  title: 'EPFO / ESIC Portals:',
                  body: ' Employee Provident Fund & Social Security labor law compliance.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 4: Professional Service Payment History
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Text('💳', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professional Service Payment History',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Empty state placeholder container
          Container(
            height: 160,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'No payment history recorded yet.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final textCtrl = TextEditingController();
        return AlertDialog(
          title: const Row(
            children: [
              Icon(LucideIcons.messageSquare, size: 18, color: Color(0xFF166534)),
              SizedBox(width: 8),
              Text('Message beta@beta-softnet.com', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: textCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type your message to your FIN-PRO partner...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                AppSnackbar.show(
                  context,
                  "Message delivered to beta@beta-softnet.com",
                  type: SnackType.success,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String title;
  final String body;

  const _InfoBullet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          TextSpan(
            text: body,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
