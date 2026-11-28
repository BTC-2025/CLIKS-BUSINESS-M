import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../widgets/calculator/beta_calculator.dart';
import '../../../core/navigation/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bit_tool_provider.dart';
import '../../../data/account_provider.dart';

class UtilityRailState {
  final int displayState; // 0 = Closed (C only), 1 = Show pinned, 2 = Show all
  final bool isEditing;
  final String? expandedTab;
  final Set<String> pinnedUtilityNames;

  UtilityRailState({
    this.displayState = 1,
    this.isEditing = false,
    this.expandedTab,
    Set<String>? pinnedUtilityNames,
  }) : pinnedUtilityNames =
           pinnedUtilityNames ??
           {'Calculator', 'Calendar', 'Contacts', 'Notes', 'Shortcuts', 'Weather'};

  UtilityRailState copyWith({
    int? displayState,
    bool? isEditing,
    String? expandedTab,
    Set<String>? pinnedUtilityNames,
    bool clearExpandedTab = false,
  }) {
    return UtilityRailState(
      displayState: displayState ?? this.displayState,
      isEditing: isEditing ?? this.isEditing,
      expandedTab: clearExpandedTab ? null : (expandedTab ?? this.expandedTab),
      pinnedUtilityNames: pinnedUtilityNames ?? this.pinnedUtilityNames,
    );
  }
}

class UtilityRailNotifier extends StateNotifier<UtilityRailState> {
  UtilityRailNotifier() : super(UtilityRailState());

  void setDisplayState(int stateVal) {
    state = state.copyWith(displayState: stateVal);
  }

  void setIsEditing(bool editing) {
    state = state.copyWith(isEditing: editing);
  }

  void setExpandedTab(String? tab) {
    if (tab == null) {
      state = state.copyWith(clearExpandedTab: true);
    } else {
      state = state.copyWith(expandedTab: tab);
    }
  }

  void togglePin(String name) {
    final updated = Set<String>.from(state.pinnedUtilityNames);
    if (updated.contains(name)) {
      if (updated.length > 1) {
        updated.remove(name);
      }
    } else {
      updated.add(name);
    }
    state = state.copyWith(pinnedUtilityNames: updated);
  }
}

final utilityRailProvider =
    StateNotifierProvider<UtilityRailNotifier, UtilityRailState>((ref) {
      return UtilityRailNotifier();
    });

class SidebarUtilityRail extends ConsumerStatefulWidget {
  const SidebarUtilityRail({super.key});

  @override
  ConsumerState<SidebarUtilityRail> createState() => _SidebarUtilityRailState();
}

class _SidebarUtilityRailState extends ConsumerState<SidebarUtilityRail> {
  DateTime _selectedCalendarDate = DateTime.now();

  final List<Map<String, String>> _shortcuts = [
    {'keys': 'Ctrl + I', 'action': 'New Invoice'},
    {'keys': 'Ctrl + P', 'action': 'Payment Setup'},
    {'keys': 'Shift + S', 'action': 'Split Billing'},
  ];

  late final TextEditingController _noteInputController;

  bool _logoLoaded = false;
  File? _logoFile;

