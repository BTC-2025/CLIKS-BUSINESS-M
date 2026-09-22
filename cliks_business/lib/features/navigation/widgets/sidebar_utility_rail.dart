import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../widgets/calculator/beta_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
           pinnedUtilityNames ?? {'Calculator', 'Calendar', 'Contacts'};

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

  final List<String> _keepNotes = [
    'Review Q3 invoices',
    'Finalize tax filings',
    'Call vendor team',
  ];
  final List<Map<String, String>> _contacts = [
    {'name': 'Sarah Jenkins', 'email': 'sarah@cliks.com'},
    {'name': 'Alex Rivera', 'email': 'alex@cliks.com'},
    {'name': 'James Miller', 'email': 'james@cliks.com'},
  ];

  final List<Map<String, String>> _shortcuts = [
    {'keys': 'Ctrl + I', 'action': 'New Invoice'},
    {'keys': 'Ctrl + P', 'action': 'Payment Setup'},
    {'keys': 'Shift + S', 'action': 'Split Billing'},
  ];

  String _targetLanguage = 'Spanish';
  String _translationResult = '';

  String _ocrOutputText = 'Extracted invoice details: Total due ₹24,500.00.';
  bool _ocrScanRunning = false;

  final List<String> _newsItems = [
    'Cliks Business launches automated GST reconciliation',
    'New real-time payout capabilities rolled out',
    'Financial trends shifting towards hybrid credit terms',
  ];

  late final TextEditingController _noteInputController;
  late final TextEditingController _translateInputController;

  bool _logoLoaded = false;
  File? _logoFile;

  @override
  void initState() {
    super.initState();
    _noteInputController = TextEditingController();
    _translateInputController = TextEditingController();
    _loadCustomLogo();
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
    _translateInputController.dispose();
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
                width: 36,
                height: 36,
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
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: Icon(
                      item['icon'] as IconData,
                      size: isActive ? 16 : 15,
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
        'icon': LucideIcons.users,
        'color': const Color(0xFF2F80ED),
        'label': 'Contacts',
      },
      {
        'icon': LucideIcons.messageSquare,
        'color': const Color(0xFF56CCF2),
        'label': 'Messages',
      },
      {
        'icon': LucideIcons.keyboard,
        'color': const Color(0xFF9B51E0),
        'label': 'Shortcuts',
      },
      {
        'icon': LucideIcons.languages,
        'color': const Color(0xFFEB5757),
        'label': 'Translate',
      },
      {
        'icon': LucideIcons.scan,
        'color': const Color(0xFF8E44AD),
        'label': 'Lens OCR',
      },
      {
        'icon': LucideIcons.cloudSun,
        'color': const Color(0xFFF2C94C),
        'label': 'Weather',
      },
      {
        'icon': LucideIcons.newspaper,
        'color': const Color(0xFF56CCF2),
        'label': 'News',
      },
    ];

    final List<Map<String, dynamic>> displayList = [];
    if (isEditingUtilities) {
      displayList.addAll(utilities);
    } else {
      // 1. Keep the first 3 default icons always
      displayList.add(utilities[0]); // Calculator
      displayList.add(utilities[1]); // Calendar
      displayList.add(utilities[2]); // Contacts

      // 2. Append other user-pinned items (excluding the default 3)
      final Set<String> defaultLabels = {'Calculator', 'Calendar', 'Contacts'};
      final customPinned = utilities.where(
        (u) =>
            pinnedUtilityNames.contains(u['label']) &&
            !defaultLabels.contains(u['label']),
      );
      displayList.addAll(customPinned);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Rail Bar - Shifted slightly to the left
        Container(
          height: 52,
          margin: const EdgeInsets.only(left: 0, right: 16, top: 4, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(3),
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
                    width: 36,
                    height: 36,
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
      case 'Messages':
        content = _buildMessagesTab();
        break;
      case 'Shortcuts':
        content = _buildShortcutsTab();
        break;
      case 'Translate':
        content = _buildTranslateTab();
        break;
      case 'Lens OCR':
        content = _buildOcrTab();
        break;
      case 'Weather':
        content = _buildWeatherTab();
        break;
      case 'News':
        content = _buildNewsTab();
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
                expandedUtilityTab,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.darkText,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(utilityRailProvider.notifier).setExpandedTab(null),
                child: const Icon(LucideIcons.x, size: 14, color: Colors.grey),
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
    final now = DateTime.now();
    final monthLabel = "July ${now.year}";
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const Row(
              children: [
                Icon(LucideIcons.chevronLeft, size: 14, color: Colors.black54),
                SizedBox(width: 8),
                Icon(LucideIcons.chevronRight, size: 14, color: Colors.black54),
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
                  width: 24,
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
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
          children: List.generate(4, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex + 1;
                  final isSelected = _selectedCalendarDate.day == dayNumber;
                  if (dayNumber > 31) return const SizedBox(width: 24);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCalendarDate = DateTime(
                          now.year,
                          now.month,
                          dayNumber,
                        );
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade200,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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
              const Icon(Icons.circle, size: 8, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedCalendarDate.day % 2 == 0
                      ? 'No business scheduled for today.'
                      : 'Payout run execution @ 3:00 PM',
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
    return Column(
      children: _contacts.map((c) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.hoverBackground,
                child: Text(
                  c['name']![0],
                  style: const TextStyle(
                    fontSize: 10,
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
                      c['name']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      c['email']!,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.messageSquare,
                size: 14,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.hoverBackground,
                child: const Text(
                  'S',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Team',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      'How can we help you today?',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
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

  Widget _buildTranslateTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Translate to: ',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            DropdownButton<String>(
              value: _targetLanguage,
              style: const TextStyle(fontSize: 11, color: AppColors.darkText),
              underline: const SizedBox.shrink(),
              items: ['Spanish', 'French', 'German', 'Chinese'].map((lang) {
                return DropdownMenuItem<String>(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (val) {
                setState(() => _targetLanguage = val!);
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _translateInputController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
              hintText: 'Enter text to translate...',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        if (_translationResult.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _translationResult,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              final txt = _translateInputController.text.trim();
              if (txt.isNotEmpty) {
                setState(() {
                  _translationResult = "Result: [Mock Translation of '$txt']";
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Translate',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOcrTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ocrScanRunning ? 'Analyzing image details...' : _ocrOutputText,
          style: const TextStyle(fontSize: 11, color: AppColors.darkText),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _ocrScanRunning = true;
                });
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    setState(() {
                      _ocrScanRunning = false;
                      _ocrOutputText =
                          "Extracted: 'Amount: ₹24,500.00, Date: 08-Jul-2026'";
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                _ocrScanRunning ? 'Analyzing...' : 'Scan invoice',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherTab() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mumbai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text('Rainy', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            Icon(LucideIcons.cloudRain, size: 20, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              '29°C',
              style: TextStyle(
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

  Widget _buildNewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _newsItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: Icon(
                  LucideIcons.newspaper,
                  size: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
