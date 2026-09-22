import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  String _selectedPriority = 'Medium - Performance/Glitch';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer': 'To reset your password, click on your Profile dropdown in the top bar, go to Settings, and click "Reset Password". Alternatively, you can use the password recovery link on the login screen.'
    },
    {
      'question': 'Can I export my financial data?',
      'answer': 'Yes, you can export all accounting, sales, and expense ledgers into CSV, Excel, or PDF formats from the Reports tab under the Finance module.'
    },
    {
      'question': 'How do I add a new team member?',
      'answer': 'Go to the HR > Staff section from the Sidebar. Click on "Invite Staff", enter their email address, assign their role permissions, and send the invitation link.'
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Absolutely. Cliks Business encrypts all financial and personal databases in transit and at rest with military-grade AES-256 standard and complies with local data privacy regulations.'
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'Certain modules like POS Billing and Offline Cash Ledger support local offline database syncing. The system will automatically reconcile changes once connection is restored.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Back Button & Badge
            isMacOS
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkText),
                        onPressed: () {
                          ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Back to Dashboard',
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.hoverBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Text(
                          'Faq',
                          style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HELP CENTER',
                          style: TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkText),
                        onPressed: () {
                          ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Back to Dashboard',
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.hoverBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Text(
                          'Faq',
                          style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HELP CENTER',
                          style: TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            isMacOS
                ? const Text(
                    'Help & Customer Support',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  )
                : const Text(
                    'Help & Customer Support',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            isMacOS
                ? const Text(
                    'Access common guides or log direct tickets to our dedicated customer support squad.',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                  )
                : const Text(
                    'Access common guides or log direct tickets to our dedicated customer support squad.',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 32),

            // Main Columns
            if (isMobile)
              (isMacOS
                  ? Column(
                      children: [
                        _buildTicketForm(),
                        const SizedBox(height: 32),
                        _buildFaqSection(),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTicketForm(),
                        const SizedBox(height: 32),
                        _buildFaqSection(),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms))
            else
              (isMacOS
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildTicketForm()),
                        const SizedBox(width: 32),
                        Expanded(flex: 5, child: _buildFaqSection()),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildTicketForm()),
                        const SizedBox(width: 32),
                        Expanded(flex: 5, child: _buildFaqSection()),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms)),
          ],
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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.messageSquare, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Open a Support Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('ISSUE SUBJECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'e.g. Invoicing tax breakdown looks wrong',
              fillColor: AppColors.background.withValues(alpha: 0.5),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('SEVERITY PRIORITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 1)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedPriority,
            onChanged: (val) {
              if (val != null) setState(() => _selectedPriority = val);
            },
            decoration: InputDecoration(
              fillColor: AppColors.background.withValues(alpha: 0.5),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            ),
            items: [
              'Low - General Question',
              'Medium - Performance/Glitch',
              'High - Workflow Blocked',
              'Critical - System Outage',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
          ),
          const SizedBox(height: 20),
          const Text('DETAILED EXPLANATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Please describe exactly what you were doing, what went wrong, and how our support specialists can assist you.',
              fillColor: AppColors.background.withValues(alpha: 0.5),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support ticket lodged successfully!')),
                );
              },
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text('Lodge Support Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.helpCircle, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText, fontSize: 14),
                ),
                childrenPadding: const EdgeInsets.only(bottom: 16, top: 4, left: 16, right: 16),
                expandedAlignment: Alignment.topLeft,
                tilePadding: EdgeInsets.zero,
                iconColor: AppColors.primaryGreen,
                collapsedIconColor: AppColors.secondaryText,
                children: [
                  Text(
                    faq['answer']!,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
