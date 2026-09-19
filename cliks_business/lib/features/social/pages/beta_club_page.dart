import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class BetaClubPage extends StatefulWidget {
  const BetaClubPage({super.key});

  @override
  State<BetaClubPage> createState() => _BetaClubPageState();
}

class _BetaClubPageState extends State<BetaClubPage> {
  int _activeTab = 0; // 0 for Active Deals Marketplace, 1 for My Studio (Founder View)
  String _selectedSectorFilter = 'All Sectors';

  final List<Map<String, String>> _deals = [
    {
      'title': 'Ravi Kumar',
      'sector': 'Technology',
      'location': 'India',
      'desc': 'Scaling AI-driven predictive supply chain & retail SaaS for emerging market merchants.',
      'goal': '₹50,00,000',
      'equity': '8%',
      'quota': '1 Quota',
    },
    {
      'title': 'usemeta',
      'sector': 'Technology',
      'location': 'India',
      'desc': 'Unified enterprise omnichannel automation infrastructure for next-gen commerce.',
      'goal': '₹25,00,000',
      'equity': '6%',
      'quota': '1 Quota',
    },
  ];

  final List<Map<String, String>> _studioPitches = [
    {
      'status': 'admin accepted your idea',
      'statusType': 'accepted',
      'sector': 'Technology',
      'body': 'wesdrcftvygbuhnijdcfvgbhnj',
    },
    {
      'status': 'Needs Revision',
      'statusType': 'revision',
      'sector': 'Manufacturing',
      'body': 'description of its in short',
    },
  ];

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;
    final bottomInset = isMobile ? 120.0 : 50.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        backgroundColor: Colors.white,
        displacement: 25,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(paddingVal, paddingVal, paddingVal, bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              _buildHeaderBanner(context, isMobile)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.04, end: 0),
              const SizedBox(height: 24),

              // Segmented Tabs Row
              _buildSegmentTabs(isMobile).animate().fadeIn(duration: 350.ms, delay: 50.ms),
              const SizedBox(height: 20),

              // Search Bar & Filter Row
              _buildSearchAndFilterRow(isMobile).animate().fadeIn(duration: 350.ms, delay: 100.ms),
              const SizedBox(height: 24),

