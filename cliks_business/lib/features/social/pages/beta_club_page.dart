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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            _buildHeaderBanner(context, isMobile)
                .animate()
                .fadeIn(duration: 450.ms)
                .slideY(begin: -0.05, end: 0),
            const SizedBox(height: 28),

            // Segmented Tabs Row
            _buildSegmentTabs().animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 20),

            // Search Bar & Filter Row
            _buildSearchAndFilterRow(isMobile).animate().fadeIn(duration: 400.ms, delay: 150.ms),
            const SizedBox(height: 28),

            // Tab View Body
            if (_activeTab == 0)
              _buildActiveDealsView(isMobile).animate().fadeIn(duration: 450.ms, delay: 200.ms)
            else
              _buildMyStudioView(isMobile).animate().fadeIn(duration: 450.ms, delay: 200.ms),
          ],
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
              Text(
                'CAPITAL MATRIX & VENTURE CONNECT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
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
    return ElevatedButton.icon(
      onPressed: () => _showListVentureDialog(context),
      icon: const Icon(LucideIcons.rocket, size: 16, color: Colors.white),
      label: const Text(
        'List Your Venture',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00A86B), // Vibrant emerald green
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSegmentTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB), // Soft neutral pill background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton('Active Deals Marketplace', 0),
            _buildTabButton('My Studio (Founder View)', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.darkText : const Color(0xFF6B7280),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
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
          // Top Row: Sector Pill + Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft light blue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  deal['sector']!,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    deal['location']!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            deal['title']!,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Connect / View Pitch Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showConnectDialog(context, deal),
              icon: const Icon(LucideIcons.lock, size: 14, color: Colors.white),
              label: Text(
                'Connect / View Pitch (${deal['quota']})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // Dark navy / blue
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
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
              Container(
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
                    Text(
                      pitch['status']!,
                      style: TextStyle(
                        color: isAccepted ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                pitch['sector']!,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                padding: const EdgeInsets.all(28),
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
                          const Column(
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
                          _buildModalLabel('Description *'),
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
                            Container(
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
                                  Text(
                                    'VERIFIED REGISTRANT INFO',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    Text(
                      value,
                      style: TextStyle(
                        color: showLinkIcon ? AppColors.primaryGreen : AppColors.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
