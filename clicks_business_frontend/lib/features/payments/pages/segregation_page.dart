import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/setup_target_wallet_dialog.dart';
import '../../../widgets/app_ui_kit.dart';

class SegregationPage extends StatefulWidget {
  const SegregationPage({super.key});

  @override
  State<SegregationPage> createState() => _SegregationPageState();
}

class _SegregationPageState extends State<SegregationPage> {
  final List<Map<String, dynamic>> _wallets = [
    {
      'id': '1',
      'title': 'pen',
      'status': 'TARGET MET',
      'statusColor': const Color(0xFFE11D48),
      'saved': 50000.0,
      'target': 50000.0,
      'notes': 'see',
      'isClaimed': false,
    },
    {
      'id': '2',
      'title': 'future stock',
      'status': 'FULLY CLAIMED',
      'statusColor': const Color(0xFF3B82F6),
      'saved': 401000.0,
      'target': 50000.0,
      'notes': 'going to buy future stocks',
      'isClaimed': true,
    },
  ];

  void _addNewWallet(Map<String, dynamic> wallet) {
    setState(() {
      _wallets.add(wallet);
    });
    AppSnackbar.show(
      context,
      "New purpose wallet '${wallet['title']}' created successfully!",
      type: SnackType.success,
    );
  }

  void _showConfirmClaimSheet(int index) {
    final wallet = _wallets[index];
    final title = wallet['title'] as String;
    final savedFormatted = (wallet['saved'] as double).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Warning Icon Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
              ),
              child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(height: 16),

            const Text(
              'Please Confirm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
            const SizedBox(height: 12),

            Text(
              'Extract ₹$savedFormatted accumulated for "$title" into main reserves?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 28),

            // Buttons (Cancel & Confirm)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5EAF4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        wallet['isClaimed'] = true;
                        wallet['status'] = 'FULLY CLAIMED';
                        wallet['statusColor'] = const Color(0xFF3B82F6);
                      });
                      Navigator.pop(ctx);
                      AppSnackbar.show(
                        context,
                        "Successfully extracted ₹$savedFormatted accumulated for \"$title\" into main reserves!",
                        type: SnackType.success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openAddCashDialog(int index) {
    final wallet = _wallets[index];
    final controller = TextEditingController(text: '1000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Cash to ${wallet['title']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final added = double.tryParse(controller.text.trim()) ?? 0;
                  if (added > 0) {
                    setState(() {
                      wallet['saved'] = (wallet['saved'] as double) + added;
                      final saved = wallet['saved'] as double;
                      final target = wallet['target'] as double;
                      if (saved >= target && wallet['isClaimed'] != true) {
                        wallet['status'] = 'TARGET MET';
                        wallet['statusColor'] = const Color(0xFFE11D48);
                      }
                    });
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Deposit Cash', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openEditWalletDialog(int index) {
    final wallet = _wallets[index];
    final titleController = TextEditingController(text: wallet['title'] as String);
    final targetController = TextEditingController(text: (wallet['target'] as double).toInt().toString());
    final notesController = TextEditingController(text: wallet['notes'] as String);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Purpose Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 20),

              const Text('PURPOSE / ITEM NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A7184))),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('TARGET CAP AMOUNT (INR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A7184))),
              const SizedBox(height: 6),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('DESCRIPTIVE NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A7184))),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: AppColors.darkText),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final newTitle = titleController.text.trim();
                    final newTarget = double.tryParse(targetController.text.trim()) ?? (wallet['target'] as double);
                    final newNotes = notesController.text.trim();

                    if (newTitle.isNotEmpty) {
                      setState(() {
                        wallet['title'] = newTitle;
                        wallet['target'] = newTarget;
                        wallet['notes'] = newNotes;
                        final saved = wallet['saved'] as double;
                        if (saved >= newTarget && wallet['isClaimed'] != true) {
                          wallet['status'] = 'TARGET MET';
                          wallet['statusColor'] = const Color(0xFFE11D48);
                        } else if (saved < newTarget) {
                          wallet['status'] = 'GROWING';
                          wallet['statusColor'] = const Color(0xFF10B981);
                          wallet['isClaimed'] = false;
                        }
                      });
                      AppSnackbar.show(
                        context,
                        "Purpose wallet '$newTitle' updated successfully!",
                        type: SnackType.success,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084421),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteWallet(int index) {
    final title = _wallets[index]['title'] as String;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Purpose Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$title'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _wallets.removeAt(index);
              });
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                "Purpose wallet '$title' deleted.",
                type: SnackType.info,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
                  );
                },
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Setup Purpose Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Summary (Gradient Stats & Actions)
            _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 24),