  @override
  void initState() {
    super.initState();
    _noteInputController = TextEditingController();
    _loadCustomLogo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(bitToolContactsProvider.notifier).loadContacts();
        ref.read(bitToolNotesProvider.notifier).loadNotes();
        ref.read(bitToolCalendarProvider.notifier).loadForMonth(_selectedCalendarDate);
        ref.read(bitToolCalculatorProvider.notifier).loadSessions();
      }
    });
  }

  void _loadCustomLogo() {
    try {
      final srcFile = File('assets/bit_tool_logo.png');
      final destFile = File('user_logo.png');

      if (srcFile.existsSync()) {
        destFile.writeAsBytesSync(srcFile.readAsBytesSync());
        setState(() {
          _logoFile = destFile;
          _logoLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }
  }

  @override
  void dispose() {
    _noteInputController.dispose();
    super.dispose();
  }

  Widget _buildUtilityIconBtn(Map<String, dynamic> item, bool isPinned) {
    final railState = ref.watch(utilityRailProvider);
    final isEditingUtilities = railState.isEditing;
    final expandedUtilityTab = railState.expandedTab;
    final String label = item['label'] as String;
    final bool isActive = expandedUtilityTab == label;
    final Color itemColor = item['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Tooltip(
            message: label,
            child: AnimatedScale(
              scale: isActive ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isActive
                        ? [
                            itemColor.withValues(alpha: 0.24),
                            itemColor.withValues(alpha: 0.06),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                  ),
                  border: Border.all(
                    color: isActive
                        ? itemColor
                        : Colors.white.withValues(alpha: 0.15),
                    width: isActive ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: itemColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    if (isEditingUtilities) {
                      ref.read(utilityRailProvider.notifier).togglePin(label);
                    } else {
                      ref
                          .read(utilityRailProvider.notifier)
                          .setExpandedTab(
                            expandedUtilityTab == label ? null : label,
                          );
                    }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Icon(
                      item['icon'] as IconData,
                      size: isActive ? 14 : 13,
                      color: isActive
                          ? itemColor
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isEditingUtilities && isPinned)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 8, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeAccountProvider, (prev, next) {
      if (prev?.email != next.email || prev?.id != next.id) {
        ref.invalidate(bitToolApiModuleProvider);
        ref.invalidate(bitToolContactsProvider);
        ref.invalidate(bitToolNotesProvider);
        ref.invalidate(bitToolCalendarProvider);
        ref.invalidate(bitToolCalculatorProvider);
        ref.invalidate(bitToolConnectionProvider);
      }
    });

    final railState = ref.watch(utilityRailProvider);
    final utilityDisplayState = railState.displayState;
    final isEditingUtilities = railState.isEditing;
    final expandedUtilityTab = railState.expandedTab;

    final pinnedUtilityNames = railState.pinnedUtilityNames;

    final List<Map<String, dynamic>> utilities = [
      {
        'icon': LucideIcons.calculator,
        'color': const Color(0xFF27AE60),
        'label': 'Calculator',
      },
      {
        'icon': LucideIcons.calendar,
        'color': const Color(0xFFF2994A),
        'label': 'Calendar',
      },
      {
        'icon': LucideIcons.contact,
        'color': const Color(0xFF2F80ED),
        'label': 'Contacts',
      },
      {
        'icon': LucideIcons.stickyNote,
        'color': const Color(0xFFDB2777),
        'label': 'Notes',
      },
      {
        'icon': LucideIcons.keyboard,
        'color': const Color(0xFF9B51E0),
        'label': 'Shortcuts',
      },
      {
        'icon': LucideIcons.cloudSun,
        'color': const Color(0xFF0284C7),
        'label': 'Weather',
      },
    ];

    final List<Map<String, dynamic>> displayList = [];
    if (isEditingUtilities) {
      displayList.addAll(utilities);
    } else {
      for (final u in utilities) {
        if (pinnedUtilityNames.contains(u['label'])) {
          displayList.add(u);
        }
      }
      if (displayList.isEmpty) {
        displayList.addAll(utilities);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Rail Bar - Aligned flush with compact margin
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Brand 'C' Toggle Logo Button
                GestureDetector(
                  onTap: () {
                    if (utilityDisplayState == 0) {
                      ref.read(utilityRailProvider.notifier).setDisplayState(1);
                    } else {
                      ref.read(utilityRailProvider.notifier).setDisplayState(0);
                      ref
                          .read(utilityRailProvider.notifier)
                          .setExpandedTab(null);
                      ref
                          .read(utilityRailProvider.notifier)
                          .setIsEditing(false);
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: kIsWeb
                        ? Image.network(
                            'user_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/bit_tool_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text(
                                      'C',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : (_logoLoaded && _logoFile != null
                              ? Image.file(
                                  _logoFile!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'C',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/bit_tool_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'C',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                )),
                  ),
                ),
                const SizedBox(width: 8),
                ...displayList.map(
                  (item) => _buildUtilityIconBtn(
                    item,
                    railState.pinnedUtilityNames.contains(item['label']),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: isEditingUtilities ? 'Done' : 'Add Utility',
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isEditingUtilities
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Color(0xFFF3F4F6)],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.04),
                              ],
                            ),
                      border: Border.all(
                        color: isEditingUtilities
                            ? AppColors.border.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                      boxShadow: [
                        if (isEditingUtilities)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(utilityRailProvider.notifier)
                            .setIsEditing(!isEditingUtilities);
                        ref
                            .read(utilityRailProvider.notifier)
                            .setDisplayState(isEditingUtilities ? 1 : 2);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Center(
                        child: Icon(
                          isEditingUtilities
                              ? LucideIcons.check
                              : LucideIcons.plus,
                          size: 16,
                          color: isEditingUtilities
                              ? AppColors.primaryGreen
                              : Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sliding Detail Panel
        if (expandedUtilityTab != null)
          (Theme.of(context).platform == TargetPlatform.macOS
              ? _buildSlidingTabPanel()
              : _buildSlidingTabPanel()
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: -0.05, end: 0)),
      ],
    );
  }

  Widget _buildSlidingTabPanel() {
    final railState = ref.read(utilityRailProvider);
    final expandedUtilityTab = railState.expandedTab;
    if (expandedUtilityTab == null) return const SizedBox.shrink();

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    Widget content;
    switch (expandedUtilityTab) {
      case 'Calculator':
        content = _buildCalculatorTab();
        break;
      case 'Calendar':
        content = _buildCalendarTab();
        break;
      case 'Contacts':
        content = _buildContactsTab();
        break;
      case 'Notes':
      case 'Messages':
        content = _buildNotesTab();
        break;
      case 'Shortcuts':
        content = _buildShortcutsTab();
        break;
      case 'Weather':
        content = _buildWeatherTab();
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expandedUtilityTab == 'Messages' ? 'Notes' : expandedUtilityTab,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.darkText,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMacOS && expandedUtilityTab == 'Calculator') ...[
                    Tooltip(
                      message: 'Split Screen View',
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).maybePop();
                          ref.read(utilityRailProvider.notifier).setExpandedTab(null);
                          ref.read(mobileCalculatorSplitScreenProvider.notifier).state = true;
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.splitscreen_rounded,
                                size: 13,
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Split',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  GestureDetector(
                    onTap: () =>
                        ref.read(utilityRailProvider.notifier).setExpandedTab(null),
                    child: const Icon(LucideIcons.x, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          content,
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return const BetaCalculator();
  }

  Widget _buildCalendarTab() {
    final calendarState = ref.watch(bitToolCalendarProvider);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthLabel = "${months[_selectedCalendarDate.month - 1]} ${_selectedCalendarDate.year}";
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedCalendarDate.year,
      _selectedCalendarDate.month,
    );
    final firstWeekday = DateTime(
      _selectedCalendarDate.year,
      _selectedCalendarDate.month,
      1,
    ).weekday;
    final totalCells = ((firstWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;
    final totalWeeks = totalCells ~/ 7;

    final dayEvents = calendarState.events.where((e) =>
      e.startTime.year == _selectedCalendarDate.year &&
      e.startTime.month == _selectedCalendarDate.month &&
      e.startTime.day == _selectedCalendarDate.day
    ).toList();

    String eventText = 'No business scheduled for today.';
    if (dayEvents.isNotEmpty) {
      final ev = dayEvents.first;
      final hr = ev.startTime.hour % 12 == 0 ? 12 : ev.startTime.hour % 12;
      final mn = ev.startTime.minute.toString().padLeft(2, '0');
      final ampm = ev.startTime.hour >= 12 ? 'PM' : 'AM';
      eventText = '${ev.title} @ $hr:$mn $ampm';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final prevMonth = DateTime(
                      _selectedCalendarDate.year,
                      _selectedCalendarDate.month - 1,
                      1,
                    );
                    setState(() => _selectedCalendarDate = prevMonth);
                    ref.read(bitToolCalendarProvider.notifier).loadForMonth(prevMonth);
                  },
                  child: const Icon(LucideIcons.chevronLeft, size: 14, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final nextMonth = DateTime(
                      _selectedCalendarDate.year,
                      _selectedCalendarDate.month + 1,
                      1,
                    );
                    setState(() => _selectedCalendarDate = nextMonth);
                    ref.read(bitToolCalendarProvider.notifier).loadForMonth(nextMonth);
                  },
                  child: const Icon(LucideIcons.chevronRight, size: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays
              .map(
                (w) => SizedBox(
                  width: 28,
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Column(
          children: List.generate(totalWeeks > 5 ? 5 : totalWeeks, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  final dayNumber = cellIndex - (firstWeekday - 1) + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 28, height: 28);
                  }

                  final isSelected = _selectedCalendarDate.day == dayNumber &&
                      _selectedCalendarDate.month == calendarState.selectedDate.month &&
                      _selectedCalendarDate.year == calendarState.selectedDate.year;

                  final hasEventOnDay = calendarState.events.any((e) =>
                    e.startTime.year == _selectedCalendarDate.year &&
                    e.startTime.month == _selectedCalendarDate.month &&
                    e.startTime.day == dayNumber
                  );

                  return GestureDetector(
                    onTap: () {
                      final selected = DateTime(
                        _selectedCalendarDate.year,
                        _selectedCalendarDate.month,
                        dayNumber,
                      );
                      setState(() {
                        _selectedCalendarDate = selected;
                      });
                      ref.read(bitToolCalendarProvider.notifier).selectDate(selected);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (hasEventOnDay
                                  ? Colors.amber.shade400
                                  : Colors.grey.shade200),
                          width: hasEventOnDay ? 1.2 : 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : (hasEventOnDay ? FontWeight.bold : FontWeight.normal),
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Divider(height: 8, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: dayEvents.isNotEmpty ? Colors.amber : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  eventText,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsTab() {
    final contactsState = ref.watch(bitToolContactsProvider);

    if (contactsState.isLoading && contactsState.contacts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      );
    }

    final contactsList = contactsState.filteredContacts.isNotEmpty
        ? contactsState.filteredContacts
        : contactsState.contacts;

    if (contactsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            const Text(
              'No contacts in BitTool directory.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => ref.read(bitToolContactsProvider.notifier).loadContacts(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.refreshCw, size: 11, color: AppColors.primaryGreen),
                  SizedBox(width: 4),
                  Text(
                    'Sync Contacts',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: contactsList.take(5).map((c) {
        final initial = (c.fullName.isNotEmpty
                ? c.fullName[0]
                : (c.email.isNotEmpty ? c.email[0] : '?'))
            .toUpperCase();
        final name = c.fullName.isNotEmpty
            ? c.fullName
            : (c.email.isNotEmpty ? c.email : 'Contact');
        final subtitle = c.email.isNotEmpty
            ? c.email
            : (c.phone.isNotEmpty ? c.phone : c.role);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.hoverBackground,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.messageSquare,
                  size: 13,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesTab() {
    final notesState = ref.watch(bitToolNotesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notesState.isLoading && notesState.notes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          )
        else if (notesState.notes.isNotEmpty)
          ...notesState.notes.take(4).map((n) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFFCE7F3),
                    child: Text(
                      n.title.isNotEmpty ? n.title[0].toUpperCase() : 'N',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDB2777),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          n.content.isNotEmpty ? n.content : 'No details',
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(bitToolNotesProvider.notifier).deleteNote(n.id),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          })
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFFCE7F3),
                  child: Text(
                    'N',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDB2777),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BitTool Notes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'No saved notes yet.',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteInputController,
                  style: const TextStyle(fontSize: 10),
                  decoration: const InputDecoration(
                    hintText: 'Add a quick note...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (val) {
                    final txt = val.trim();
                    if (txt.isNotEmpty) {
                      ref.read(bitToolNotesProvider.notifier).createNote(
                            title: 'Quick Note',
                            content: txt,
                          );
                      _noteInputController.clear();
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  final txt = _noteInputController.text.trim();
                  if (txt.isNotEmpty) {
                    ref.read(bitToolNotesProvider.notifier).createNote(
                          title: 'Quick Note',
                          content: txt,
                        );
                    _noteInputController.clear();
                  }
                },
                child: const Icon(
                  LucideIcons.sendHorizontal,
                  size: 13,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutsTab() {
    return Column(
      children: _shortcuts.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s['action']!,
                style: const TextStyle(fontSize: 11, color: AppColors.darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  s['keys']!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeatherTab() {
    final weatherAsync = ref.watch(bitToolWeatherProvider);

    return weatherAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ),
      error: (err, stack) => _buildWeatherRow(
        city: 'Mumbai',
        condition: 'Clear',
        icon: LucideIcons.sun,
        temp: '29°C',
      ),
      data: (weather) {
        final city = weather?.city ?? 'Tiruvallur';
        final temp = weather?.current.temperature != null
            ? '${weather!.current.temperature.round()}°C'
            : '29°C';
        final code = weather?.current.weatherCode ?? 0;
        final condition = _getWeatherCondition(code);
        final icon = _getWeatherIcon(code);
        return _buildWeatherRow(
          city: city,
          condition: condition,
          icon: icon,
          temp: temp,
        );
      },
    );
  }

  Widget _buildWeatherRow({
    required String city,
    required String condition,
    required IconData icon,
    required String temp,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(condition, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              temp,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeatherCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 65) return 'Rainy';
    if (code <= 75) return 'Snowy';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code <= 3) return LucideIcons.cloudSun;
    if (code <= 48) return LucideIcons.cloudFog;
    if (code <= 65) return LucideIcons.cloudRain;
    if (code <= 75) return LucideIcons.cloudSnow;
    if (code >= 95) return LucideIcons.cloudLightning;
    return LucideIcons.cloud;
  }
}
