import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_product_model.dart';
import '../models/customer_view_settings_model.dart';
import '../providers/customer_view_provider.dart';

class CustomerViewSettingsPage extends ConsumerStatefulWidget {
  const CustomerViewSettingsPage({super.key});

  @override
  ConsumerState<CustomerViewSettingsPage> createState() =>
      _CustomerViewSettingsPageState();
}

class _CustomerViewSettingsPageState
    extends ConsumerState<CustomerViewSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _businessNameCtrl;
  late TextEditingController _headlineCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _prepTimeCtrl;
  late TextEditingController _promoTitleCtrl;
  late TextEditingController _promoSubtitleCtrl;
  late TextEditingController _attractHeadlineCtrl;
  final TextEditingController _visibilitySearchCtrl = TextEditingController();

  late CustomerViewSettings _draftSettings;
  CustomerProduct? _selectedProductForImage;
  String? _selectedProductId;
  String? _pickedImagePath;
  String _visibilitySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final settings = ref.read(customerViewProvider).settings;
    _draftSettings = settings;

    _businessNameCtrl = TextEditingController(text: settings.businessName);
    _headlineCtrl = TextEditingController(text: settings.welcomeHeadline);
    _subtitleCtrl = TextEditingController(text: settings.welcomeSubtitle);
    _prepTimeCtrl =
        TextEditingController(text: settings.defaultPreparationMinutes.toString());
    _promoTitleCtrl = TextEditingController(text: settings.promoBannerTitle);
    _promoSubtitleCtrl = TextEditingController(text: settings.promoBannerSubtitle);
    _attractHeadlineCtrl = TextEditingController(text: settings.attractHeadline);

    final products = ref.read(customerViewProvider).products;
    if (products.isNotEmpty) {
      _selectedProductId = products.first.id;
      _selectedProductForImage = products.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameCtrl.dispose();
    _headlineCtrl.dispose();
    _subtitleCtrl.dispose();
    _prepTimeCtrl.dispose();
    _promoTitleCtrl.dispose();
    _promoSubtitleCtrl.dispose();
    _attractHeadlineCtrl.dispose();
    _visibilitySearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageForSelectedProduct() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select Product Image for Customer Kiosk',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedImagePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _saveProductImage() {
    final products = ref.read(customerViewProvider).products;
    if (products.isEmpty) return;
    final currentProduct = products.firstWhere(
      (p) => p.id == (_selectedProductId ?? _selectedProductForImage?.id),
      orElse: () => products.first,
    );

    if (_pickedImagePath != null) {
      ref.read(customerViewProvider.notifier).setProductCustomImage(
            currentProduct.id,
            _pickedImagePath!,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated image for ${currentProduct.name}',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _pickedImagePath = null;
      });
    }
  }

  void _removeProductImage() {
    final products = ref.read(customerViewProvider).products;
    if (products.isEmpty) return;
    final currentProduct = products.firstWhere(
      (p) => p.id == (_selectedProductId ?? _selectedProductForImage?.id),
      orElse: () => products.first,
    );

    ref.read(customerViewProvider.notifier).removeProductCustomImage(
          currentProduct.id,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reset image to default for ${currentProduct.name}',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF4B5563),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _pickedImagePath = null;
    });
  }

  Future<void> _applyGourmetFoodPresets() async {
    await ref.read(customerViewProvider.notifier).applyGourmetFoodPresets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Applied High-Res Gourmet Food Photography across all kiosk items!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _saveAllSettings() {
    final parsedMinutes =
        int.tryParse(_prepTimeCtrl.text.trim()) ?? _draftSettings.defaultPreparationMinutes;

    final updated = _draftSettings.copyWith(
      businessName: _businessNameCtrl.text.trim(),
      welcomeHeadline: _headlineCtrl.text.trim(),
      welcomeSubtitle: _subtitleCtrl.text.trim(),
      promoBannerTitle: _promoTitleCtrl.text.trim(),
      promoBannerSubtitle: _promoSubtitleCtrl.text.trim(),
      attractHeadline: _attractHeadlineCtrl.text.trim(),
      defaultPreparationMinutes: parsedMinutes,
    );

    ref.read(customerViewProvider.notifier).updateSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCheck, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Customer View & Kiosk Settings saved successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewProvider);
    final primaryColor = Color(_draftSettings.primaryColorValue);
    final accentColor = Color(_draftSettings.accentColorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Kiosk & Self-Ordering Settings',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              'Modern visual themes, promotions, attract screens, dietary tags and high-res photography',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _saveAllSettings,
              icon: const Icon(LucideIcons.save, size: 15),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(LucideIcons.palette, size: 16), text: 'Themes & Colors'),
            Tab(icon: Icon(LucideIcons.sparkles, size: 16), text: 'Promotions & Attract'),
            Tab(icon: Icon(LucideIcons.utensilsCrossed, size: 16), text: 'Menu & Ordering'),
            Tab(icon: Icon(LucideIcons.image, size: 16), text: 'Food Photography'),
            Tab(icon: Icon(LucideIcons.eye, size: 16), text: 'Catalog Visibility'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── TAB 1: THEMES & COLORS ───
          _buildThemesTab(primaryColor, accentColor),

          // ─── TAB 2: PROMOTIONS & ATTRACT SCREEN ───
          _buildPromotionsTab(primaryColor, accentColor),

          // ─── TAB 3: MENU & ORDERING ───
          _buildOrderingTab(primaryColor),

          // ─── TAB 4: FOOD PHOTOGRAPHY ───
          _buildImagesTab(state.products, primaryColor),

          // ─── TAB 5: CATALOG VISIBILITY ───
          _buildCatalogVisibilityTab(state),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: THEMES & COLORS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildThemesTab(Color primaryColor, Color accentColor) {
    final themePresets = [
      {
        'key': 'emerald_gourmet',
        'title': 'Emerald Gourmet',
        'subtitle': 'Fresh Emerald Green & Warm Gold — Perfect for organic cafes & gourmet bistros',
        'primary': 0xFF059669,
        'accent': 0xFFF59E0B,
        'dark': false,
      },
      {
        'key': 'tokyo_amber',
        'title': 'Tokyo Amber & Flame',
        'subtitle': 'Vibrant Flame Orange & Sun Gold — High appetite fast-casual, burgers & ramen',
        'primary': 0xFFEA580C,
        'accent': 0xFFFBBF24,
        'dark': false,
      },
      {
        'key': 'cyber_indigo',
        'title': 'Cyber Electric Indigo',
        'subtitle': 'Electric Indigo & Neon Teal — Modern tech lounge, cocktail bar & kiosk',
        'primary': 0xFF4F46E5,
        'accent': 0xFF06B6D4,
        'dark': false,
      },
      {
        'key': 'ruby_velvet',
        'title': 'Ruby Rose & Velvet',
        'subtitle': 'Crimson Velvet & Coral Rose — Artisan French bakery, steakhouses & Italian pizza',
        'primary': 0xFFBE123C,
        'accent': 0xFFFB7185,
        'dark': false,
      },
      {
        'key': 'sunset_gold',
        'title': 'Sunset Regal Gold',
        'subtitle': 'Rich Espresso & Regal Saffron — Specialty roastery, artisanal coffee & sweets',
        'primary': 0xFFD97706,
        'accent': 0xFF92400E,
        'dark': false,
      },
      {
        'key': 'midnight_luxury',
        'title': 'Midnight Obsidian (Dark)',
        'subtitle': 'Matte Dark Obsidian & Platinum Mint — Ultra-sleek nightclub & VIP lounge kiosk',
        'primary': 0xFF10B981,
        'accent': 0xFF34D399,
        'dark': true,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Curated Designer Kiosk Themes'),
              const SizedBox(height: 6),
              Text(
                'Select an appetizing, designer-curated color scheme designed to attract customers and maximize orders.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              // Theme Preset Cards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: themePresets.length,
                itemBuilder: (context, index) {
                  final preset = themePresets[index];
                  final isSelected = _draftSettings.themePreset == preset['key'];
                  final pColor = Color(preset['primary'] as int);
                  final aColor = Color(preset['accent'] as int);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _draftSettings = _draftSettings.copyWith(
                          themePreset: preset['key'] as String,
                          primaryColorValue: preset['primary'] as int,
                          accentColorValue: preset['accent'] as int,
                          isDarkMode: preset['dark'] as bool,
                        );
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? pColor : const Color(0xFFE5E7EB),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? pColor.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Color Swatches Dual Circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [pColor, aColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: pColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        preset['title'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: pColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'ACTIVE',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  preset['subtitle'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Dark Mode Appearance'),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration,
                child: _buildSwitchTile(
                  'Enable Dark Mode UI',
                  'Dark slate background with vibrant glow accents — ideal for dim dining rooms & bars',
                  _draftSettings.isDarkMode,
                  (val) => setState(() => _draftSettings = _draftSettings.copyWith(isDarkMode: val)),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Store Branding on Kiosk'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    TextField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Business Name Displayed on Kiosk',
                        prefixIcon: Icon(LucideIcons.store, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _headlineCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Welcome Headline',
                        prefixIcon: Icon(LucideIcons.messageSquare, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _subtitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Welcome Subtitle',
                        prefixIcon: Icon(LucideIcons.alignLeft, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: PROMOTIONS & ATTRACT SCREEN
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPromotionsTab(Color primaryColor, Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Customer-Attracting Promotional Offer Banner'),
              const SizedBox(height: 6),
              Text(
                'Showcase today\'s special discounts, limited combo offers, or festive deals right above the menu.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: _cardDecoration,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Show Promotional Offer Banner',
                      'Display top marquee banner on self-ordering screen',
                      _draftSettings.showPromoBanner,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showPromoBanner: val)),
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: _promoTitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Offer Headline',
                        hintText: 'e.g. 🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
                        prefixIcon: Icon(LucideIcons.flame, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _promoSubtitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Offer Subtitle / Terms',
                        hintText: 'e.g. Freshly crafted to order. Tap any meal to customize with favorite dips.',
                        prefixIcon: Icon(LucideIcons.info, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Attract Screen & Inactivity Screensaver'),
              const SizedBox(height: 6),
              Text(
                'When the kiosk is idle, display an enticing full-screen invitation that invites passing customers to order.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: _cardDecoration,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Enable Attract Mode (Idle Screensaver)',
                      'Shows full-screen animated touch-to-order invitation when idle',
                      _draftSettings.enableAttractScreen,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableAttractScreen: val)),
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: _attractHeadlineCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Touch Prompt Headline',
                        hintText: 'e.g. Touch Anywhere on Screen to Start Ordering',
                        prefixIcon: Icon(LucideIcons.hand, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 10),
                        Text(
                          'Inactivity Timeout to Attract Screen:',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _draftSettings.idleTimeoutSeconds,
                          items: const [
                            DropdownMenuItem(value: 30, child: Text('30 Seconds')),
                            DropdownMenuItem(value: 60, child: Text('60 Seconds (1 Min)')),
                            DropdownMenuItem(value: 90, child: Text('90 Seconds')),
                            DropdownMenuItem(value: 120, child: Text('120 Seconds (2 Min)')),
                            DropdownMenuItem(value: 180, child: Text('180 Seconds (3 Min)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _draftSettings = _draftSettings.copyWith(idleTimeoutSeconds: val));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: MENU & ORDERING FEATURES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOrderingTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Dietary Filters & Smart Upsell'),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Enable Dietary Badges & Filter Bar',
                      'Display Pure Veg (Green Dot) and Non-Veg (Red Mark) tags + quick filter bar',
                      _draftSettings.enableDietaryFilters,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableDietaryFilters: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Enable Upsell Recommendations',
                      'Suggest fries, drinks & dips when adding main gourmet items',
                      _draftSettings.enableUpsellRecommendations,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableUpsellRecommendations: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Allow Dine In / Takeaway Toggle',
                      'Let customers choose whether dining inside or packing takeaway',
                      _draftSettings.allowOrderTypeSelection,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(allowOrderTypeSelection: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Show Live Kitchen Countdown Timer',
                      'Display estimated preparation clock on order confirmation',
                      _draftSettings.showPreparationTimer,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showPreparationTimer: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Fulfillment & Token Mode'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.receipt, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 10),
                        Text(
                          'Order Slip / Token Generation Mode:',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _draftSettings.kitchenSlipMode,
                          items: const [
                            DropdownMenuItem(value: 'Digital Token Only', child: Text('Digital Token (K-1024)')),
                            DropdownMenuItem(value: 'Token + Kitchen Chits', child: Text('Token + Kitchen Ticket')),
                            DropdownMenuItem(value: 'Full Detailed Bill', child: Text('Full Detailed Invoice')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _draftSettings = _draftSettings.copyWith(kitchenSlipMode: val));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _prepTimeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Estimated Preparation Time (Minutes)',
                        prefixIcon: Icon(LucideIcons.timer, size: 16),
                        hintText: 'e.g. 12',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: FOOD PHOTOGRAPHY & PRESETS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildImagesTab(List<CustomerProduct> products, Color primaryColor) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products available to customize.',
          style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        ),
      );
    }

    final currentProduct = products.firstWhere(
      (p) => p.id == (_selectedProductId ?? _selectedProductForImage?.id),
      orElse: () => products.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instant Gourmet Visual Presets Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One-Tap Professional Food Photography Presets',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instantly load mouth-watering high-resolution food photography across burgers, pizzas, pastas, desserts, shakes and coffees.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      onPressed: _applyGourmetFoodPresets,
                      icon: const Icon(LucideIcons.sparkles, size: 14),
                      label: const Text('Apply Presets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF059669),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Upload Custom Product Images from Mac'),
              const SizedBox(height: 6),
              Text(
                'Choose any PNG, JPG, or WebP photo stored on your Mac disk for individual items.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Select Product to Customize',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: products.any((p) => p.id == currentProduct.id)
                              ? currentProduct.id
                              : (products.isNotEmpty ? products.first.id : null),
                          items: products.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text('${p.name} (₹${p.price.toStringAsFixed(0)}) - ${p.category}'),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              setState(() {
                                _selectedProductId = id;
                                _selectedProductForImage =
                                    products.firstWhere((p) => p.id == id);
                                _pickedImagePath = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      '2. Image Preview',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _pickedImagePath != null
                          ? Stack(
                              children: [
                                Image.file(
                                  File(_pickedImagePath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'NEW IMAGE SELECTED',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : (currentProduct.customImagePath != null &&
                                  File(currentProduct.customImagePath!).existsSync())
                              ? Stack(
                                  children: [
                                    Image.file(
                                      File(currentProduct.customImagePath!),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2563EB),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'ACTIVE CUSTOM MAC IMAGE',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : (currentProduct.networkImageUrl != null &&
                                      currentProduct.networkImageUrl!.isNotEmpty)
                                  ? Stack(
                                      children: [
                                        Image.network(
                                          currentProduct.networkImageUrl!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF059669),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'HIGH-RES STUDIO PHOTOGRAPHY',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(LucideIcons.image, size: 36, color: Color(0xFF9CA3AF)),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Using Default Category Placeholder',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImageForSelectedProduct,
                          icon: const Icon(LucideIcons.upload, size: 15),
                          label: const Text('Choose from Mac (PNG / JPG / WebP)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_pickedImagePath != null)
                          ElevatedButton.icon(
                            onPressed: _saveProductImage,
                            icon: const Icon(LucideIcons.check, size: 15),
                            label: const Text('Apply & Save Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        const Spacer(),
                        if (currentProduct.customImagePath != null)
                          OutlinedButton.icon(
                            onPressed: _removeProductImage,
                            icon: const Icon(LucideIcons.rotateCcw, size: 14, color: Color(0xFFDC2626)),
                            label: Text(
                              'Restore Default',
                              style: GoogleFonts.inter(color: const Color(0xFFDC2626)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: CATALOG VISIBILITY & POPULAR BADGES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCatalogVisibilityTab(CustomerViewState state) {
    final query = _visibilitySearchQuery.trim().toLowerCase();
    final filtered = state.products.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Product Visibility & Best Sellers'),
              const SizedBox(height: 6),
              Text(
                'Choose which items appear on customer self-ordering screens and toggle the popular flame badge.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, size: 15, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _visibilitySearchCtrl,
                        onChanged: (val) => setState(() => _visibilitySearchQuery = val),
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search items to toggle visibility...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                decoration: _cardDecoration,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final isHidden = state.hiddenProductIds.contains(product.id);
                    final isFeatured = state.featuredProductIds.contains(product.id);

                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        title: Text(
                          product.name,
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${product.category} • ₹${product.price.toStringAsFixed(0)} • Stock: ${product.stock} • ${product.dietaryTag ?? "All"}',
                          style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF6B7280)),
                        ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              LucideIcons.flame,
                              color: isFeatured ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                              size: 18,
                            ),
                            tooltip: isFeatured ? 'Remove Popular Badge' : 'Mark as Popular',
                            onPressed: () {
                              ref
                                  .read(customerViewProvider.notifier)
                                  .toggleProductFeatured(product.id, !isFeatured);
                            },
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: !isHidden,
                            activeColor: const Color(0xFF16A34A),
                            onChanged: (visible) {
                              ref
                                  .read(customerViewProvider.notifier)
                                  .toggleProductVisibility(product.id, visible);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF16A34A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
