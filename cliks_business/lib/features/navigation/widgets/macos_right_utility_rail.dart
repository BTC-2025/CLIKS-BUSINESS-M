import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/calculator/beta_calculator.dart';

final macosBetaAppsVisibleProvider = StateProvider<bool>((ref) => false);

class MacOSRightUtilityRail extends ConsumerStatefulWidget {
  const MacOSRightUtilityRail({super.key});

  @override
  ConsumerState<MacOSRightUtilityRail> createState() => _MacOSRightUtilityRailState();
}

class _MacOSRightUtilityRailState extends ConsumerState<MacOSRightUtilityRail> {
  // Currently open panel: null (closed - only thin rail visible), 'beta', 'calendar', 'calculator', 'contacts', 'security', 'notes'
  String? _activeTool;
  int _betaTab = 0; // 0 = FAVORITES, 1 = RECENT
  DateTime _selectedCalendarDate = DateTime.now();

  final List<String> _notes = [
    'Review Q3 sales invoices',
    'Verify GST credit ledger',
    'Schedule audit reconciliation meeting',
  ];
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, String>> _contacts = [
    {'name': 'Sarah Jenkins', 'email': 'sarah@cliks.com', 'role': 'Finance Lead'},
    {'name': 'Alex Rivera', 'email': 'alex@cliks.com', 'role': 'Auditor'},
    {'name': 'James Miller', 'email': 'james@cliks.com', 'role': 'Account Manager'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleTool(String tool) {
    setState(() {
      if (_activeTool == tool) {
        _activeTool = null;
      } else {
        _activeTool = tool;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(macosBetaAppsVisibleProvider, (prev, next) {
      if (!next && _activeTool != null) {
        setState(() => _activeTool = null);
      }
    });

    final hasOpenPanel = _activeTool != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slide-out Drawer Panel (only visible when a tool is selected)
        if (hasOpenPanel)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: _buildPanelContent(),
          ),

        // Slim Pinned Vertical Utility Rail (54px width)
        Container(
          width: 54,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 1. Beta Icon Button (Script B)
              _buildBetaCircleBtn(),
              const SizedBox(height: 12),

              // 2. Calendar Button
              _buildRailBoxBtn(
                tool: 'calendar',
                icon: LucideIcons.calendar,
                tooltip: 'Calendar',
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 10),

              // 3. Calculator Button
              _buildRailBoxBtn(
                tool: 'calculator',
                icon: LucideIcons.calculator,
                tooltip: 'Calculator',
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
              ),
              const SizedBox(height: 10),

              // 4. Contacts / ID Card Button
              _buildRailBoxBtn(
                tool: 'contacts',
                icon: LucideIcons.users,
                tooltip: 'Contacts',
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 10),

              // 5. Shield / Security Button
              _buildRailBoxBtn(
                tool: 'security',
                icon: LucideIcons.shieldCheck,
                tooltip: 'B2Auth Security',
                bgColor: const Color(0xFFCCFBF1),
                iconColor: const Color(0xFF0D9488),
              ),
              const SizedBox(height: 10),

              // 6. Plus / Add Utility Button
              _buildRailBoxBtn(
                tool: 'add',
                icon: LucideIcons.plus,
                tooltip: 'More Utilities',
                bgColor: Colors.white,
                iconColor: const Color(0xFF94A3B8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                customTap: () {
                  _showAddUtilityDialog();
                },
              ),

              const Spacer(),

              // 7. Quick Notes Button
              _buildRailBoxBtn(
                tool: 'notes',
                icon: LucideIcons.squarePen,
                tooltip: 'Quick Notes',
                bgColor: Colors.white,
                iconColor: _activeTool == 'notes' ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              const SizedBox(height: 10),

              // 8. Sliders / Close Toolbar Button
              _buildRailBoxBtn(
                tool: 'settings',
                icon: LucideIcons.slidersHorizontal,
                tooltip: 'Close Toolbar',
                bgColor: Colors.white,
                iconColor: const Color(0xFF9CA3AF),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                customTap: () {
                  setState(() => _activeTool = null);
                  ref.read(macosBetaAppsVisibleProvider.notifier).state = false;
                },
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  // --- Vertical Rail Button Builders ---

  Widget _buildBetaCircleBtn() {
    final isActive = _activeTool == 'beta';
    return Tooltip(
      message: 'Beta Apps',
      child: GestureDetector(
        onTap: () => _toggleTool('beta'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFE8F8F2),
            border: Border.all(
              color: const Color(0xFF10B981),
              width: isActive ? 2.0 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: const Text(
            'ℬ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F766E),
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              height: 1.05,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRailBoxBtn({
    required String tool,
    required IconData icon,
    required String tooltip,
    required Color bgColor,
    required Color iconColor,
    Border? border,
    VoidCallback? customTap,
  }) {
    final isActive = _activeTool == tool;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: customTap ?? () => _toggleTool(tool),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? bgColor.withValues(alpha: 0.9) : bgColor,
            borderRadius: BorderRadius.circular(10),
            border: border ??
                Border.all(
                  color: isActive ? iconColor : Colors.transparent,
                  width: 1.5,
                ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }

  // --- Main Panel Content Switcher ---

  Widget _buildPanelContent() {
    switch (_activeTool) {
      case 'beta':
        return _buildBetaPanel();
      case 'calculator':
        return _buildCalculatorPanel();
      case 'calendar':
        return _buildCalendarPanel();
      case 'contacts':
        return _buildContactsPanel();
      case 'security':
        return _buildSecurityPanel();
      case 'notes':
        return _buildNotesPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Beta Drawer Panel (Image 2) ---

  Widget _buildBetaPanel() {
    return Column(
      children: [
        // Header: BETA title, Edit button, X button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Row(
            children: [
              const Text(
                'BETA',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Edit button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customize shortcuts in Beta settings.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.pencil, size: 12, color: Color(0xFF374151)),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Close button
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7280)),
                onPressed: () {
                  setState(() => _activeTool = null);
                },
                tooltip: 'Close panel',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFF3F4F6)),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Underline Tabs: FAVORITES | RECENT
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _buildUnderlineTab('FAVORITES', 0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '|',
                          style: TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      _buildUnderlineTab('RECENT', 1),
                    ],
                  ),
                ),

                // Favorites Content
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Center(
                    child: Text(
                      _betaTab == 0 ? 'No favorites' : 'No recent items',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // BASE section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: const [
                      Text(
                        'BASE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'PUBLIC  |  BUSINESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Apps Grid (Cliks, BNXmail, Bit-Tool, B2Auth, CliksBus...)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildAppLauncherTile(
                        label: 'Cliks',
                        iconWidget: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/icon2_image.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        onTap: () {
                          ref.read(navigationProvider.notifier).setModuleAndRoute(
                                AppModule.books,
                                AppRoute.dashboard,
                              );
                        },
                      ),
                      _buildAppLauncherTile(
                        label: 'BNXmail',
                        iconWidget: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.send, color: Color(0xFF2563EB), size: 20),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening BNXmail Workspace...')),
                          );
                        },
                      ),
                      _buildAppLauncherTile(
                        label: 'Bit-Tool',
                        iconWidget: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.candlestickChart, color: Color(0xFF2563EB), size: 22),
                        ),
                        onTap: () {
                          setState(() => _activeTool = 'calculator');
                        },
                      ),
                      _buildAppLauncherTile(
                        label: 'B2Auth',
                        iconWidget: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.shield, color: Color(0xFF374151), size: 22),
                        ),
                        onTap: () {
                          setState(() => _activeTool = 'security');
                        },
                      ),
                      _buildAppLauncherTile(
                        label: 'CliksBus...',
                        iconWidget: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/icon2_image.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        onTap: () {
                          ref.read(navigationProvider.notifier).setModuleAndRoute(
                                AppModule.books,
                                AppRoute.betaClub,
                              );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // BETA LABS RELEASE Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Color(0xFF7C3AED), size: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'BETA LABS RELEASE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6D28D9),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Building the next generation of Beta applications.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                const Center(
                  child: Text(
                    'BETA ECOSYSTEM · FUTURE READY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnderlineTab(String title, int index) {
    final isSelected = _betaTab == index;
    return InkWell(
      onTap: () => setState(() => _betaTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: isSelected ? 48 : 0,
            color: isSelected ? const Color(0xFF135029) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildAppLauncherTile({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            iconWidget,
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- Calculator Panel ---

  Widget _buildCalculatorPanel() {
    return Column(
      children: [
        _buildPanelHeader('Calculator', LucideIcons.calculator, const Color(0xFF059669)),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: BetaCalculator(),
          ),
        ),
      ],
    );
  }

  // --- Calendar Panel ---

  Widget _buildCalendarPanel() {
    return Column(
      children: [
        _buildPanelHeader('Calendar', LucideIcons.calendar, const Color(0xFFD97706)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarDatePicker(
                  initialDate: _selectedCalendarDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (date) {
                    setState(() => _selectedCalendarDate = date);
                  },
                ),
                const Divider(height: 24),
                const Text(
                  'Upcoming Deadlines',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 10),
                _buildEventTile('GST Filing Deadline', '24th this month', const Color(0xFFEF4444)),
                _buildEventTile('Quarterly Audit Sync', 'End of Quarter', const Color(0xFF2563EB)),
                _buildEventTile('Staff Payroll Processing', 'Last working day', const Color(0xFF059669)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTile(String title, String date, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          Text(date, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Contacts Panel ---

  Widget _buildContactsPanel() {
    return Column(
      children: [
        _buildPanelHeader('Contacts & Team', LucideIcons.users, const Color(0xFF2563EB)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _contacts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final c = _contacts[i];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    c['name']![0],
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${c['role']} · ${c['email']}', style: const TextStyle(fontSize: 11)),
                trailing: const Icon(LucideIcons.mail, size: 16, color: Color(0xFF6B7280)),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Security Panel ---

  Widget _buildSecurityPanel() {
    return Column(
      children: [
        _buildPanelHeader('B2Auth Security', LucideIcons.shieldCheck, const Color(0xFF0D9488)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(LucideIcons.shieldCheck, color: Color(0xFF0D9488), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enterprise Session Protected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF134E4A))),
                            SizedBox(height: 2),
                            Text('Hardware token & IP bound security verified.', style: TextStyle(fontSize: 10, color: Color(0xFF0F766E))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Security Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildSecurityCheck('Two-Factor Authentication', true),
                _buildSecurityCheck('Encrypted Audit Trail', true),
                _buildSecurityCheck('PIN Lock on Sign-in', true),
                _buildSecurityCheck('Active Device Monitoring', true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCheck(String title, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(enabled ? LucideIcons.checkCircle2 : LucideIcons.xCircle, color: enabled ? const Color(0xFF16A34A) : Colors.red, size: 16),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
        ],
      ),
    );
  }

  // --- Quick Notes Panel ---

  Widget _buildNotesPanel() {
    return Column(
      children: [
        _buildPanelHeader('Quick Notes', LucideIcons.squarePen, const Color(0xFF2563EB)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Add a quick note...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        _notes.add(val.trim());
                        _noteController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.plus, color: Color(0xFF2563EB)),
                onPressed: () {
                  final text = _noteController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _notes.add(text);
                      _noteController.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _notes.length,
            itemBuilder: (ctx, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(_notes[i], style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFF9CA3AF)),
                      onPressed: () => setState(() => _notes.removeAt(i)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Generic Panel Header Helper ---

  Widget _buildPanelHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7280)),
            onPressed: () {
              setState(() => _activeTool = null);
              ref.read(macosBetaAppsVisibleProvider.notifier).state = false;
            },
            tooltip: 'Close panel',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddUtilityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Utilities to Rail'),
        content: const Text('Select tools and shortcuts to pin to your quick rail.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
