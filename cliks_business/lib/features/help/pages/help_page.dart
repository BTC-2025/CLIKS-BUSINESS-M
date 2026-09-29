import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  String _selectedPriority = 'Medium - Performance/Glitch';
  final Set<int> _expandedFaqs = {};

  final List<Map<String, dynamic>> _tickets = [];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'To reset your password, click on your Profile dropdown in the top bar, go to Settings, and click "Reset Password". Alternatively, you can use the password recovery link on the login screen.',
    },
    {
      'question': 'Can I export my financial data?',
      'answer':
          'Yes, you can export all accounting, sales, and expense ledgers into CSV, Excel, or PDF formats from the Reports tab under the Finance module.',
    },
    {
      'question': 'How do I add a new team member?',
      'answer':
          'Go to the HR > Staff section from the Sidebar. Click on "Invite Staff", enter their email address, assign their role permissions, and send the invitation link.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Absolutely. Cliks Business encrypts all financial and personal databases in transit and at rest with military-grade AES-256 standard and complies with local data privacy regulations.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'Certain modules like POS Billing and Offline Cash Ledger support local offline database syncing. The system will automatically reconcile changes once connection is restored.',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _subjectController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  void _lodgeTicket() {
    final subject = _subjectController.text.trim();
    final explanation = _explanationController.text.trim();

    if (subject.isEmpty) {
      AppSnackbar.show(
        context,
        'Please enter an issue subject before lodging a ticket.',
        type: SnackType.warning,
      );
      return;
    }

    setState(() {
      _tickets.insert(0, {
        'id': '#TKT-${1000 + _tickets.length}',
        'subject': subject,
        'priority': _selectedPriority,
        'explanation': explanation,
        'date': 'Today',
      });
      _subjectController.clear();
      _explanationController.clear();
    });

    AppSnackbar.show(
      context,
      'Support ticket lodged successfully! Ticket ${_tickets.first['id']} has been created.',
      type: SnackType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      primary: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: _scrollController,
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.all(paddingVal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Pill Badge: HELP CENTER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'HELP CENTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  'Help & Customer Support',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Access common guides or log direct tickets to our dedicated customer support squad.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 32),

                // Two-column layout matching design
                if (isMobile)
                  Column(
                    children: [
                      _buildTicketForm(),
                      const SizedBox(height: 24),
                      _buildSupportLogCard(),
                      const SizedBox(height: 24),
                      _buildFaqCard(),
                      const SizedBox(height: 24),
                      _buildDirectSupportCard(),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildTicketForm(),
                            const SizedBox(height: 24),
                            _buildSupportLogCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildFaqCard(),
                            const SizedBox(height: 24),
                            _buildDirectSupportCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF2E4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.messageSquare,
                    color: Color(0xFF166534),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Open a Support Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Issue Subject
          const Text(
            'ISSUE SUBJECT',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: TextField(
              controller: _subjectController,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: 'e.g. Invoicing tax breakdown looks wrong',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Severity Priority
          const Text(
            'SEVERITY PRIORITY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
              icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF166534), size: 16),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF166534),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                ),
              ),
              dropdownColor: Colors.white,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
              items: [
                'Low - General Question',
                'Medium - Performance/Glitch',
                'High - Workflow Blocked',
                'Critical - System Outage',
              ].map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: p == 'Medium - Performance/Glitch'
                          ? const Color(0xFF166534)
                          : const Color(0xFF111827),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Detailed Explanation
          const Text(
            'DETAILED EXPLANATION',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: TextField(
              controller: _explanationController,
              maxLines: 4,
              scrollPhysics: const ClampingScrollPhysics(),
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText:
                    'Please describe exactly what you were doing, what went wrong, and how our support specialists can assist you.',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), height: 1.4),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _lodgeTicket,
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text(
                'Lodge Support Ticket',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportLogCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.activity,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Support Log',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_tickets.length} logged',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_tickets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No filed tickets detected in your system history.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            Column(
              children: _tickets.map((t) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCF2E4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t['id'] ?? '#TKT',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['subject'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              '${t['priority']} • ${t['date']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Under Review',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
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

  Widget _buildFaqCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.helpCircle,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_faqs.length, (index) {
            final faq = _faqs[index];
            final isLast = index == _faqs.length - 1;
            final isExpanded = _expandedFaqs.contains(index);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedFaqs.remove(index);
                      } else {
                        _expandedFaqs.add(index);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            LucideIcons.chevronDown,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 2, right: 16),
                    child: Text(
                      faq['answer']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState:
                      isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDirectSupportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF166534),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.mail,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Direct Support Coordinates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Need instant answers or have specialized billing queries? Get in touch directly via our channels below:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildCoordinateTile(
                icon: LucideIcons.mail,
                label: 'EMAIL SUPPORT',
                value: 'support@beta-softnet.com',
              ),
              const SizedBox(height: 12),
              _buildCoordinateTile(
                icon: LucideIcons.globe,
                label: 'OFFICIAL PORTAL',
                value: 'beta-softnet.com',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