              // Tab View Body with smooth animated switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _activeTab == 0
                    ? KeyedSubtree(
                        key: const ValueKey('active_deals'),
                        child: _buildActiveDealsView(isMobile),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('my_studio'),
                        child: _buildMyStudioView(isMobile),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Royal dark blue
        borderRadius: BorderRadius.circular(24),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderLeftSection(),
                const SizedBox(height: 20),
                _buildHeaderRightSection(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildHeaderLeftSection()),
                const SizedBox(width: 24),
                _buildHeaderRightSection(),
              ],
            ),
    );
  }

  Widget _buildHeaderLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Capital Matrix Tag Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.trendingUp, color: Color(0xFF60A5FA), size: 12),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'CAPITAL MATRIX & VENTURE CONNECT',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SME Deal Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connect directly with verified founders, review pitch decks, and unlock investment deals.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // Select Region / Lock GPS button
        InkWell(
          onTap: () {
            AppSnackbar.show(
              context,
              'Region locked to India (GPS Auto-Detected)',
              type: SnackType.info,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.mapPin, color: Color(0xFF34D399), size: 13),
                SizedBox(width: 8),
                Text(
                  'Select Region / Lock GPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Icon(LucideIcons.chevronDown, color: Colors.white70, size: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRightSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A86B), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showListVentureDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.rocket, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'List Your Venture',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTabs(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Soft slate pill background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: isMobile ? 'Active Deals' : 'Active Deals Marketplace',
              badge: _deals.length.toString(),
              icon: LucideIcons.store,
              index: 0,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              title: isMobile ? 'My Studio' : 'My Studio (Founder View)',
              badge: _studioPitches.length.toString(),
              icon: LucideIcons.sparkles,
              index: 1,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required String badge,
    required IconData icon,
    required int index,
    required bool isMobile,
  }) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        if (_activeTab != index) {
          setState(() => _activeTab = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFFE2E8F0), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? const Color(0xFF00A86B) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: isMobile ? 12.5 : 13.5,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00A86B).withValues(alpha: 0.12)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isActive ? const Color(0xFF00A86B) : const Color(0xFF64748B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(bool isMobile) {
    final searchBox = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.search, color: Color(0xFF9CA3AF), size: 16),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deals by title, sector, problem, or keywords...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );

    final sectorFilter = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: PopupMenuButton<String>(
        onSelected: (sector) {
          setState(() => _selectedSectorFilter = sector);
        },
        itemBuilder: (context) => [
          'All Sectors',
          'Technology',
          'Manufacturing',
          'Retail & Commerce',
          'Finance',
          'Healthcare',
        ].map((s) => PopupMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedSectorFilter,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          searchBox,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: sectorFilter),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchBox),
        const SizedBox(width: 14),
        sectorFilter,
      ],
    );
  }

  Widget _buildActiveDealsView(bool isMobile) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: _deals.map((deal) {
        return SizedBox(
          width: isMobile ? double.infinity : 350,
          child: _buildActiveDealCard(deal),
        );
      }).toList(),
    );
  }

  Widget _buildActiveDealCard(Map<String, String> deal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Sector Pill + Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Soft light blue
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    deal['sector']!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.mapPin, size: 11, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          deal['location']!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            deal['title']!,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          if (deal['desc'] != null && deal['desc']!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              deal['desc']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Professional "Connect / View Pitch" Button
          _buildConnectPitchButton(deal),
        ],
      ),
    );
  }

  Widget _buildConnectPitchButton(Map<String, String> deal) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showConnectDialog(context, deal),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Midnight Slate Navy
                Color(0xFF1E293B), // Charcoal Blue
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.lockKeyhole, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connect / View Pitch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Direct Founder Access',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF00A86B).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 10, color: Color(0xFF34D399)),
                    const SizedBox(width: 4),
                    Text(
                      deal['quota'] ?? '1 Quota',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(LucideIcons.chevronRight, size: 15, color: Colors.white60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyStudioView(bool isMobile) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: _studioPitches.map((pitch) {
        return SizedBox(
          width: isMobile ? double.infinity : 350,
          child: _buildStudioCard(pitch),
        );
      }).toList(),
    );
  }

  Widget _buildStudioCard(Map<String, String> pitch) {
    final isAccepted = pitch['statusType'] == 'accepted';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
        children: [
          // Top Row: Status badge on left, Sector on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAccepted ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAccepted ? const Color(0xFFBBF7D0) : const Color(0xFFFECDD3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAccepted ? LucideIcons.check : LucideIcons.triangleAlert,
                        size: 11,
                        color: isAccepted ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          pitch['status']!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isAccepted ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  pitch['sector']!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Content body
          Text(
            pitch['body']!,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showListVentureDialog(BuildContext context) {
    final businessNameController = TextEditingController();
    final headlineController = TextEditingController();
    final descriptionController = TextEditingController();
    final pitchDeckUrlController = TextEditingController();
    String selectedSector = 'Technology';
    int wordCount = 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'List Your Venture',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Submit your roadmap for Admin Review & Investor Connect',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7280)),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Business / Venture Name *
                      _buildModalLabel('Business / Venture Name *'),
                      _buildModalTextField(
                        controller: businessNameController,
                        hint: '',
                      ),
                      const SizedBox(height: 16),

                      // Sector *
                      _buildModalLabel('Sector *'),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSector,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: AppColors.darkText),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                        ),
                        items: [
                          'Technology',
                          'Manufacturing',
                          'Retail & Commerce',
                          'Healthcare',
                          'Finance',
                          'Education',
                          'Logistics & Mobility',
                        ].map((sector) => DropdownMenuItem(value: sector, child: Text(sector))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedSector = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Headline Pitch *
                      _buildModalLabel('Headline Pitch *'),
                      _buildModalTextField(
                        controller: headlineController,
                        hint: 'e.g. Next-gen AI inventory platform for retail SMEs',
                      ),
                      const SizedBox(height: 16),

                      // Description * + Word count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: _buildModalLabel('Description *')),
                          const SizedBox(width: 8),
                          Text(
                            '$wordCount / 300 words',
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                          ),
                        ],
                      ),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (text) {
                          final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
                          setModalState(() => wordCount = words);
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter venture description (maximum 300 words)...',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF00A86B), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pitch Deck URL
                      _buildModalLabel('Pitch Deck URL'),
                      _buildModalTextField(
                        controller: pitchDeckUrlController,
                        hint: 'https://drive.google.com/...',
                      ),
                      const SizedBox(height: 24),

                      // Submit Pitch for Admin Review Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            AppSnackbar.show(
                              context,
                              'Venture pitch submitted successfully for Admin Review & Investor Connect!',
                              type: SnackType.success,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A86B), // Vibrant Emerald
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit Pitch for Admin Review',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildModalLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00A86B), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }

  void _showConnectDialog(BuildContext context, Map<String, String> deal) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Connect',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dark Header (Midnight navy slate)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF022C22),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.shieldCheck, color: AppColors.primaryGreen, size: 12),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'VERIFIED REGISTRANT INFO',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          deal['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deal['desc'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VENTURE DETAILS',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Target & Equity Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.hoverBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Target & Equity',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${deal['goal'] ?? '₹25,00,000'} for ${deal['equity'] ?? '8%'}',
                                        style: const TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.hoverBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Industry',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        deal['sector']!,
                                        style: const TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location Row
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: AppColors.secondaryText, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                deal['location']!,
                                style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'DIRECT FOUNDERS CONNECT',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildConnectInfoRow(
                            icon: LucideIcons.building,
                            label: 'Corporate Holder',
                            value: deal['title']!,
                          ),
                          const SizedBox(height: 8),
                          _buildConnectInfoRow(
                            icon: LucideIcons.mail,
                            label: 'Email Address',
                            value: '${deal['title']!.toLowerCase().replaceAll(' ', '')}@bnxmail.com',
                            showLinkIcon: true,
                          ),
                          const SizedBox(height: 8),
                          _buildConnectInfoRow(
                            icon: LucideIcons.phone,
                            label: 'Registered Contact',
                            value: '+91 95663 93028',
                            showLinkIcon: true,
                          ),
                          const SizedBox(height: 24),

                          // Submit Connect Request Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                AppSnackbar.show(
                                  context,
                                  'Connection request sent successfully! Deal coordinator will contact you shortly.',
                                  type: SnackType.success,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Submit Connect Request (1 Quota)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildConnectInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showLinkIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.hoverBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 16, color: AppColors.secondaryText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: showLinkIcon ? AppColors.primaryGreen : AppColors.darkText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showLinkIcon) ...[
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowUpRight, size: 12, color: AppColors.primaryGreen),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
