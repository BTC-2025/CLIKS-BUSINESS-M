import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AdminApprovalStatus {
  idle,
  pending,
  approved,
  rejected,
}

class CustomizablePlanBuilderSection extends StatefulWidget {
  final bool isMobile;
  final VoidCallback? onScrollToActivePlan;
  final VoidCallback? onScrollToBillingHistory;

  const CustomizablePlanBuilderSection({
    super.key,
    this.isMobile = false,
    this.onScrollToActivePlan,
    this.onScrollToBillingHistory,
  });

  @override
  State<CustomizablePlanBuilderSection> createState() =>
      _CustomizablePlanBuilderSectionState();
}

class _CustomizablePlanBuilderSectionState
    extends State<CustomizablePlanBuilderSection> {
  // Brand color palette
  static const Color _darkForestGreen = Color(0xFF135029);
  static const Color _lightMintBg = Color(0xFFEAFAE3);
  static const Color _mintBorder = Color(0xFFD1F2C2);
  static const Color _emeraldBrand = Color(0xFF166534);
  static const Color _goldBrand = Color(0xFFD97706);
  static const Color _slateText = Color(0xFF64748B);
  static const Color _darkHeading = Color(0xFF0F172A);
  static const Color _cardBorderDefault = Color(0xFFE2E8F0);

  // Sub-switcher mode:
  // 0: Build Custom Plan (Admin Approval)
  // 1: Instant Add-On Boosters
  // 2: All / Complete View
  int _activeSubMode = 0;

  // Billing Cycle
  bool _isAnnualBilling = true; // true = Annual (20% discount on monthly recurring), false = Monthly

  // Base platform floor
  static const int _baseFloorPrice = 149;

  // Capacity Sliders / Steppers:
  int _usersCount = 2; // Range: 2 to 100 (+₹49/user/mo for users > 2)
  int _warehouseCount = 1; // Range: 1 to 50 (+₹99/site/mo for sites > 1)
  int _invoicesTierIndex = 0; // 0: 5k (inc), 1: 15k (+49), 2: 50k (+129), 3: 100k+ (+249)
  int _skuTierIndex = 0; // 0: 5k (inc), 1: 25k (+49), 2: Unlimited (+99)
  int _staffCount = 5; // Range: 5 to 250 (+₹15/staff/mo for staff > 5)
  int _posTerminalsCount = 1; // Range: 1 to 25 (+₹119/terminal/mo for terminals > 1)

  // Invoice capacity options
  static const List<Map<String, dynamic>> _invoiceOptions = [
    {'label': '5,000 / yr', 'badge': 'Included', 'price': 0},
    {'label': '15,000 / yr', 'badge': '+₹49 / mo', 'price': 49},
    {'label': '50,000 / yr', 'badge': '+₹129 / mo', 'price': 129},
    {'label': 'Unlimited 100k+', 'badge': '+₹249 / mo', 'price': 249},
  ];

  // SKU limit options
  static const List<Map<String, dynamic>> _skuOptions = [
    {'label': '5,000 SKUs', 'badge': 'Included', 'price': 0},
    {'label': '25,000 SKUs', 'badge': '+₹49 / mo', 'price': 49},
    {'label': 'Unlimited SKUs', 'badge': '+₹99 / mo', 'price': 99},
  ];

  // Modular Feature Picklist (14 Modules)
  final Set<String> _selectedModules = {};
  int _finProExtraClients = 0; // If finpro_client_pack is selected (+₹25/extra client)

  // Instant Add-On Boosters (Quantities)
  final Map<String, int> _addonQuantities = {
    'addon_finpro_seat': 0, // ₹299/mo (recurring)
    'addon_cloud_storage': 0, // ₹99/mo per 25GB (recurring)
    'addon_pitch_unlock': 0, // ₹499 one-time
    'addon_founder_spotlight': 0, // ₹799 one-time
    'addon_einvoice_credits': 0, // ₹199 one-time
    'addon_whatsapp_credits': 0, // ₹299 one-time
  };

  // Admin Approval Workflow State
  AdminApprovalStatus _adminStatus = AdminApprovalStatus.idle;
  final TextEditingController _adminNoteController = TextEditingController();

  @override
  void dispose() {
    _adminNoteController.dispose();
    super.dispose();
  }

  // --- Calculations ---
  int get _capacityUsersPrice => (_usersCount - 2) * 49;
  int get _capacityWarehousePrice => (_warehouseCount - 1) * 99;
  int get _capacityInvoicesPrice => _invoiceOptions[_invoicesTierIndex]['price'] as int;
  int get _capacitySkuPrice => _skuOptions[_skuTierIndex]['price'] as int;
  int get _capacityStaffPrice => (_staffCount - 5) * 15;
  int get _capacityPosPrice => (_posTerminalsCount - 1) * 119;

  int get _totalCapacityPrice =>
      _capacityUsersPrice +
      _capacityWarehousePrice +
      _capacityInvoicesPrice +
      _capacitySkuPrice +
      _capacityStaffPrice +
      _capacityPosPrice;

  // Selected Modules total
  int get _totalModulesPrice {
    int sum = 0;
    for (final mod in _allModules) {
      if (_selectedModules.contains(mod['id'])) {
        sum += (mod['price'] as int);
        if (mod['id'] == 'finpro_client_pack') {
          sum += _finProExtraClients * 25;
        }
      }
    }
    return sum;
  }

  // Monthly Recurring Total for Custom Plan (Base + Capacity + Modules)
  int get _monthlyCustomSubtotal =>
      _baseFloorPrice + _totalCapacityPrice + _totalModulesPrice;

  // Instant Recurring Add-ons
  int get _recurringAddonsSubtotal =>
      (_addonQuantities['addon_finpro_seat']! * 299) +
      (_addonQuantities['addon_cloud_storage']! * 99);

  // Instant One-Time Add-ons
  int get _oneTimeAddonsSubtotal =>
      (_addonQuantities['addon_pitch_unlock']! * 499) +
      (_addonQuantities['addon_founder_spotlight']! * 799) +
      (_addonQuantities['addon_einvoice_credits']! * 199) +
      (_addonQuantities['addon_whatsapp_credits']! * 299);

  // Total effective monthly recurring (Custom Plan + Recurring Add-ons)
  int get _totalMonthlyRecurring =>
      _monthlyCustomSubtotal + _recurringAddonsSubtotal;

  // Discounted monthly price when Annual is selected (20% off)
  int get _effectiveMonthlyPrice => _isAnnualBilling
      ? (_totalMonthlyRecurring * 0.8).round()
      : _totalMonthlyRecurring;

  // Annual billed amount (before GST)
  int get _billedAnnualPrice => (_effectiveMonthlyPrice * 12);

  // 18% GST calculation
  int get _gstAmount => _isAnnualBilling
      ? (_billedAnnualPrice * 0.18).round()
      : (_effectiveMonthlyPrice * 0.18).round();

  int get _netPayableAmount => _isAnnualBilling
      ? (_billedAnnualPrice + _gstAmount)
      : (_effectiveMonthlyPrice + _gstAmount);

  int get _oneTimeGst => (_oneTimeAddonsSubtotal * 0.18).round();
  int get _netOneTimePayable => _oneTimeAddonsSubtotal + _oneTimeGst;

  bool get _hasAnyInstantAddon =>
      _addonQuantities.values.any((qty) => qty > 0);

  // Module catalogue
  static final List<Map<String, dynamic>> _allModules = [
    // Group 1: Business & Enterprise ERP
    {
      'id': 'hr_payroll',
      'group': 'Business ERP',
      'title': 'Automated HR Payroll, Attendance & Payslips',
      'price': 79,
      'desc':
          'Geo-fenced attendance, shift rosters, automated salary slips & staff ledgers.',
      'icon': LucideIcons.users,
      'isGold': false,
    },
    {
      'id': 'barcode_labels',
      'group': 'Business ERP',
      'title': 'Custom Barcode & Thermal QR Label Printing',
      'price': 49,
      'desc':
          'Thermal roll/A4 barcode designer, bulk SKU printing & weigh-scale barcode support.',
      'icon': LucideIcons.qrCode,
      'isGold': false,
    },
    {
      'id': 'recurring_invoices',
      'group': 'Business ERP',
      'title': 'Recurring Invoices, Smart Overdue Alerts & Dunning',
      'price': 39,
      'desc':
          'Automated subscription billing cycles, WhatsApp/Email payment reminders & late fee rules.',
      'icon': LucideIcons.repeat,
      'isGold': false,
    },
    {
      'id': 'einvoice_eway',
      'group': 'Business ERP',
      'title': 'Live E-Invoicing & E-Way Bill GSP API',
      'price': 69,
      'desc':
          '1-click IRN generation, live GSTR-2B ITC auto-reconciliation & bulk E-Way bills.',
      'icon': LucideIcons.fileCheck2,
      'isGold': false,
    },
    {
      'id': 'bom_manufacturing',
      'group': 'Business ERP',
      'title': 'Bill of Materials (BOM), Work Orders & Manufacturing',
      'price': 149,
      'desc':
          'Multi-stage production recipes, raw material scrap tracking, batch expiry & QC logs.',
      'icon': LucideIcons.factory,
      'isGold': false,
    },
    {
      'id': 'api_webhooks',
      'group': 'Business ERP',
      'title': 'API, Webhooks & Direct ERP / E-Commerce Sync',
      'price': 129,
      'desc':
          'REST API keys, real-time webhook triggers & Shopify/WooCommerce inventory sync.',
      'icon': LucideIcons.webhook,
      'isGold': false,
    },
    {
      'id': 'roles_approval',
      'group': 'Business ERP',
      'title': 'Granular Multi-User Role & Approval Matrix',
      'price': 59,
      'desc':
          'Maker-checker voucher approvals, field-level hiding & immutable 1-year audit trail.',
      'icon': LucideIcons.shieldAlert,
      'isGold': false,
    },
    {
      'id': 'white_label',
      'group': 'Business ERP',
      'title': 'Custom White-Label Invoicing & Brand Domain',
      'price': 149,
      'desc':
          'Remove Cliks branding, custom PDF/HTML invoice layouts & custom sender domain.',
      'icon': LucideIcons.sparkles,
      'isGold': true,
    },
    {
      'id': 'whatsapp_marketing',
      'group': 'Business ERP',
      'title': 'WhatsApp Business Marketing & Loyalty Campaigns',
      'price': 89,
      'desc':
          'Bulk festival offer broadcasts, customer reward points & automated ledger statements.',
      'icon': LucideIcons.messageSquare,
      'isGold': false,
    },
    {
      'id': 'vip_priority_support',
      'group': 'Business ERP',
      'title': '24/7 VIP Priority Support & 99.99% Uptime SLA',
      'price': 149,
      'desc':
          'Dedicated account manager, fast-track phone/chat support & enterprise SLA guarantee.',
      'icon': LucideIcons.headset,
      'isGold': false,
    },

    // Group 2: FIN-PRO
    {
      'id': 'finpro_client_pack',
      'group': 'FIN-PRO Practice',
      'title': 'FIN-PRO Client Ledger & Audit Pack',
      'price': 299,
      'desc':
          'Smart Vouching & Sampler, Direct Bank BRS Engine, Fixed Asset Depreciation & Workpapers.',
      'extraNote': 'Includes 10 Active Clients. +₹25/mo per extra client.',
      'icon': LucideIcons.award,
      'isGold': true,
    },
    {
      'id': 'gov_vault_gaap',
      'group': 'FIN-PRO Practice',
      'title': 'Government Credential Vault & IFRS/US GAAP Mapper',
      'price': 149,
      'desc':
          'Encrypted client password vault (GST, IT, TRACES, MCA, EPFO) + international account layout mapping.',
      'icon': LucideIcons.landmark,
      'isGold': false,
    },

    // Group 3: Partner Launch Desk
    {
      'id': 'investor_deal_pass',
      'group': 'Partner Launch Desk',
      'title': 'Investor Club Deal Pass',
      'price': 399,
      'desc':
          'Includes 10 Startup Pitch Unlocks/mo, sector/GPS filters, verified founder chat & deal rooms.',
      'icon': LucideIcons.crown,
      'isGold': true,
    },
    {
      'id': 'founder_studio',
      'group': 'Partner Launch Desk',
      'title': 'Founder Studio & Marketplace Spotlight',
      'price': 299,
      'desc':
          'List up to 3 active startup roadmaps/pitches, investor-ready templates & live Cliks ERP revenue badge.',
      'icon': LucideIcons.zap,
      'isGold': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = widget.isMobile || MediaQuery.of(context).size.width < 1080;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. SUB-MODE SWITCHER (Centered secondary pill) ───
        _buildSubModeSelector(),
        const SizedBox(height: 20),

        // ─── 2. SECTION HEADER WITH CONTROLS ───
        _buildSectionHeaderWithControls(isNarrow),
        const SizedBox(height: 18),

        // ─── 3. RESPONSIVE LAYOUT (2-Column Desktop or Stacked Narrow) ───
        if (isNarrow) ...[
          _buildLeftConfiguratorColumn(),
          const SizedBox(height: 24),
          _buildRightStickySummaryCard(),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 68,
                child: _buildLeftConfiguratorColumn(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 32,
                child: _buildRightStickySummaryCard(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. SUB-MODE SELECTOR (Centered secondary pill)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubModeSelector() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubModeItem(
                index: 0,
                label: '⚡ Build Custom Plan (Admin Approval)',
                badge: 'Custom Sizing',
                badgeColor: const Color(0xFF166534),
                badgeBg: const Color(0xFFDCFCE7),
              ),
              const SizedBox(width: 4),
              _buildSubModeItem(
                index: 1,
                label: '➕ Instant Add-On Boosters',
                badge: 'Instant Activation',
                badgeColor: const Color(0xFFB45309),
                badgeBg: const Color(0xFFFEF3C7),
              ),
              const SizedBox(width: 4),
              _buildSubModeItem(
                index: 2,
                label: '✦ View All Modules & Add-Ons',
                badge: 'Full Suite',
                badgeColor: const Color(0xFF4338CA),
                badgeBg: const Color(0xFFEEF2FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubModeItem({
    required int index,
    required String label,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    final bool isSelected = _activeSubMode == index;

    return InkWell(
      onTap: () {
        setState(() {
          _activeSubMode = index;
        });
      },
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_darkForestGreen, Color(0xFF166534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _darkForestGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.22) : badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. SECTION HEADER WITH CONTROLS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionHeaderWithControls(bool isNarrow) {
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _darkForestGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Customize Workspace & Add-On Boosters',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _darkHeading,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildHeaderJumpPill(
                icon: LucideIcons.arrowUp,
                label: 'Active Plan',
                onTap: widget.onScrollToActivePlan,
              ),
              _buildHeaderJumpPill(
                icon: LucideIcons.arrowDown,
                label: 'Billing History',
                onTap: widget.onScrollToBillingHistory,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Build a tailor-made plan matching your exact business size, or add instant quota boosters to your active plan.',
            style: GoogleFonts.inter(
              fontSize: widget.isMobile ? 12 : 13,
              color: _slateText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _buildAdminSimulatorControl(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _darkForestGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Customize Workspace & Add-On Boosters',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _darkHeading,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildHeaderJumpPill(
              icon: LucideIcons.arrowUp,
              label: 'Active Plan',
              onTap: widget.onScrollToActivePlan,
            ),
            const SizedBox(width: 8),
            _buildHeaderJumpPill(
              icon: LucideIcons.arrowDown,
              label: 'Billing History',
              onTap: widget.onScrollToBillingHistory,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Build a tailor-made plan matching your exact business size, or add instant quota boosters to your active plan.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _slateText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildAdminSimulatorControl(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderJumpPill({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF475569)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSimulatorControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.flaskConical, size: 13, color: Color(0xFFB45309)),
              const SizedBox(width: 6),
              Text(
                'Simulate Admin Approval:',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<AdminApprovalStatus>(
              value: _adminStatus,
              isDense: true,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
              items: const [
                DropdownMenuItem(
                  value: AdminApprovalStatus.idle,
                  child: Text('Idle (New)'),
                ),
                DropdownMenuItem(
                  value: AdminApprovalStatus.pending,
                  child: Text('⏳ Pending Review (2h SLA)'),
                ),
                DropdownMenuItem(
                  value: AdminApprovalStatus.approved,
                  child: Text('✅ Approved (Ready to Pay)'),
                ),
                DropdownMenuItem(
                  value: AdminApprovalStatus.rejected,
                  child: Text('❌ Rejected / Revise'),
                ),
              ],
              onChanged: (newStatus) {
                if (newStatus != null) {
                  setState(() => _adminStatus = newStatus);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LEFT COLUMN: Interactive Configurator
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLeftConfiguratorColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Plan Sections when mode is 0 or 2
        if (_activeSubMode == 0 || _activeSubMode == 2) ...[
          _buildSectionABaseFoundation(),
          const SizedBox(height: 24),
          _buildSectionBCapacitySliders(),
          const SizedBox(height: 24),
          _buildSectionCModularModules(),
          const SizedBox(height: 24),
        ],

        // Instant Add-On Boosters when mode is 1 or 2
        if (_activeSubMode == 1 || _activeSubMode == 2) ...[
          _buildSectionDInstantAddons(),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION A: Core Base Platform Foundation
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionABaseFoundation() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFFCFDF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkForestGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 520;
              final iconWidget = Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_darkForestGreen, Color(0xFF166534)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _darkForestGreen.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.lock, color: Colors.white, size: 20),
                ),
              );

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'SECTION A: Base Platform Foundation',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _emeraldBrand,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          'ALWAYS INCLUDED',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cliks Core Workspace Foundation',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _darkHeading,
                    ),
                  ),
                ],
              );

              final priceWidget = Column(
                crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹$_baseFloorPrice ',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _darkForestGreen,
                          ),
                        ),
                        TextSpan(
                          text: '/ mo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _slateText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Billed annually (₹1,788/yr)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconWidget,
                        const SizedBox(width: 12),
                        Expanded(child: titleWidget),
                      ],
                    ),
                    const SizedBox(height: 12),
                    priceWidget,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconWidget,
                  const SizedBox(width: 14),
                  Expanded(child: titleWidget),
                  const SizedBox(width: 12),
                  priceWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDCFCE7), height: 1),
          const SizedBox(height: 14),
          Text(
            'Mandatory foundational workspace. Included automatically in every custom plan:',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FoundationPill(label: 'Unlimited Accounting & Day Book Logs'),
              _FoundationPill(label: 'Basic GSTR-1/3B Reconciliation Reports'),
              _FoundationPill(label: 'Single-Warehouse Inventory (up to 5,000 items)'),
              _FoundationPill(label: 'Simple Billing & Direct Tax Invoicing'),
              _FoundationPill(label: '1 GB Secure Cloud Vault Storage'),
              _FoundationPill(label: 'Standard Email Support (24h SLA)'),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION B: Interactive Capacity Sliders
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionBCapacitySliders() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 520;
              final iconWidget = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(LucideIcons.sliders, color: Color(0xFF4338CA), size: 18),
                ),
              );

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECTION B: Dynamic Capacity Sizing',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4338CA),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Interactive Quantitative Limits',
                    style: GoogleFonts.inter(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: _darkHeading,
                    ),
                  ),
                ],
              );

              final badgeWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ ₹$_totalCapacityPrice / mo total',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _darkForestGreen,
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconWidget,
                        const SizedBox(width: 10),
                        Expanded(child: titleWidget),
                      ],
                    ),
                    const SizedBox(height: 8),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Expanded(child: titleWidget),
                  const SizedBox(width: 8),
                  badgeWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 18),

          // 1. Organization Users & Role Access (2 to 100)
          _buildSliderItem(
            title: 'Organization Users & Role Access',
            subtitle: '2 users included in base platform. Scale for staff, accountants & managers.',
            currentValue: _usersCount,
            min: 2,
            max: 100,
            unit: 'Users',
            extraPricePerUnit: 49,
            includedCount: 2,
            calculatedMonthlyPrice: _capacityUsersPrice,
            onChanged: (val) => setState(() => _usersCount = val.round()),
          ),
          const SizedBox(height: 20),

          // 2. Warehouses / Showrooms (1 to 50)
          _buildSliderItem(
            title: 'Warehouses / Showrooms (Multi-Site Sync)',
            subtitle: '1 central site included in base. Sync inventory across stores & depots.',
            currentValue: _warehouseCount,
            min: 1,
            max: 50,
            unit: 'Sites',
            extraPricePerUnit: 99,
            includedCount: 1,
            calculatedMonthlyPrice: _capacityWarehousePrice,
            onChanged: (val) => setState(() => _warehouseCount = val.round()),
          ),
          const SizedBox(height: 20),

          // 3. Annual Invoices & Bills Capacity (Segmented)
          _buildSegmentedCapacityItem(
            title: 'Annual Invoices & Bills Capacity',
            subtitle: 'Fast invoice numbering, e-invoicing limits & transaction archiving.',
            selectedIndex: _invoicesTierIndex,
            options: _invoiceOptions,
            onSelect: (idx) => setState(() => _invoicesTierIndex = idx),
          ),
          const SizedBox(height: 20),

          // 4. Products / Stock SKU Limit (Segmented)
          _buildSegmentedCapacityItem(
            title: 'Products / Stock SKU Limit',
            subtitle: 'Catalog items, serial numbers, barcodes & multi-variant tracking.',
            selectedIndex: _skuTierIndex,
            options: _skuOptions,
            onSelect: (idx) => setState(() => _skuTierIndex = idx),
          ),
          const SizedBox(height: 20),

          // 5. Active HR Staff Capacity (5 to 250)
          _buildSliderItem(
            title: 'Active HR Staff Capacity',
            subtitle: '5 staff members included in base. Track employee records & payroll.',
            currentValue: _staffCount,
            min: 5,
            max: 250,
            unit: 'Staff',
            extraPricePerUnit: 15,
            includedCount: 5,
            calculatedMonthlyPrice: _capacityStaffPrice,
            onChanged: (val) => setState(() => _staffCount = val.round()),
          ),
          const SizedBox(height: 20),

          // 6. POS Billing Counters / Terminals (1 to 25)
          _buildSliderItem(
            title: 'POS Billing Counters / Terminals',
            subtitle: '1 billing counter included. Add cashier desks & quick-checkout terminals.',
            currentValue: _posTerminalsCount,
            min: 1,
            max: 25,
            unit: 'Counters',
            extraPricePerUnit: 119,
            includedCount: 1,
            calculatedMonthlyPrice: _capacityPosPrice,
            onChanged: (val) => setState(() => _posTerminalsCount = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
    required String title,
    required String subtitle,
    required int currentValue,
    required double min,
    required double max,
    required String unit,
    required int extraPricePerUnit,
    required int includedCount,
    required int calculatedMonthlyPrice,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: calculatedMonthlyPrice > 0
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
          width: calculatedMonthlyPrice > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: calculatedMonthlyPrice > 0
                ? _darkForestGreen.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 420;

          final titleWidget = Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _darkHeading,
            ),
          );

          final badgeWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: calculatedMonthlyPrice > 0
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: calculatedMonthlyPrice > 0
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              calculatedMonthlyPrice > 0
                  ? '+ ₹$calculatedMonthlyPrice / mo'
                  : 'Included in Base',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: calculatedMonthlyPrice > 0
                    ? const Color(0xFF15803D)
                    : const Color(0xFF64748B),
              ),
            ),
          );

          final stepperWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallStepBtn(
                icon: LucideIcons.minus,
                onTap: currentValue > min ? () => onChanged((currentValue - 1).toDouble()) : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$currentValue $unit',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _darkForestGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSmallStepBtn(
                icon: LucideIcons.plus,
                onTap: currentValue < max ? () => onChanged((currentValue + 1).toDouble()) : null,
              ),
            ],
          );

          final sliderWidget = Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _darkForestGreen,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: _darkForestGreen,
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  elevation: 3,
                ),
                overlayColor: _darkForestGreen.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: currentValue.toDouble(),
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
              ),
            ),
          );

          final maxWidget = Text(
            '${max.toInt()} max',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _slateText,
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                titleWidget,
                const SizedBox(height: 6),
                badgeWidget,
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleWidget),
                    const SizedBox(width: 8),
                    badgeWidget,
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: _slateText,
                ),
              ),
              const SizedBox(height: 12),
              if (isCompact) ...[
                stepperWidget,
                const SizedBox(height: 6),
                Row(
                  children: [
                    sliderWidget,
                    const SizedBox(width: 8),
                    maxWidget,
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    stepperWidget,
                    const SizedBox(width: 14),
                    sliderWidget,
                    const SizedBox(width: 8),
                    maxWidget,
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentedCapacityItem({
    required String title,
    required String subtitle,
    required int selectedIndex,
    required List<Map<String, dynamic>> options,
    required ValueChanged<int> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (options[selectedIndex]['price'] as int) > 0
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
          width: (options[selectedIndex]['price'] as int) > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (options[selectedIndex]['price'] as int) > 0
                ? _darkForestGreen.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 420;

          final titleWidget = Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _darkHeading,
            ),
          );

          final badgeWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (options[selectedIndex]['price'] as int) > 0
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (options[selectedIndex]['price'] as int) > 0
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              options[selectedIndex]['badge'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: (options[selectedIndex]['price'] as int) > 0
                    ? const Color(0xFF15803D)
                    : const Color(0xFF64748B),
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                titleWidget,
                const SizedBox(height: 6),
                badgeWidget,
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleWidget),
                    const SizedBox(width: 8),
                    badgeWidget,
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: _slateText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(options.length, (idx) {
                  final opt = options[idx];
                  final bool isSelected = selectedIndex == idx;
                  return InkWell(
                    onTap: () => onSelect(idx),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? _darkForestGreen : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? _darkForestGreen : const Color(0xFFCBD5E1),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _darkForestGreen.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        runSpacing: 2,
                        children: [
                          Text(
                            opt['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : _darkHeading,
                            ),
                          ),
                          Text(
                            '(${opt['badge']})',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white.withValues(alpha: 0.85) : _slateText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION C: Modular Feature Picklist (14 Modules)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionCModularModules() {
    final businessModules = _allModules.where((m) => m['group'] == 'Business ERP').toList();
    final finProModules = _allModules.where((m) => m['group'] == 'FIN-PRO Practice').toList();
    final launchDeskModules = _allModules.where((m) => m['group'] == 'Partner Launch Desk').toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 520;
              final iconWidget = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(LucideIcons.boxes, color: Color(0xFF059669), size: 18),
                ),
              );

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECTION C: Modular Feature Picklist',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Select Only What Your Business Needs',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _darkHeading,
                    ),
                  ),
                ],
              );

              final badgeWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedModules.length} selected (+ ₹$_totalModulesPrice / mo)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _darkForestGreen,
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconWidget,
                        const SizedBox(width: 10),
                        Expanded(child: titleWidget),
                      ],
                    ),
                    const SizedBox(height: 8),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Expanded(child: titleWidget),
                  const SizedBox(width: 8),
                  badgeWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          // Group 1: Business ERP Modules (10)
          _buildModuleGroupHeading('1. Business & Enterprise ERP Modules', '10 selectable modules'),
          const SizedBox(height: 12),
          _buildModuleCardsGrid(businessModules),
          const SizedBox(height: 24),

          // Group 2: FIN-PRO Modules (2)
          _buildModuleGroupHeading('2. FIN-PRO (CA / Auditor Practice Modules)', 'Audit vouching & compliance engine'),
          const SizedBox(height: 12),
          _buildModuleCardsGrid(finProModules),
          const SizedBox(height: 24),

          // Group 3: Partner Launch Desk (2)
          _buildModuleGroupHeading('3. Partner Launch Desk (Investor & Founder Modules)', 'Startup deal rooms & spotlight directory'),
          const SizedBox(height: 12),
          _buildModuleCardsGrid(launchDeskModules),
        ],
      ),
    );
  }

  Widget _buildModuleGroupHeading(String title, String countText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkHeading,
                  ),
                ),
                TextSpan(
                  text: '($countText)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: _slateText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCardsGrid(List<Map<String, dynamic>> modules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 650) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 950) {
          crossAxisCount = 2;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: modules.map((m) {
            final double cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;
            return SizedBox(
              width: cardWidth.floorToDouble(),
              child: _buildSingleModuleCard(m),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSingleModuleCard(Map<String, dynamic> mod) {
    final String id = mod['id'] as String;
    final bool isSelected = _selectedModules.contains(id);
    final bool isGold = mod['isGold'] as bool;
    final int price = mod['price'] as int;

    final Color activeBorder = isGold ? _goldBrand : _emeraldBrand;
    final Color activeBadgeBg = isGold ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7);
    final Color activeBadgeText = isGold ? const Color(0xFFB45309) : const Color(0xFF15803D);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedModules.remove(id);
          } else {
            _selectedModules.add(id);
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isGold ? const Color(0xFFFFFDF5) : const Color(0xFFF0FDF4))
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeBorder : const Color(0xFFE2E8F0),
            width: isSelected ? 1.75 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBorder.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isGold ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0))
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      mod['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? (isGold ? const Color(0xFF92400E) : const Color(0xFF14532D))
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mod['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _darkHeading,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: activeBadgeBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isGold
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF86EFAC).withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '+ ₹$price / mo',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activeBadgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  activeColor: activeBorder,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedModules.add(id);
                      } else {
                        _selectedModules.remove(id);
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              mod['desc'] as String,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: _slateText,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // If FinPro client pack is selected, show extra client stepper
            if (id == 'finpro_client_pack' && isSelected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Extra Client Ledgers:',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          Text(
                            '+₹25/mo per client',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _slateText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSmallStepBtn(
                      icon: LucideIcons.minus,
                      onTap: _finProExtraClients > 0
                          ? () => setState(() => _finProExtraClients--)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_finProExtraClients',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _darkHeading,
                        ),
                      ),
                    ),
                    _buildSmallStepBtn(
                      icon: LucideIcons.plus,
                      onTap: () => setState(() => _finProExtraClients++),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION D: Instant Add-On Boosters & Top-Up Packs
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionDInstantAddons() {
    final addonsList = [
      {
        'id': 'addon_finpro_seat',
        'title': 'Extra Fin-Pro Audit Team Member Seat',
        'type': 'Instant Recurring Add-On',
        'price': '₹299 / mo per seat',
        'desc': 'Empower staff accountants to conduct audits under your practice umbrella.',
        'icon': LucideIcons.userPlus,
        'isRecurring': true,
        'rate': 299,
      },
      {
        'id': 'addon_cloud_storage',
        'title': 'Cloud Vault Storage Booster (+25 GB Pack)',
        'type': 'Instant Recurring Add-On',
        'price': '₹99 / mo per 25 GB',
        'desc': 'Store unlimited high-res invoice scans, audit evidence & bill attachments.',
        'icon': LucideIcons.hardDrive,
        'isRecurring': true,
        'rate': 99,
      },
      {
        'id': 'addon_pitch_unlock',
        'title': 'Startup Pitch Unlock Quota Booster (+10 Pitches)',
        'type': 'Instant Credit Top-Up for Investors',
        'price': '₹499 one-time',
        'desc': 'Unlock 10 direct founder deal rooms, pitch decks & verified revenue metrics.',
        'icon': LucideIcons.unlock,
        'isRecurring': false,
        'rate': 499,
      },
      {
        'id': 'addon_founder_spotlight',
        'title': 'Founder Homepage Spotlight Boost (7 Days Featured)',
        'type': 'Instant Visibility Booster for Founders',
        'price': '₹799 one-time',
        'desc': 'Top spotlight banner on Cliks Investor directory for 7 consecutive days.',
        'icon': LucideIcons.sparkles,
        'isRecurring': false,
        'rate': 799,
      },
      {
        'id': 'addon_einvoice_credits',
        'title': 'High-Volume E-Invoice / E-Way API Pack (+1,000 Credits)',
        'type': 'Instant Tax Quota Top-Up',
        'price': '₹199 one-time',
        'desc': 'Instant IRN voucher credits & automated NIC portal synchronization.',
        'icon': LucideIcons.fileText,
        'isRecurring': false,
        'rate': 199,
      },
      {
        'id': 'addon_whatsapp_credits',
        'title': 'WhatsApp / SMS Verified Notification Pack (+2,500 Messages)',
        'type': 'Instant Marketing Top-Up',
        'price': '₹299 one-time',
        'desc': 'Send payment reminders, invoice PDF links & festival broadcast alerts.',
        'icon': LucideIcons.messageSquare,
        'isRecurring': false,
        'rate': 299,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 520;
              final iconWidget = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(LucideIcons.zap, color: Color(0xFFB45309), size: 18),
                ),
              );

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECTION D: Instant Workspace Boosters',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Instant Add-On Boosters (Works With Any Plan — No Admin Wait)',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _darkHeading,
                    ),
                  ),
                ],
              );

              final badgeWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚡ Instant 0-Sec Activation',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF15803D),
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconWidget,
                        const SizedBox(width: 10),
                        Expanded(child: titleWidget),
                      ],
                    ),
                    const SizedBox(height: 8),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Expanded(child: titleWidget),
                  const SizedBox(width: 8),
                  badgeWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Need more quota right now? Top-ups activate immediately to your active workspace without modifying your base tier or awaiting admin review.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: _slateText,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth < 650) crossAxisCount = 1;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: addonsList.map((addon) {
                  final double cardWidth =
                      (constraints.maxWidth - ((crossAxisCount - 1) * 14)) / crossAxisCount;
                  return SizedBox(
                    width: cardWidth.floorToDouble(),
                    child: _buildAddonPackCard(addon),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddonPackCard(Map<String, dynamic> addon) {
    final String id = addon['id'] as String;
    final int qty = _addonQuantities[id] ?? 0;
    final bool isSelected = qty > 0;
    final bool isRecurring = addon['isRecurring'] as bool;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.75 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDE68A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    addon['icon'] as IconData,
                    size: 18,
                    color: isSelected ? const Color(0xFFB45309) : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addon['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _darkHeading,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isRecurring ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isRecurring ? const Color(0xFFBAE6FD) : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        addon['type'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isRecurring ? const Color(0xFF0284C7) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            addon['desc'] as String,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: _slateText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  addon['price'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _darkForestGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallStepBtn(
                    icon: LucideIcons.minus,
                    onTap: qty > 0
                        ? () => setState(() => _addonQuantities[id] = qty - 1)
                        : null,
                  ),
                  Container(
                    width: 34,
                    alignment: Alignment.center,
                    child: Text(
                      '$qty',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: qty > 0 ? const Color(0xFFB45309) : _slateText,
                      ),
                    ),
                  ),
                  _buildSmallStepBtn(
                    icon: LucideIcons.plus,
                    onTap: () => setState(() => _addonQuantities[id] = qty + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RIGHT COLUMN: Sticky Live Estimate & Admin Approval Card
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRightStickySummaryCard() {
    final bool isEliteThresholdCrossed = _monthlyCustomSubtotal >= 999;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mintBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkForestGreen.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _darkForestGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(LucideIcons.receipt, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Custom Plan & Add-On Summary',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _darkHeading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Admin Status Stepper Indicator
          _buildAdminStatusStepperBanner(),
          const SizedBox(height: 16),

          // Billing Cycle Switcher Pill
          _buildBillingCyclePill(),
          const SizedBox(height: 16),

          // Itemized Breakdown Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LIVE ITEMIZED BREAKDOWN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _slateText,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                'Monthly Rate',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _slateText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Base floor
          _buildSummaryLineItem(
            label: 'Core Workspace Foundation',
            sublabel: 'Base platform floor (Included)',
            priceText: '₹$_baseFloorPrice / mo',
            isBold: true,
          ),

          // 2. Capacity Upgrades
          if (_capacityUsersPrice > 0)
            _buildSummaryLineItem(
              label: '$_usersCount Users (${_usersCount - 2} extra)',
              sublabel: '+₹49/mo per user',
              priceText: '+ ₹$_capacityUsersPrice / mo',
            ),
          if (_capacityWarehousePrice > 0)
            _buildSummaryLineItem(
              label: '$_warehouseCount Warehouses (${_warehouseCount - 1} extra)',
              sublabel: '+₹99/mo per warehouse',
              priceText: '+ ₹$_capacityWarehousePrice / mo',
            ),
          if (_capacityInvoicesPrice > 0)
            _buildSummaryLineItem(
              label: _invoiceOptions[_invoicesTierIndex]['label'] as String,
              sublabel: 'Invoice & Bill throughput upgrade',
              priceText: '+ ₹$_capacityInvoicesPrice / mo',
            ),
          if (_capacitySkuPrice > 0)
            _buildSummaryLineItem(
              label: _skuOptions[_skuTierIndex]['label'] as String,
              sublabel: 'Stock catalog SKU upgrade',
              priceText: '+ ₹$_capacitySkuPrice / mo',
            ),
          if (_capacityStaffPrice > 0)
            _buildSummaryLineItem(
              label: '$_staffCount Staff (${_staffCount - 5} extra)',
              sublabel: '+₹15/mo per staff',
              priceText: '+ ₹$_capacityStaffPrice / mo',
            ),
          if (_capacityPosPrice > 0)
            _buildSummaryLineItem(
              label: '$_posTerminalsCount POS Terminals (${_posTerminalsCount - 1} extra)',
              sublabel: '+₹119/mo per counter',
              priceText: '+ ₹$_capacityPosPrice / mo',
            ),

          // 3. Selected Functional Modules
          for (final modId in _selectedModules) ...[
            Builder(
              builder: (ctx) {
                final mod = _allModules.firstWhere((m) => m['id'] == modId);
                final price = mod['price'] as int;
                return _buildSummaryLineItem(
                  label: mod['title'] as String,
                  sublabel: mod['group'] as String,
                  priceText: '+ ₹$price / mo',
                );
              },
            ),
          ],
          if (_selectedModules.contains('finpro_client_pack') && _finProExtraClients > 0)
            _buildSummaryLineItem(
              label: '$_finProExtraClients Extra FIN-PRO Clients',
              sublabel: '+₹25/mo per client',
              priceText: '+ ₹${_finProExtraClients * 25} / mo',
            ),

          // 4. Recurring Add-ons
          if (_recurringAddonsSubtotal > 0) ...[
            const SizedBox(height: 6),
            Text(
              'RECURRING ADD-ONS',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 4),
            if (_addonQuantities['addon_finpro_seat']! > 0)
              _buildSummaryLineItem(
                label: 'Extra Fin-Pro Seat (x${_addonQuantities['addon_finpro_seat']})',
                sublabel: 'Recurring seat add-on',
                priceText: '+ ₹${_addonQuantities['addon_finpro_seat']! * 299} / mo',
              ),
            if (_addonQuantities['addon_cloud_storage']! > 0)
              _buildSummaryLineItem(
                label: '+25 GB Cloud Storage (x${_addonQuantities['addon_cloud_storage']})',
                sublabel: 'Recurring cloud pack',
                priceText: '+ ₹${_addonQuantities['addon_cloud_storage']! * 99} / mo',
              ),
          ],

          // 5. One-time Add-on packs
          if (_oneTimeAddonsSubtotal > 0) ...[
            const SizedBox(height: 6),
            Text(
              'ONE-TIME QUOTA TOP-UPS',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 4),
            if (_addonQuantities['addon_pitch_unlock']! > 0)
              _buildSummaryLineItem(
                label: '+10 Investor Pitches (x${_addonQuantities['addon_pitch_unlock']})',
                sublabel: 'One-time unlock credit',
                priceText: '₹${_addonQuantities['addon_pitch_unlock']! * 499} once',
              ),
            if (_addonQuantities['addon_founder_spotlight']! > 0)
              _buildSummaryLineItem(
                label: '7-Day Homepage Spotlight (x${_addonQuantities['addon_founder_spotlight']})',
                sublabel: 'One-time featured promo',
                priceText: '₹${_addonQuantities['addon_founder_spotlight']! * 799} once',
              ),
            if (_addonQuantities['addon_einvoice_credits']! > 0)
              _buildSummaryLineItem(
                label: '+1,000 E-Invoice Credits (x${_addonQuantities['addon_einvoice_credits']})',
                sublabel: 'One-time tax pack',
                priceText: '₹${_addonQuantities['addon_einvoice_credits']! * 199} once',
              ),
            if (_addonQuantities['addon_whatsapp_credits']! > 0)
              _buildSummaryLineItem(
                label: '+2,500 WhatsApp Messages (x${_addonQuantities['addon_whatsapp_credits']})',
                sublabel: 'One-time notification credits',
                priceText: '₹${_addonQuantities['addon_whatsapp_credits']! * 299} once',
              ),
          ],

          // Smart Comparison Alert Banner (if >= 999/mo)
          if (isEliteThresholdCrossed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.lightbulb, size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 Tip: Your selection is close to Tier 4 (Elite at ₹999/mo), which unlocks Unlimited everything!',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 14),

          // Total Price Display in Bento Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF86EFAC).withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF15803D).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
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
                        'CUSTOM PLAN TOTAL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166534),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹$_effectiveMonthlyPrice ',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _darkForestGreen,
                            ),
                          ),
                          TextSpan(
                            text: '/ mo',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFBBF7D0), height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isAnnualBilling ? 'Annualized (-20%)' : 'Monthly recurring',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF15803D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Net: ₹$_netPayableAmount',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _darkHeading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _isAnnualBilling
                        ? 'Billed at ₹$_billedAnnualPrice / yr + 18% GST (₹$_gstAmount)'
                        : '+ 18% GST (₹$_gstAmount)',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF14532D),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          // One-Time Add-On Total line if any
          if (_oneTimeAddonsSubtotal > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'One-Time Add-Ons (+18% GST):',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹$_netOneTimePayable',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Custom Note for Admin
          Text(
            'Custom Note for Admin Review:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _darkHeading,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _adminNoteController,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 12),
            decoration: InputDecoration(
              hintText:
                  'Add business requirements or request a custom enterprise discount for Admin review...',
              hintStyle: GoogleFonts.inter(fontSize: 11, color: _slateText),
              contentPadding: const EdgeInsets.all(10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _darkForestGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dual Action Buttons
          _buildPrimaryAdminButton(),
          const SizedBox(height: 10),

          if (_hasAnyInstantAddon) ...[
            _buildInstantAddonsPayButton(),
            const SizedBox(height: 10),
          ],

          Center(
            child: Text(
              '🔒 Encrypted SSL • 24h Admin SLA • Instant Invoice Generated',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: _slateText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStatusStepperBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _adminStatus == AdminApprovalStatus.approved
            ? const Color(0xFFDCFCE7)
            : _adminStatus == AdminApprovalStatus.pending
                ? const Color(0xFFFEF3C7)
                : _adminStatus == AdminApprovalStatus.rejected
                    ? const Color(0xFFFFE4E6)
                    : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _adminStatus == AdminApprovalStatus.approved
              ? const Color(0xFF86EFAC)
              : _adminStatus == AdminApprovalStatus.pending
                  ? const Color(0xFFFDE68A)
                  : _adminStatus == AdminApprovalStatus.rejected
                      ? const Color(0xFFFECDD3)
                      : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStepNode(
              stepNum: 1,
              label: 'Sent',
              isActive: _adminStatus != AdminApprovalStatus.idle,
              isCompleted: _adminStatus == AdminApprovalStatus.pending ||
                  _adminStatus == AdminApprovalStatus.approved,
            ),
          ),
          const Icon(LucideIcons.arrowRight, size: 12, color: Color(0xFF94A3B8)),
          Expanded(
            child: _buildStepNode(
              stepNum: 2,
              label: 'Review (2h)',
              isActive: _adminStatus == AdminApprovalStatus.pending ||
                  _adminStatus == AdminApprovalStatus.approved,
              isCompleted: _adminStatus == AdminApprovalStatus.approved,
            ),
          ),
          const Icon(LucideIcons.arrowRight, size: 12, color: Color(0xFF94A3B8)),
          Expanded(
            child: _buildStepNode(
              stepNum: 3,
              label: 'Approved',
              isActive: _adminStatus == AdminApprovalStatus.approved,
              isCompleted: _adminStatus == AdminApprovalStatus.approved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNum,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color color = isCompleted
        ? const Color(0xFF166534)
        : isActive
            ? const Color(0xFFB45309)
            : const Color(0xFF94A3B8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(LucideIcons.check, size: 10, color: Colors.white)
                : Text(
                    '$stepNum',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCyclePill() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isAnnualBilling = true),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isAnnualBilling ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isAnnualBilling
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Annual Billing',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: _isAnnualBilling ? FontWeight.w800 : FontWeight.w600,
                          color: _isAnnualBilling ? _darkForestGreen : _slateText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Save 20%',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isAnnualBilling = false),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isAnnualBilling ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_isAnnualBilling
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Monthly Billing',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: !_isAnnualBilling ? FontWeight.w800 : FontWeight.w600,
                      color: !_isAnnualBilling ? _darkHeading : _slateText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLineItem({
    required String label,
    required String sublabel,
    required String priceText,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                    color: _darkHeading,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: _slateText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            priceText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isBold ? _darkForestGreen : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAdminButton() {
    String label;
    IconData icon;
    List<Color> gradientColors;
    Color shadowColor;

    switch (_adminStatus) {
      case AdminApprovalStatus.idle:
        label = '🚀 Submit Custom Plan to Admin';
        icon = LucideIcons.send;
        gradientColors = const [Color(0xFF0D5E36), Color(0xFF15803D)];
        shadowColor = const Color(0xFF0D5E36);
        break;
      case AdminApprovalStatus.pending:
        label = '⏳ Under Review (Admin SLA: 2 Hrs)';
        icon = LucideIcons.clock;
        gradientColors = const [Color(0xFFB45309), Color(0xFFD97706)];
        shadowColor = const Color(0xFFB45309);
        break;
      case AdminApprovalStatus.approved:
        label = '🔒 Approved & Ready — Pay ₹$_netPayableAmount';
        icon = LucideIcons.shieldCheck;
        gradientColors = const [Color(0xFF166534), Color(0xFF15803D)];
        shadowColor = const Color(0xFF166534);
        break;
      case AdminApprovalStatus.rejected:
        label = '🔄 Revise & Resubmit to Admin';
        icon = LucideIcons.refreshCw;
        gradientColors = const [Color(0xFF991B1B), Color(0xFFDC2626)];
        shadowColor = const Color(0xFF991B1B);
        break;
    }

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePrimaryAction(),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstantAddonsPayButton() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleInstantAddonPayment(),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.zap, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '⚡ Pay & Activate Add-Ons Instantly (₹$_netOneTimePayable)',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Handlers ---
  void _handlePrimaryAction() {
    if (_adminStatus == AdminApprovalStatus.idle || _adminStatus == AdminApprovalStatus.rejected) {
      _showSubmissionConfirmationDialog();
    } else if (_adminStatus == AdminApprovalStatus.pending) {
      _showPendingReviewInfoDialog();
    } else if (_adminStatus == AdminApprovalStatus.approved) {
      _showPaymentCheckoutDialog();
    }
  }

  void _showSubmissionConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.send, color: Color(0xFF15803D), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Submit Custom Plan for Admin Review',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your tailored enterprise configuration will be submitted directly to our Cliks Workspace Operations team. We review and approve bespoke plans within 2 hours.',
              style: GoogleFonts.inter(fontSize: 13, color: _slateText),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildModalSummaryRow('Configuration Base:', 'Cliks Core Foundation (₹149/mo)'),
                  _buildModalSummaryRow('Users & Sites:', '$_usersCount Users • $_warehouseCount Sites'),
                  _buildModalSummaryRow('Selected Modules:', '${_selectedModules.length} Functional Modules'),
                  _buildModalSummaryRow('Estimated Monthly Rate:', '₹$_effectiveMonthlyPrice / mo (+GST)'),
                  if (_adminNoteController.text.trim().isNotEmpty)
                    _buildModalSummaryRow('Your Note:', _adminNoteController.text.trim()),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _slateText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _adminStatus = AdminApprovalStatus.pending;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Custom Plan successfully submitted! Admin review is in progress (2h SLA).',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _darkForestGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkForestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Confirm & Submit Request',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showPendingReviewInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.clock, color: Color(0xFFB45309), size: 22),
            const SizedBox(width: 10),
            Text(
              'Request Under Review',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Your bespoke plan is currently being verified by an Enterprise Desk Administrator.\n\nGuaranteed SLA: Within 2 hours.\nWe will notify you via email and in-app banner once approved.',
          style: GoogleFonts.inter(fontSize: 13, color: _slateText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Got It', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPaymentCheckoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF15803D), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activate Approved Custom Plan',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin has approved your custom configuration! Proceed to complete activation for your workspace.',
              style: GoogleFonts.inter(fontSize: 13, color: _slateText),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildModalSummaryRow('Effective Rate:', '₹$_effectiveMonthlyPrice / mo'),
                  _buildModalSummaryRow('Cycle:', _isAnnualBilling ? 'Annual (Save 20%)' : 'Monthly'),
                  _buildModalSummaryRow('18% GST:', '₹$_gstAmount'),
                  const Divider(color: Color(0xFFE2E8F0)),
                  _buildModalSummaryRow('Total Net Payable:', '₹$_netPayableAmount', isBold: true),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _slateText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment successful! Your custom workspace plan is now active.',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: _darkForestGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Pay & Activate Workspace',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleInstantAddonPayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.zap, color: Color(0xFFB45309), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Instant Add-On Activation',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'These add-on boosters will be immediately provisioned to your current active plan without modifying your core subscription tier.',
              style: GoogleFonts.inter(fontSize: 13, color: _slateText),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildModalSummaryRow('Add-On Subtotal:', '₹$_oneTimeAddonsSubtotal'),
                  _buildModalSummaryRow('18% GST:', '₹$_oneTimeGst'),
                  const Divider(color: Color(0xFFE2E8F0)),
                  _buildModalSummaryRow('Net Immediate Charge:', '₹$_netOneTimePayable', isBold: true),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _slateText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚡ Boosters Activated! Quotas updated in your workspace.',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF166534),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Pay & Provision Instantly',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? _darkHeading : _slateText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                color: isBold ? _darkForestGreen : _darkHeading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStepBtn({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: onTap != null ? _darkHeading : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _FoundationPill extends StatelessWidget {
  final String label;

  const _FoundationPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textWidget = Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF166534),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(LucideIcons.check, size: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              constraints.maxWidth.isFinite
                  ? Flexible(child: textWidget)
                  : textWidget,
            ],
          ),
        );
      },
    );
  }
}
