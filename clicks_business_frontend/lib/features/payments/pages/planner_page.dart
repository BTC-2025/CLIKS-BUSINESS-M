import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/schedule_payment_dialog.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  int _activeFilter = 0; // 0: All, 1: Send, 2: Receive
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // State List of Scheduled Payments matching screenshot defaults
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 'sched_1',
      'name': 'rahul',
      'amount': 1000.0,
      'isSend': false, // TO RECEIVE
      'date': '8/7/2026',
      'status': 'PENDING',
      'description': 'Freelance settlement',
    },
    {
      'id': 'sched_2',
      'name': 'Ravi',
      'amount': 5000.0,
      'isSend': true, // TO SEND
      'date': '8/7/2026',
      'status': 'PENDING',
      'description': 'Vendor invoice payment',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculated Real-Time Aggregates
  int get _totalScheduled => _schedules.length;

  double get _totalToSend => _schedules
      .where((s) => s['isSend'] == true && s['status'] == 'PENDING')
      .fold(0.0, (sum, s) => sum + (s['amount'] as num).toDouble());

  double get _totalToReceive => _schedules
      .where((s) => s['isSend'] == false && s['status'] == 'PENDING')
      .fold(0.0, (sum, s) => sum + (s['amount'] as num).toDouble());

  int get _pendingTasks => _schedules.where((s) => s['status'] == 'PENDING').length;

  List<Map<String, dynamic>> get _filteredSchedules {
    return _schedules.where((s) {
      final matchesFilter = () {
        if (_activeFilter == 1) return s['isSend'] == true;
        if (_activeFilter == 2) return s['isSend'] == false;
        return true;
      }();

      if (!matchesFilter) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final name = (s['name'] as String).toLowerCase();
      final date = (s['date'] as String).toLowerCase();
      final amt = (s['amount'] as num).toString().toLowerCase();

      return name.contains(q) || date.contains(q) || amt.contains(q);
    }).toList();
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
                onPressed: _openScheduleDialog,
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, 20, paddingVal, isMobile ? 90 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 24),

            // Tabs and Search Row
            _buildTabsAndSearchRow(isMobile).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 20),

            // Scheduled Payment Cards List / Empty State
            if (_filteredSchedules.isEmpty)
              _buildEmptyStateCard(context, isMobile).animate().fadeIn(duration: 450.ms)
            else
              _buildSchedulesList(context, isMobile).animate().fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final scheduleBtn = ElevatedButton.icon(
      onPressed: _openScheduleDialog,
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text('Schedule', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F5B2E),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      'TOTAL SCHEDULED',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalScheduled',
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
              if (!isMobile) scheduleBtn,
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroChip('To Send', '₹ ${_fmt(_totalToSend)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('To Receive', '₹ ${_fmt(_totalToReceive)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Pending Tasks', '$_pendingTasks', isMobile),
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

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.hoverBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.calendarDays, color: AppColors.primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Planner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText), overflow: TextOverflow.ellipsis),
                        Text('Transfers & Collections', style: TextStyle(fontSize: 11, color: AppColors.secondaryText), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _openScheduleDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Schedule', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.hoverBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.calendarDays, color: AppColors.primaryGreen, size: 22),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Planner', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              SizedBox(height: 4),
              Text('Schedule and manage upcoming transfers and collections with ease.', style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton.icon(
          onPressed: _openScheduleDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Schedule Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  void _openScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => SchedulePaymentDialog(
        onScheduled: (newItem) {
          setState(() {
            _schedules.add(newItem);
          });
          AppSnackbar.show(
            context,
            "Payment for '${newItem['name']}' scheduled successfully!",
            type: SnackType.success,
          );
        },
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, bool isMobile) {
    final cardsData = [
      {
        'label': 'TOTAL SCHEDULED',
        'value': '$_totalScheduled',
        'icon': LucideIcons.calendar,
        'color': AppColors.primaryGreen,
        'bgColor': const Color(0xFFECFDF5),
      },
      {
        'label': 'TO SEND',
        'value': '₹${_fmt(_totalToSend)}',
        'icon': LucideIcons.arrowUpRight,
        'color': const Color(0xFFEF4444),
        'bgColor': const Color(0xFFFEF2F2),
      },
      {
        'label': 'TO RECEIVE',
        'value': '₹${_fmt(_totalToReceive)}',
        'icon': LucideIcons.arrowDownLeft,
        'color': const Color(0xFF059669),
        'bgColor': const Color(0xFFECFDF5),
      },
      {
        'label': 'PENDING TASK',
        'value': '$_pendingTasks',
        'icon': LucideIcons.clock,
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFFFBEB),
      },
    ];

    final cardWidgets = cardsData.map((c) {
      final iconColor = c['color'] as Color;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c['label'] as String,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(c['icon'] as IconData, color: iconColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                c['value'] as String,
                style: TextStyle(color: AppColors.darkText, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cardWidgets[0]),
              const SizedBox(width: 12),
              Expanded(child: cardWidgets[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cardWidgets[2]),
              const SizedBox(width: 12),
              Expanded(child: cardWidgets[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: cardWidgets.map((c) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: c,
        ),
      )).toList(),
    );
  }

  void _openEditDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => SchedulePaymentDialog(
        initialData: item,
        onScheduled: (updatedItem) {
          setState(() {
            final idx = _schedules.indexWhere((s) => s['id'] == item['id']);
            if (idx != -1) {
              _schedules[idx] = updatedItem;
            }
          });
          AppSnackbar.show(
            context,
            "Payment for '${updatedItem['name']}' updated successfully!",
            type: SnackType.success,
          );
        },
      ),
    );
  }

  Widget _buildTabsAndSearchRow(bool isMobile) {
    final tabs = ['All', 'Send', 'Receive'];

    final icons = [LucideIcons.list, LucideIcons.arrowUpRight, LucideIcons.arrowDownLeft];

    final tabsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(tabs.length, (index) {
          final isActive = _activeFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeFilter = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF166534) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFE5E7EB)),
                  boxShadow: isActive ? [BoxShadow(color: const Color(0xFF166534).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[index], size: 14, color: isActive ? Colors.white : const Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: isActive ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // Edit Tabs Icon Button
        Tooltip(
          message: 'Edit tabs & views',
          child: InkWell(
            onTap: () {
              AppSnackbar.show(
                context,
                "Custom filter views and tabs editor",
                type: SnackType.info,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.pencil, size: 14, color: AppColors.secondaryText),
            ),
          ),
        ),
      ],
    );

    final searchBar = Container(
      width: isMobile ? double.infinity : 280,
      height: 42,
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
                hintText: 'Search schedules...',
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
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
          const SizedBox(height: 14),
          searchBar,
        ],
      );
    }

    return Row(
      children: [
        tabsRow,
        const Spacer(),
        searchBar,
      ],
    );
  }

  Widget _buildSchedulesList(BuildContext context, bool isMobile) {
    return Column(
      children: _filteredSchedules.map((item) {
        final isSend = item['isSend'] == true;
        final isCompleted = item['status'] == 'COMPLETED';
        final color = isSend ? const Color(0xFFEF4444) : const Color(0xFF059669);
        final bgColor = isSend ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
        final icon = isSend ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft;

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
          child: isMobile
              ? Column(
                  children: [
                    // Top Row: Icon + Name & Date + Amount
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.grey.shade500 : AppColors.darkText,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  decorationColor: Colors.grey.shade400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 11, color: AppColors.secondaryText),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['date'] as String,
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'AMOUNT',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.3),
                            ),
                            Text(
                              '₹${_fmt((item['amount'] as num).toDouble())}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),

                    // Bottom Row: PENDING Badge + Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? const Color(0xFF047857) : const Color(0xFF15803D),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  item['status'] = (item['status'] == 'PENDING') ? 'COMPLETED' : 'PENDING';
                                });
                                AppSnackbar.show(
                                  context,
                                  item['status'] == 'COMPLETED'
                                      ? "Payment for '${item['name']}' marked as Completed!"
                                      : "Payment for '${item['name']}' reset to Pending.",
                                  type: SnackType.success,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCompleted ? LucideIcons.checkCheck : LucideIcons.check,
                                      color: const Color(0xFF16A34A),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isCompleted ? 'Done' : 'Mark Paid',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Edit Button
                            InkWell(
                              onTap: () => _openEditDialog(item),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF93C5FD)),
                                ),
                                child: const Icon(LucideIcons.pencil, color: Color(0xFF2563EB), size: 14),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                final name = item['name'];
                                setState(() {
                                  _schedules.removeWhere((s) => s['id'] == item['id']);
                                });
                                AppSnackbar.show(
                                  context,
                                  "Schedule for '$name' deleted.",
                                  type: SnackType.info,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFCA5A5)),
                                ),
                                child: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Direction Icon Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),

                    // Name & Status Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.grey.shade500 : AppColors.darkText,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.clock, size: 12, color: AppColors.secondaryText),
                              const SizedBox(width: 4),
                              Text(
                                item['date'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['status'] as String,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? const Color(0xFF047857) : const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Amount & Action Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'AMOUNT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_fmt((item['amount'] as num).toDouble())}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Action Buttons Row (Mark Done & Delete)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle Status Button
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF0FDF4),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Icon(
                              isCompleted ? LucideIcons.checkCheck : LucideIcons.check,
                              color: const Color(0xFF16A34A),
                              size: 16,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              item['status'] = (item['status'] == 'PENDING') ? 'COMPLETED' : 'PENDING';
                            });
                            AppSnackbar.show(
                              context,
                              item['status'] == 'COMPLETED'
                                  ? "Payment for '${item['name']}' marked as Completed!"
                                  : "Payment for '${item['name']}' reset to Pending.",
                              type: SnackType.success,
                            );
                          },
                        ),
                        const SizedBox(width: 4),

                        // Edit Button
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Icon(LucideIcons.pencil, color: Color(0xFF2563EB), size: 16),
                          ),
                          onPressed: () => _openEditDialog(item),
                        ),
                        const SizedBox(width: 4),

                        // Delete Button
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 16),
                          ),
                          onPressed: () {
                            final name = item['name'];
                            setState(() {
                              _schedules.removeWhere((s) => s['id'] == item['id']);
                            });
                            AppSnackbar.show(
                              context,
                              "Schedule for '$name' deleted.",
                              type: SnackType.info,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
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
            decoration: const BoxDecoration(
              color: AppColors.hoverBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.calendar, color: AppColors.secondaryText, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Scheduled Payments Found',
            style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Click + Schedule below to create your first scheduled transfer.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _fmt(double val) {
    return val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
