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
  int _activeTab = 0; // 0 for Active Deals, 1 for My Studio

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
            _buildHeaderBanner(context, isMobile).animate().fadeIn(duration: 450.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 32),

            // Segment Tabs & Search Bar (Responsive Layout)
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSegmentTabs(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms)
            else
              Row(
                children: [
                  _buildSegmentTabs(),
                  const Spacer(),
                  _buildSearchBar(),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 28),

            // Deal Cards Wrap Layout (Zero Overflow)
            _buildDealsGrid(isMobile).animate().fadeIn(duration: 500.ms, delay: 200.ms),
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
        color: const Color(0xFF1E3A8A), // Dark royal blue background
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.briefcase, color: AppColors.primaryGreen, size: 12),
              SizedBox(width: 6),
              Text(
                'VENTURE CONNECT',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SME Deal Marketplace',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Connect directly with verified founders, review pitches, and contact owners instantly.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildHeaderRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.mapPin, color: AppColors.primaryGreen, size: 14),
              SizedBox(width: 8),
              Text(
                'Tiruvallur, Tamil Nadu',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showPublishVentureBottomSheet(context),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('List Your Venture', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            foregroundColor: Colors.white,
            elevation: 0,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.hoverBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Active Deals', 0),
          _buildTabButton('My Studio', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.darkText : AppColors.secondaryText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 240,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.search, color: AppColors.secondaryText, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deals...',
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
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
  }

  Widget _buildDealsGrid(bool isMobile) {
    final deals = [
      {
        'title': 'beta',
        'badge': 'RETAIL & COMMERCE',
        'desc': 'memo of on',
        'location': 'Chennai, Tamil Nadu',
        'goal': '₹5,00,000',
        'equity': '5%',
      },
      {
        'title': 'fsdv',
        'badge': 'TECHNOLOGY',
        'desc': 'adfsc',
        'location': 'Chennai, Tamil Nadu',
        'goal': '₹23,232',
        'equity': '4%',
      },
      {
        'title': 'BETA',
        'badge': 'TECHNOLOGY',
        'desc': 'SOFTWARE',
        'location': 'Chennai, Tamil Nadu',
        'goal': '₹10,000',
        'equity': '8%',
      },
      {
        'title': 'Meta',
        'badge': 'TECHNOLOGY',
        'desc': 'Scaling AI-driven social engagement tools across emerging markets.',
        'location': 'Chennai, Tamil Nadu',
        'goal': '₹25,00,000',
        'equity': '10%',
      },
      {
        'title': 'Meta',
        'badge': 'TECHNOLOGY',
        'desc': 'Fight',
        'location': 'Chennai, Tamil Nadu',
        'goal': '₹8,00,000',
        'equity': '6%',
      },
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: deals.map((d) {
        return SizedBox(
          width: isMobile ? double.infinity : 340,
          child: _buildDealCard(d),
        );
      }).toList(),
    );
  }

  Widget _buildDealCard(Map<String, String> deal) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.hoverBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deal['badge']!,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.checkCircle, color: AppColors.primaryGreen, size: 12),
                  const SizedBox(width: 4),
                  const Text(
                    'VERIFIED',
                    style: TextStyle(color: AppColors.primaryGreen, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            deal['title']!,
            style: const TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            deal['desc']!,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, color: AppColors.secondaryText, size: 12),
              const SizedBox(width: 6),
              Text(
                deal['location']!,
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Goal & Equity Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.hoverBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GOAL',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal['goal']!,
                      style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'EQUITY',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal['equity']!,
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Connect Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showConnectDialog(context, deal),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1A30), // Dark slate/navy
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connect',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(width: 8),
                  Icon(LucideIcons.arrowRight, size: 14),
                ],
              ),
            ),
          ),
        ],
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
                  // Dark Header (Midnight slate color)
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.shieldCheck, color: AppColors.primaryGreen, size: 12),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'VERIFIED REGISTRANT INFO',
                                    style: TextStyle(color: AppColors.primaryGreen, fontSize: 9, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deal['desc']!,
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
                          // Venture Details Heading
                          const Text(
                            'VENTURE DETAILS',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 12),
                          
                          // Row with cards
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
                                        '${deal['goal']!} for ${deal['equity']!}',
                                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold),
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
                                        deal['badge']!,
                                        style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Expansion Intent
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.hoverBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expansion Intent / Roadmap',
                                  style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  deal['desc']!,
                                  style: const TextStyle(color: AppColors.darkText, fontSize: 13),
                                ),
                              ],
                            ),
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
                          
                          // Direct Founders Connect Heading
                          const Text(
                            'DIRECT FOUNDERS CONNECT',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 12),
                          
                          // Corporate Holder Row
                          _buildConnectRow(
                            icon: LucideIcons.building,
                            label: 'Corporate Holder',
                            value: deal['title']!,
                          ),
                          const SizedBox(height: 8),
                          
                          // Email Address Row
                          _buildConnectRow(
                            icon: LucideIcons.mail,
                            label: 'Email Address',
                            value: '${deal['title']!.toLowerCase()}@bnxmail.com',
                            showLinkIcon: true,
                          ),
                          const SizedBox(height: 8),
                          
                          // Registered Contact Row
                          _buildConnectRow(
                            icon: LucideIcons.phone,
                            label: 'Registered Contact',
                            value: '9566393028',
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
                                  "Connection request sent successfully! Deal coordinator will contact you shortly.",
                                  type: SnackType.success,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Submit Connect Request', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildConnectRow({
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

  void _showPublishVentureBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final screenHeight = MediaQuery.of(context).size.height;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PublishVenture',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 800,
                  maxHeight: screenHeight * 0.60,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Publish Venture Profile',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Broadcast your capital expansion targets immediately',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: AppColors.secondaryText),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    
                    // Form Fields (Scrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Registry Business Name *
                            _buildLabel('Registry Business Name *'),
                            _buildTextField(hint: 'e.g., Beta Tech Solutions'),
                            const SizedBox(height: 16),
                            
                            // Core Industry Tag
                            _buildLabel('Core Industry Tag'),
                            _buildDropdownField(
                              items: ['Technology', 'Retail & Commerce', 'Finance', 'Healthcare', 'Education'],
                              initialValue: 'Technology',
                            ),
                            const SizedBox(height: 16),
                            
                            // Headline / Expansion Memo *
                            _buildLabel('Headline / Expansion Memo *'),
                            _buildTextField(hint: 'e.g., Disrupting regional supply chain with micro-automated routing'),
                            const SizedBox(height: 16),
                            
                            // Funding Request Amount & Equity Transfer (Row)
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Funding Request Amount (₹) *'),
                                      _buildTextField(hint: 'e.g. 5000000', prefixIcon: LucideIcons.coins),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Equity Transfer (%)'),
                                      _buildTextField(hint: 'e.g. 10', prefixIcon: LucideIcons.percent),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Brief Expansion Intent / Roadmap
                            _buildLabel('Brief Expansion Intent / Roadmap'),
                            _buildTextField(
                              hint: 'Briefly detail operational growth goals or capital allocation...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Investor Query Email & Founder Contact Phone (Row)
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Investor Query Email *'),
                                      _buildTextField(hint: 'founder@yourbiz.com', prefixIcon: LucideIcons.mail),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Founder Contact Phone *'),
                                      _buildTextField(hint: '+9199999 99999', prefixIcon: LucideIcons.phone),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Business Location
                            _buildLabel('Business Location (Optional - defaults to detected GPS)'),
                            _buildTextField(hint: 'Tiruvallur, Tamil Nadu', prefixIcon: LucideIcons.mapPin),
                            const SizedBox(height: 16),
                            
                            // Deck Link
                            _buildLabel('Deck Link (Optional)'),
                            _buildTextField(hint: 'https://drive.google.com/executive-deck.pdf', prefixIcon: LucideIcons.fileText),
                            const SizedBox(height: 24),
                            
                            // Cancel & Publish Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkText,
                                    side: const BorderSide(color: AppColors.border),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    AppSnackbar.show(
                                      context,
                                      "Venture profile published successfully!",
                                      type: SnackType.success,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F5B2E), // Dark Green matching Cliks headers
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Publish Now', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16, color: AppColors.secondaryText) : null,
        fillColor: AppColors.background.withValues(alpha: 0.5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required List<String> items,
    required String initialValue,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      style: const TextStyle(fontSize: 13, color: AppColors.darkText),
      onChanged: (val) {},
      decoration: InputDecoration(
        fillColor: AppColors.background.withValues(alpha: 0.5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
    );
  }
}