            // Purpose Wallets List or Empty State
            if (_wallets.isEmpty)
              _buildEmptyStateCard(context, isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms)
            else
              _buildWalletCardsSection(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),

            const SizedBox(height: 28),

            // Financial Goals Section
            _buildFinancialGoalsCard(isMobile).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final double totalSaved = _wallets.fold(0.0, (sum, item) => sum + (item['saved'] as double));
    final double totalTarget = _wallets.fold(0.0, (sum, item) => sum + (item['target'] as double));
    final int accomplishment = totalTarget > 0 ? ((totalSaved / totalTarget) * 100).toInt() : 0;

    final setupWalletBtn = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
        );
      },
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text('Setup Purpose Wallet', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F5B2E),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL ISOLATED FUNDS',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${totalSaved.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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
              if (!isMobile) setupWalletBtn,
            ],
          ),
          const SizedBox(height: 16),
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Goal Target', '₹ ${totalTarget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Target Accomp.', '$accomplishment%', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Active Wallets', '${_wallets.length}', isMobile),
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

  Widget _buildWalletCardsSection(bool isMobile) {
    final cardWidgets = _wallets.asMap().entries.map((entry) {
      final index = entry.key;
      final w = entry.value;
      final isClaimed = w['isClaimed'] == true;
      final saved = w['saved'] as double;
      final target = w['target'] as double;
      final isTargetMet = saved >= target;

      final String statusText;
      final Color statusColor;
      final Color statusBgColor;

      if (isClaimed) {
        statusText = 'FULLY CLAIMED';
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFDBEAFE);
      } else if (isTargetMet) {
        statusText = 'TARGET MET';
        statusColor = const Color(0xFFE11D48);
        statusBgColor = const Color(0xFFFCE7F3);
      } else {
        statusText = 'GROWING';
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
      }

      final percent = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
      final percentDisplay = (percent * 100).toInt();

      return Container(
        padding: const EdgeInsets.all(20),
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
            // Top Accent Bar
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w['title'] as String,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.history, size: 18, color: AppColors.secondaryText),
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      "Wallet transaction history loaded.",
                      type: SnackType.info,
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.secondaryText),
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditWalletDialog(index);
                    } else if (value == 'delete') {
                      _deleteWallet(index);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil, size: 16, color: Color(0xFF10B981)),
                          SizedBox(width: 12),
                          Text(
                            'Edit Wallet',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              w['notes'] as String,
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Allocation Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.hoverBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saved Allocated', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      Text(
                        '₹${saved.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Ceiling', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      Text(
                        '₹${target.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Goal Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Goal Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                Text('$percentDisplay%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: AppColors.hoverBackground,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 20),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddCashDialog(index),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('Add Cash', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                      foregroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isClaimed
                      ? OutlinedButton.icon(
                          onPressed: () {
                            AppSnackbar.show(
                              context,
                              "This goal has already been extracted into main reserves.",
                              type: SnackType.info,
                            );
                          },
                          icon: const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF10B981)),
                          label: const Text(
                            'Claimed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            side: const BorderSide(color: Color(0xFFE5EAF4)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      : isTargetMet
                          ? ElevatedButton(
                              onPressed: () => _showConfirmClaimSheet(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC05621), // Brown/orange filled button like Image 1
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Claim Goal!',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {
                                AppSnackbar.show(
                                  context,
                                  "Accumulate ₹${(target - saved).toInt()} more to unlock goal extraction.",
                                  type: SnackType.info,
                                );
                              },
                              icon: const Icon(LucideIcons.lock, size: 14),
                              label: const Text(
                                'Locked',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondaryText,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();

    if (isMobile) {
      return Column(
        children: cardWidgets
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: c,
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 2;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: cardWidgets
              .map((c) => SizedBox(
                    width: cardWidth,
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildFinancialGoalsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.target, color: Colors.purple.shade600, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Goals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your long-term milestones',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SetupTargetWalletDialog(
                  onWalletCreated: _addNewWallet,
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.purple.shade50,
              foregroundColor: Colors.purple.shade700,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.wallet, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Segregated Wallets',
            style: TextStyle(color: AppColors.darkText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: const Text(
              'Setup isolated purpose-driven buckets! For example, reserve money sequentially to buy future equipment, specialized stationery, or tax deposits.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SetupTargetWalletDialog(
                  onWalletCreated: _addNewWallet,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text(
              'Create First Segregated Wallet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
