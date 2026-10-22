import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_product_model.dart';
import '../models/customer_view_settings_model.dart';
import '../providers/customer_view_provider.dart';
import '../utils/customer_theme_helper.dart';

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
  late TextEditingController _attractSubtitleCtrl;
  late TextEditingController _primaryHexCtrl;
  late TextEditingController _accentHexCtrl;
  final TextEditingController _visibilitySearchCtrl = TextEditingController();

  late CustomerViewSettings _draftSettings;
  CustomerProduct? _selectedProductForImage;
  String? _selectedProductId;
  String? _pickedImagePath;
  String _visibilitySearchQuery = '';
  bool _showSidePreview = true;

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
    _attractSubtitleCtrl = TextEditingController(text: settings.attractSubtitle);

    _primaryHexCtrl = TextEditingController(
      text: '#${settings.primaryColorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    );
    _accentHexCtrl = TextEditingController(
      text: '#${settings.accentColorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    );

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
    _attractSubtitleCtrl.dispose();
    _primaryHexCtrl.dispose();
    _accentHexCtrl.dispose();
    _visibilitySearchCtrl.dispose();
    super.dispose();
  }

  void _onPrimaryHexChanged(String val) {
    var clean = val.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final intVal = int.tryParse('FF$clean', radix: 16);
      if (intVal != null) {
        setState(() {
          _draftSettings = _draftSettings.copyWith(
            primaryColorValue: intVal,
            themePreset: 'custom',
          );
        });
      }
    }
  }

  void _onAccentHexChanged(String val) {
    var clean = val.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final intVal = int.tryParse('FF$clean', radix: 16);
      if (intVal != null) {
        setState(() {
          _draftSettings = _draftSettings.copyWith(
            accentColorValue: intVal,
            themePreset: 'custom',
          );
        });
      }
    }
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
      if (!mounted) return;
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

  void _resetProductImage() {
    final products = ref.read(customerViewProvider).products;
    if (products.isEmpty) return;
    final currentProduct = products.firstWhere(
      (p) => p.id == (_selectedProductId ?? _selectedProductForImage?.id),
      orElse: () => products.first,
    );

    ref.read(customerViewProvider.notifier).resetProductImage(
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
      attractSubtitle: _attractSubtitleCtrl.text.trim(),
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
              'Customize typography, theme colors, card styles, promotions, ordering and catalog visibility',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showSidePreview ? 'Hide Live Screen Preview' : 'Show Live Screen Preview',
            icon: Icon(
              _showSidePreview ? LucideIcons.panelRightClose : LucideIcons.panelRightOpen,
              color: const Color(0xFF374151),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showSidePreview = !_showSidePreview;
              });
              if (MediaQuery.of(context).size.width < 1050 && _showSidePreview) {
                _openLivePreviewModal(context, state);
              }
            },
          ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1050;
          final tabBarView = TabBarView(
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
          );

          if (isWide && _showSidePreview) {
            final sideWidth = constraints.maxWidth >= 1350
                ? 430.0
                : (constraints.maxWidth >= 1180 ? 385.0 : 350.0);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: tabBarView,
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                ),
                SizedBox(
                  width: sideWidth,
                  child: _buildRightSideLiveKioskScreen(state),
                ),
              ],
            );
          }

          return tabBarView;
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: THEMES & COLORS (TYPOGRAPHY, PALETTES & LAYOUT)
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

    final primarySwatches = [
      {'name': 'Emerald Green', 'val': 0xFF059669},
      {'name': 'Royal Blue', 'val': 0xFF2563EB},
      {'name': 'Electric Indigo', 'val': 0xFF4F46E5},
      {'name': 'Flame Orange', 'val': 0xFFEA580C},
      {'name': 'Crimson Rose', 'val': 0xFFBE123C},
      {'name': 'Amber Gold', 'val': 0xFFD97706},
      {'name': 'Teal Mint', 'val': 0xFF0D9488},
      {'name': 'Charcoal Dark', 'val': 0xFF1E293B},
    ];

    final accentSwatches = [
      {'name': 'Sun Gold', 'val': 0xFFF59E0B},
      {'name': 'Neon Cyan', 'val': 0xFF06B6D4},
      {'name': 'Coral Rose', 'val': 0xFFFB7185},
      {'name': 'Mint Lime', 'val': 0xFF10B981},
      {'name': 'Flame Red', 'val': 0xFFEF4444},
      {'name': 'Electric Violet', 'val': 0xFF8B5CF6},
    ];

    final fontFamilies = [
      {'name': 'Inter', 'desc': 'Clean, crisp & neutral default'},
      {'name': 'Poppins', 'desc': 'Appetizing, geometric & modern'},
      {'name': 'Roboto', 'desc': 'Structured & highly legible'},
      {'name': 'Outfit', 'desc': 'Premium trendy branding'},
      {'name': 'Montserrat', 'desc': 'Bold, architectural & stylish'},
      {'name': 'Plus Jakarta Sans', 'desc': 'Contemporary tech aesthetics'},
      {'name': 'Playfair Display', 'desc': 'Luxury gourmet & editorial'},
      {'name': 'DM Sans', 'desc': 'Approachable, warm & clean'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── COMPLETE KIOSK DESIGN TEMPLATES (1-CLICK APPLICATION) ───
              _buildSectionTitle('Designer Kiosk Templates (1-Click Application)'),
              const SizedBox(height: 6),
              Text(
                'Select any signature design template below to instantly configure colors, typography, card style, borders, promo banner, and mode in real time.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              _buildDesignTemplatesSection(primaryColor, accentColor),
              const SizedBox(height: 28),

              // ─── LIVE INTERACTIVE PREVIEW CARD ───
              _buildLivePreviewCard(primaryColor, accentColor),
              const SizedBox(height: 28),

              // ─── CURATED THEME PRESETS ───
              _buildSectionTitle('Curated Designer Kiosk Themes'),
              const SizedBox(height: 6),
              Text(
                'Select an appetizing, designer-curated color scheme designed to attract customers and maximize orders.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

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
                        _primaryHexCtrl.text = '#${(preset['primary'] as int).toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                        _accentHexCtrl.text = '#${(preset['accent'] as int).toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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

              const SizedBox(height: 28),

              // ─── FONT FAMILY & TYPOGRAPHY ───
              _buildSectionTitle('Typography & Kiosk Font Family'),
              const SizedBox(height: 6),
              Text(
                'Customize the global font family rendered across the entire self-ordering kiosk interface.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: fontFamilies.map((f) {
                        final isSel = _draftSettings.fontFamily.toLowerCase() == f['name']!.toLowerCase();
                        return InkWell(
                          onTap: () => setState(() => _draftSettings = _draftSettings.copyWith(fontFamily: f['name'])),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? primaryColor : const Color(0xFFE5E7EB),
                                width: isSel ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      f['name']!,
                                      style: CustomerThemeHelper.font(
                                        _draftSettings.copyWith(fontFamily: f['name']),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? primaryColor : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (isSel) ...[
                                      const SizedBox(width: 6),
                                      Icon(LucideIcons.check, size: 14, color: primaryColor),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f['desc']!,
                                  style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 28),

                    // Sizing Scale & Weight
                    Builder(builder: (context) {
                      final fontScales = <double, String>{
                        0.85: 'Extra Compact (85%)',
                        0.9: 'Compact (90%)',
                        1.0: 'Standard (100%)',
                        1.1: 'Comfortable (110%)',
                        1.2: 'Large Kiosk (120%)',
                      };
                      if (!fontScales.containsKey(_draftSettings.fontSizeScale)) {
                        fontScales[_draftSettings.fontSizeScale] =
                            '${(_draftSettings.fontSizeScale * 100).toInt()}% (Custom)';
                      }
                      final fontWeights = <String, String>{
                        'Light': 'Light & Minimal',
                        'Standard': 'Standard Balanced',
                        'Bold': 'Bold & Punchy',
                      };
                      if (!fontWeights.containsKey(_draftSettings.fontWeightPreset)) {
                        fontWeights[_draftSettings.fontWeightPreset] = _draftSettings.fontWeightPreset;
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Text Sizing Scale',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<double>(
                                  value: _draftSettings.fontSizeScale,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.type, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: fontScales.entries.map((e) {
                                    return DropdownMenuItem<double>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(fontSizeScale: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Font Weight Profile',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _draftSettings.fontWeightPreset,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.bold, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: fontWeights.entries.map((e) {
                                    return DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(fontWeightPreset: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── FULL CUSTOM COLOR CUSTOMIZER ───
              _buildSectionTitle('Custom Colors & Brand Palettes'),
              const SizedBox(height: 6),
              Text(
                'Customize primary buttons, selection rings, banner badges and glowing accents.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Color Section
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Primary Brand Color (Buttons & Active States)',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: primarySwatches.map((s) {
                        final val = s['val'] as int;
                        final isSel = _draftSettings.primaryColorValue == val;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _draftSettings = _draftSettings.copyWith(
                                primaryColorValue: val,
                                themePreset: 'custom',
                              );
                              _primaryHexCtrl.text = '#${val.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(val),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? Colors.black : Colors.transparent,
                                width: isSel ? 2.5 : 1.0,
                              ),
                            ),
                            child: isSel ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _primaryHexCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Primary HEX',
                              hintText: '#059669',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: _onPrimaryHexChanged,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28),

                    // Accent Color Section
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Accent / Highlight Color (Badges, Offers & Special Tags)',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: accentSwatches.map((s) {
                        final val = s['val'] as int;
                        final isSel = _draftSettings.accentColorValue == val;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _draftSettings = _draftSettings.copyWith(
                                accentColorValue: val,
                                themePreset: 'custom',
                              );
                              _accentHexCtrl.text = '#${val.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(val),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? Colors.black : Colors.transparent,
                                width: isSel ? 2.5 : 1.0,
                              ),
                            ),
                            child: isSel ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _accentHexCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Accent HEX',
                              hintText: '#F59E0B',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: _onAccentHexChanged,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── CARD STYLES & ROUNDING ───
              _buildSectionTitle('Card Geometry & Layout Style'),
              const SizedBox(height: 6),
              Text(
                'Configure card corner rounding, elevation and surface presentation.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Builder(builder: (context) {
                  final borderRadiusOptions = <double, String>{
                    6.0: 'Extra Subtle (6px)',
                    8.0: 'Subtle (8px)',
                    12.0: 'Smooth (12px)',
                    14.0: 'Modern Compact (14px)',
                    16.0: 'Standard Modern (16px)',
                    18.0: 'Curved Gourmet (18px)',
                    22.0: 'Soft Round (22px)',
                    26.0: 'Playful Pill (26px)',
                  };
                  if (!borderRadiusOptions.containsKey(_draftSettings.borderRadius)) {
                    borderRadiusOptions[_draftSettings.borderRadius] =
                        'Custom (${_draftSettings.borderRadius.toInt()}px)';
                  }

                  final cardStyleOptions = <String, String>{
                    'modern': 'Modern Elevated Shadow',
                    'bordered': 'Crisp Bordered',
                    'compact': 'Compact Grid',
                    'minimal': 'Minimal Clean',
                  };
                  if (!cardStyleOptions.containsKey(_draftSettings.productCardStyle)) {
                    cardStyleOptions[_draftSettings.productCardStyle] = _draftSettings.productCardStyle;
                  }

                  final headerStyleOptions = <String, String>{
                    'clean': 'Clean Solid',
                    'gradient': 'Subtle Brand Gradient',
                    'brand': 'Contrasting Brand Color',
                  };
                  if (!headerStyleOptions.containsKey(_draftSettings.headerStyle)) {
                    headerStyleOptions[_draftSettings.headerStyle] = _draftSettings.headerStyle;
                  }

                  final surfaceTintOptions = <String, String>{
                    'default': 'Default Clean Slate',
                    'cream': 'Warm Ivory Cream',
                    'frost': 'Cool Modern Frost',
                    'slate': 'Deep Modern Slate',
                  };
                  if (!surfaceTintOptions.containsKey(_draftSettings.surfaceTint)) {
                    surfaceTintOptions[_draftSettings.surfaceTint] = _draftSettings.surfaceTint;
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Corner Rounding (Border Radius)',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<double>(
                                  value: _draftSettings.borderRadius,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.square, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: borderRadiusOptions.entries.map((e) {
                                    return DropdownMenuItem<double>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(borderRadius: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Card Style',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _draftSettings.productCardStyle,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.layoutGrid, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: cardStyleOptions.entries.map((e) {
                                    return DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(productCardStyle: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Header Bar Style',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _draftSettings.headerStyle,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.panelTop, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: headerStyleOptions.entries.map((e) {
                                    return DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(headerStyle: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Surface Tint / Ambiance',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _draftSettings.surfaceTint,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.sun, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: surfaceTintOptions.entries.map((e) {
                                    return DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(surfaceTint: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 28),

              // ─── DARK MODE APPEARANCE ───
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

              const SizedBox(height: 28),

              // ─── STORE BRANDING ───
              _buildSectionTitle('Store Branding on Kiosk'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    TextField(
                      controller: _businessNameCtrl,
                      onChanged: (val) => setState(() => _draftSettings = _draftSettings.copyWith(businessName: val)),
                      decoration: const InputDecoration(
                        labelText: 'Business Name Displayed on Kiosk',
                        prefixIcon: Icon(LucideIcons.store, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _headlineCtrl,
                      onChanged: (val) => setState(() => _draftSettings = _draftSettings.copyWith(welcomeHeadline: val)),
                      decoration: const InputDecoration(
                        labelText: 'Welcome Headline',
                        prefixIcon: Icon(LucideIcons.messageSquare, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _subtitleCtrl,
                      onChanged: (val) => setState(() => _draftSettings = _draftSettings.copyWith(welcomeSubtitle: val)),
                      decoration: const InputDecoration(
                        labelText: 'Welcome Subtitle',
                        prefixIcon: Icon(LucideIcons.alignLeft, size: 16),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      'Show Store Logo in Header',
                      'Display branded icon badge in kiosk header',
                      _draftSettings.showBusinessLogo,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showBusinessLogo: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Show Business Name in Header',
                      'Display title in top bar',
                      _draftSettings.showBusinessName,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showBusinessName: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Show Welcome Subtitle Tagline',
                      'Display subtitle underneath title in kiosk header',
                      _draftSettings.showWelcomeMessage,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showWelcomeMessage: val)),
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

  // ─── LIVE PREVIEW CARD ───
  Widget _buildLivePreviewCard(Color primaryColor, Color accentColor) {
    final radius = Radius.circular(_draftSettings.borderRadius);
    final isDark = _draftSettings.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE PREVIEW',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Font: ${_draftSettings.fontFamily} | Radius: ${_draftSettings.borderRadius.toInt()}px | Mode: ${isDark ? "Dark" : "Light"}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini Product Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.all(radius),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // Sample image box
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.7),
                  ),
                  child: Icon(LucideIcons.utensils, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '★ CHEF SPECIAL',
                              style: CustomerThemeHelper.font(
                                _draftSettings,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '580 kcal',
                            style: CustomerThemeHelper.font(
                              _draftSettings,
                              fontSize: 10,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Artisan Truffle & Double Cheese Burger',
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Handcrafted sourdough brioche with smoked cheddar and truffle aioli',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CustomerThemeHelper.formatPrice(_draftSettings, 289.0),
                      style: CustomerThemeHelper.font(
                        _draftSettings,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.plus, size: 13),
                      label: Text(
                        'Add',
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(radius),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TEMPLATE APPLICATION HANDLER ───
  void _applyDesignTemplate(Map<String, dynamic> template) {
    setState(() {
      _draftSettings = _draftSettings.copyWith(
        themePreset: template['themePreset'] as String,
        primaryColorValue: template['primaryColorValue'] as int,
        accentColorValue: template['accentColorValue'] as int,
        fontFamily: template['fontFamily'] as String,
        fontSizeScale: (template['fontSizeScale'] as num).toDouble(),
        fontWeightPreset: template['fontWeightPreset'] as String,
        borderRadius: (template['borderRadius'] as num).toDouble(),
        productCardStyle: template['productCardStyle'] as String,
        headerStyle: template['headerStyle'] as String,
        surfaceTint: template['surfaceTint'] as String,
        isDarkMode: template['isDarkMode'] as bool,
        showPromoBanner: true,
        promoBannerTitle: template['promoBannerTitle'] as String,
        promoBannerSubtitle: template['promoBannerSubtitle'] as String,
        promoBannerStyle: template['promoBannerStyle'] as String,
      );

      _primaryHexCtrl.text =
          '#${(template['primaryColorValue'] as int).toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      _accentHexCtrl.text =
          '#${(template['accentColorValue'] as int).toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      _promoTitleCtrl.text = template['promoBannerTitle'] as String;
      _promoSubtitleCtrl.text = template['promoBannerSubtitle'] as String;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Applied "${template['name']}" Template! Real-time preview updated on the right screen.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: Color(template['primaryColorValue'] as int),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── DESIGN TEMPLATES GALLERY GRID ───
  Widget _buildDesignTemplatesSection(Color primaryColor, Color accentColor) {
    final templates = [
      {
        'id': 'artisan_gourmet',
        'name': 'Artisan Gourmet Bistro',
        'category': 'ORGANIC CAFE & BISTRO',
        'tagline': 'Farm-to-table organic freshness with warm artisan gold accents',
        'badgeColor': 0xFF059669,
        'icon': LucideIcons.leaf,
        'themePreset': 'emerald_gourmet',
        'primaryColorValue': 0xFF059669,
        'accentColorValue': 0xFFF59E0B,
        'fontFamily': 'Inter',
        'fontSizeScale': 1.0,
        'fontWeightPreset': 'Standard',
        'borderRadius': 16.0,
        'productCardStyle': 'modern',
        'headerStyle': 'gradient',
        'surfaceTint': 'default',
        'isDarkMode': false,
        'promoBannerTitle': '🌿 FRESH FARM-TO-TABLE: GET 25% OFF ORGANIC SALAD BOWLS TODAY!',
        'promoBannerSubtitle': 'Made with locally sourced heirloom greens and house cold-pressed vinaigrettes.',
        'promoBannerStyle': 'emerald',
      },
      {
        'id': 'tokyo_neon',
        'name': 'Tokyo Neon & Midnight Ramen',
        'category': 'RAMEN, BURGERS & NIGHTLIFE',
        'tagline': 'High appetite flame orange and sun gold on deep obsidian dark mode',
        'badgeColor': 0xFFEA580C,
        'icon': LucideIcons.flame,
        'themePreset': 'tokyo_amber',
        'primaryColorValue': 0xFFEA580C,
        'accentColorValue': 0xFFFBBF24,
        'fontFamily': 'Outfit',
        'fontSizeScale': 1.05,
        'fontWeightPreset': 'Bold',
        'borderRadius': 20.0,
        'productCardStyle': 'modern',
        'headerStyle': 'brand',
        'surfaceTint': 'slate',
        'isDarkMode': true,
        'promoBannerTitle': '🍜 LATE NIGHT RAMEN SPECIAL: FREE EXTRA CHASHU & GYOZA COMBO!',
        'promoBannerSubtitle': '24-hour slow simmered tonkotsu broth with artisan handcrafted spring noodles.',
        'promoBannerStyle': 'fire',
      },
      {
        'id': 'ruby_velvet',
        'name': 'Ruby Velvet Patisserie & Bakery',
        'category': 'FRENCH PATISSERIE & PIZZA',
        'tagline': 'Editorial luxury with Crimson Velvet Rose and editorial Playfair serif',
        'badgeColor': 0xFFBE123C,
        'icon': LucideIcons.cake,
        'themePreset': 'ruby_velvet',
        'primaryColorValue': 0xFFBE123C,
        'accentColorValue': 0xFFFB7185,
        'fontFamily': 'Playfair Display',
        'fontSizeScale': 1.0,
        'fontWeightPreset': 'Standard',
        'borderRadius': 14.0,
        'productCardStyle': 'bordered',
        'headerStyle': 'clean',
        'surfaceTint': 'cream',
        'isDarkMode': false,
        'promoBannerTitle': '🥐 MORNING PATISSERIE: COMPLIMENTARY CAFE LATTE WITH CROISSANTS!',
        'promoBannerSubtitle': 'Laminated with French Normandy butter and baked fresh every 45 minutes.',
        'promoBannerStyle': 'fire',
      },
      {
        'id': 'cyber_electric',
        'name': 'Cyber Electric Indigo Lounge',
        'category': 'TECH CAFE & COCKTAIL BAR',
        'tagline': 'Futuristic electric indigo, neon cyan, and contemporary pill curves',
        'badgeColor': 0xFF4F46E5,
        'icon': LucideIcons.zap,
        'themePreset': 'cyber_indigo',
        'primaryColorValue': 0xFF4F46E5,
        'accentColorValue': 0xFF06B6D4,
        'fontFamily': 'Plus Jakarta Sans',
        'fontSizeScale': 1.0,
        'fontWeightPreset': 'Bold',
        'borderRadius': 24.0,
        'productCardStyle': 'bordered',
        'headerStyle': 'gradient',
        'surfaceTint': 'frost',
        'isDarkMode': false,
        'promoBannerTitle': '⚡ HAPPY HOUR FLASH SALE: BUY 1 GET 1 ON ALL CRAFT MOCKTAILS!',
        'promoBannerSubtitle': 'Infused with natural botanicals, chilled cold press and edible glitter garnish.',
        'promoBannerStyle': 'indigo',
      },
      {
        'id': 'sunset_saffron',
        'name': 'Sunset Saffron Royal Grill',
        'category': 'ROYAL TANDOOR & BIRYANI',
        'tagline': 'Warm regal amber saffron and tandoor crimson with approachable DM Sans',
        'badgeColor': 0xFFD97706,
        'icon': LucideIcons.crown,
        'themePreset': 'sunset_gold',
        'primaryColorValue': 0xFFD97706,
        'accentColorValue': 0xFFDC2626,
        'fontFamily': 'DM Sans',
        'fontSizeScale': 1.0,
        'fontWeightPreset': 'Bold',
        'borderRadius': 12.0,
        'productCardStyle': 'modern',
        'headerStyle': 'brand',
        'surfaceTint': 'cream',
        'isDarkMode': false,
        'promoBannerTitle': '👑 SHAHI FEAST: COMPLIMENTARY KESAR PHIRNI ON ORDERS ABOVE ₹500!',
        'promoBannerSubtitle': 'Cooked over fragrant charcoal embers with heritage hand-ground royal spices.',
        'promoBannerStyle': 'gold',
      },
      {
        'id': 'nordic_minimal',
        'name': 'Nordic Minimal Slate Espresso',
        'category': 'SPECIALTY COFFEE ROASTER',
        'tagline': 'Ultra-crisp Scandinavian slate monochrome with sharp architectural cards',
        'badgeColor': 0xFF0F172A,
        'icon': LucideIcons.coffee,
        'themePreset': 'midnight_luxury',
        'primaryColorValue': 0xFF0F172A,
        'accentColorValue': 0xFF3B82F6,
        'fontFamily': 'Montserrat',
        'fontSizeScale': 0.95,
        'fontWeightPreset': 'Light',
        'borderRadius': 8.0,
        'productCardStyle': 'minimal',
        'headerStyle': 'clean',
        'surfaceTint': 'default',
        'isDarkMode': false,
        'promoBannerTitle': '☕ SINGLE ORIGIN TASTING: 20% OFF ETHIOPIAN YIRGACHEFFE POUR-OVERS!',
        'promoBannerSubtitle': 'Light roast notes of jasmine, bergamot peach and lemon blossom.',
        'promoBannerStyle': 'indigo',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 580 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 2 ? 1.7 : 2.2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final t = templates[index];
            final tPrimary = Color(t['primaryColorValue'] as int);
            final tAccent = Color(t['accentColorValue'] as int);
            final isDark = t['isDarkMode'] as bool;
            final isCurrent = _draftSettings.themePreset == t['themePreset'] &&
                _draftSettings.fontFamily == t['fontFamily'];

            return InkWell(
              onTap: () => _applyDesignTemplate(t),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent
                        ? tPrimary
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isCurrent ? 2.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent
                          ? tPrimary.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isCurrent ? 14 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [tPrimary, tAccent]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(t['icon'] as IconData, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  t['category'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: tPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: tPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.check, size: 11, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(
                                  'ACTIVE',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Text(
                      t['tagline'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            'Font: ${t['fontFamily']}',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            '${(t['borderRadius'] as double).toInt()}px radius',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            isDark ? 'Dark Mode' : 'Light Mode',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _applyDesignTemplate(t),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrent
                              ? tPrimary
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          foregroundColor: isCurrent
                              ? Colors.white
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isCurrent ? 'Template Applied' : 'Apply Template',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isCurrent ? LucideIcons.checkCheck : LucideIcons.arrowRight,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PERSISTENT RIGHT-SIDE LIVE KIOSK SCREEN PREVIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRightSideLiveKioskScreen(CustomerViewState state) {
    final primaryColor = Color(_draftSettings.primaryColorValue);
    final accentColor = Color(_draftSettings.accentColorValue);
    final isDark = _draftSettings.isDarkMode;
    final surfaceColor = CustomerThemeHelper.surfaceBackground(_draftSettings);
    final borderRadiusVal = _draftSettings.borderRadius;
    final radius = Radius.circular(borderRadiusVal);

    final sampleProducts = state.visibleProducts.isNotEmpty
        ? state.visibleProducts.take(3).toList()
        : [
            const CustomerProduct(
              id: 'sample-1',
              name: 'Artisan Truffle Burger',
              category: 'Food & Dining',
              description: 'Handcrafted brioche with smoked cheddar & truffle aioli',
              price: 289.0,
              stock: 25,
              isVeg: false,
              isFeatured: true,
              calories: '580 kcal',
            ),
            const CustomerProduct(
              id: 'sample-2',
              name: 'Iced Vanilla Cold Brew',
              category: 'Beverages',
              description: 'Steeped for 18 hours with Madagascar vanilla cream',
              price: 149.0,
              stock: 40,
              isVeg: true,
              calories: '120 kcal',
            ),
            const CustomerProduct(
              id: 'sample-3',
              name: 'Woodfired Margherita Pizza',
              category: 'Food & Dining',
              description: 'San Marzano tomatoes, fresh buffalo mozzarella & basil',
              price: 349.0,
              stock: 15,
              isVeg: true,
              calories: '650 kcal',
            ),
          ];

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Studio Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.monitor, size: 16, color: primaryColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LIVE KIOSK SCREEN',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF16A34A), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SYNCED',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4ADE80),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Font: ${_draftSettings.fontFamily} • ${borderRadiusVal.toInt()}px • ${isDark ? "Dark" : "Light"}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Realistic Tablet Bezel Frame
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF334155), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Column(
                  children: [
                    // Top camera notch
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 6, top: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Inner Live Screen
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: surfaceColor,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Status Bar
                                _buildKioskStatusBar(primaryColor, isDark),

                                // 2. Kiosk Header / Branding
                                _buildKioskHeader(primaryColor, accentColor, isDark),

                                // 3. Promotional Offer Banner
                                if (_draftSettings.showPromoBanner)
                                  _buildKioskPromoBanner(primaryColor, accentColor),

                                // 4. Category Filter Chips
                                _buildKioskCategoryChips(primaryColor, isDark),

                                // 5. Live Product Cards
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Column(
                                    children: [
                                      for (final product in sampleProducts)
                                        _buildKioskProductCard(
                                          product,
                                          primaryColor,
                                          accentColor,
                                          isDark,
                                          radius,
                                        ),
                                    ],
                                  ),
                                ),

                                // 6. Floating Cart Dock
                                _buildKioskCartDock(primaryColor),

                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskStatusBar(Color primaryColor, bool isDark) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '12:45 PM',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Text(
            'KIOSK #01',
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            children: [
              Icon(
                LucideIcons.wifi,
                size: 10,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.batteryMedium,
                size: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKioskHeader(Color primaryColor, Color accentColor, bool isDark) {
    final headerStyle = _draftSettings.headerStyle;
    Color headerBg;
    LinearGradient? headerGradient;
    Color textColor;
    Color iconColor;

    if (headerStyle == 'brand') {
      headerBg = primaryColor;
      textColor = Colors.white;
      iconColor = Colors.white;
    } else if (headerStyle == 'gradient') {
      headerBg = primaryColor;
      headerGradient = LinearGradient(colors: [primaryColor, accentColor]);
      textColor = Colors.white;
      iconColor = Colors.white;
    } else {
      headerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
      textColor = isDark ? Colors.white : const Color(0xFF111827);
      iconColor = primaryColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        gradient: headerGradient,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_draftSettings.showBusinessLogo)
                Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: (headerStyle == 'clean')
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.utensils, color: iconColor, size: 14),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_draftSettings.showBusinessName)
                      Text(
                        _draftSettings.businessName.isNotEmpty
                            ? _draftSettings.businessName
                            : 'Cliks Gourmet Kiosk',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    if (_draftSettings.showWelcomeMessage)
                      Text(
                        _draftSettings.welcomeHeadline.isNotEmpty
                            ? _draftSettings.welcomeHeadline
                            : 'Self-Ordering Kiosk',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 9.5,
                          color: (headerStyle == 'clean')
                              ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: (headerStyle == 'clean')
                  ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9))
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.search,
                  size: 12,
                  color: (headerStyle == 'clean')
                      ? const Color(0xFF94A3B8)
                      : Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Search handcrafted menu...',
                    overflow: TextOverflow.ellipsis,
                    style: CustomerThemeHelper.font(
                      _draftSettings,
                      fontSize: 9.5,
                      color: (headerStyle == 'clean')
                          ? const Color(0xFF94A3B8)
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskPromoBanner(Color primaryColor, Color accentColor) {
    List<Color> gradientColors;
    switch (_draftSettings.promoBannerStyle) {
      case 'gold':
        gradientColors = [const Color(0xFFD97706), const Color(0xFFF59E0B)];
        break;
      case 'indigo':
        gradientColors = [const Color(0xFF4F46E5), const Color(0xFF6366F1)];
        break;
      case 'emerald':
        gradientColors = [const Color(0xFF059669), const Color(0xFF10B981)];
        break;
      case 'fire':
      default:
        gradientColors = [const Color(0xFFEA580C), const Color(0xFFF97316)];
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.6),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _draftSettings.promoBannerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomerThemeHelper.font(
                    _draftSettings,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _draftSettings.promoBannerSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomerThemeHelper.font(
                    _draftSettings,
                    fontSize: 8.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'SPECIAL',
              style: CustomerThemeHelper.font(
                _draftSettings,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: gradientColors.first,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskCategoryChips(Color primaryColor, bool isDark) {
    final chips = ['All Items', '★ Specials', 'Beverages', 'Desserts'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: i == 0
                    ? primaryColor
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.5),
                border: Border.all(
                  color: i == 0
                      ? primaryColor
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Text(
                chips[i],
                style: CustomerThemeHelper.font(
                  _draftSettings,
                  fontSize: 9.5,
                  fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w600,
                  color: i == 0
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKioskProductCard(
    CustomerProduct product,
    Color primaryColor,
    Color accentColor,
    bool isDark,
    Radius radius,
  ) {
    final cardStyle = _draftSettings.productCardStyle;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    Border? cardBorder;
    List<BoxShadow>? cardShadow;

    if (cardStyle == 'bordered') {
      cardBorder = Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5);
    } else if (cardStyle == 'minimal') {
      cardBorder = Border.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        width: 1,
      );
    } else {
      cardShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    }

    final formattedPrice = CustomerThemeHelper.formatPrice(_draftSettings, product.price);
    final imgRadius = _draftSettings.borderRadius * 0.6;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.all(radius),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Row(
        children: [
          _buildKioskProductImage(product, primaryColor, imgRadius),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_draftSettings.enableDietaryFilters)
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: product.isVeg
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: product.isVeg
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              shape: product.isVeg ? BoxShape.circle : BoxShape.rectangle,
                            ),
                          ),
                        ),
                      ),
                    if (product.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'CHEF SPECIAL',
                          style: CustomerThemeHelper.font(
                            _draftSettings,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ),
                    if (_draftSettings.showCalories && product.calories != null)
                      Text(
                        product.calories!.contains('kcal') ? product.calories! : '${product.calories} kcal',
                        style: CustomerThemeHelper.font(
                          _draftSettings,
                          fontSize: 8.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomerThemeHelper.font(
                    _draftSettings,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                if (_draftSettings.showProductDescriptions && product.description.isNotEmpty)
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomerThemeHelper.font(
                      _draftSettings,
                      fontSize: 9,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          formattedPrice,
                          style: CustomerThemeHelper.font(
                            _draftSettings,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        if (_draftSettings.taxDisplayMode == 'breakdown')
                          Text(
                            ' + GST',
                            style: CustomerThemeHelper.font(
                              _draftSettings,
                              fontSize: 8,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          )
                        else if (_draftSettings.taxDisplayMode == 'inclusive')
                          Text(
                            ' Incl. Tax',
                            style: CustomerThemeHelper.font(
                              _draftSettings,
                              fontSize: 8,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.plus, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            'Add',
                            style: CustomerThemeHelper.font(
                              _draftSettings,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskProductImage(CustomerProduct product, Color primaryColor, double radius) {
    if (_selectedProductId == product.id && _pickedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          File(_pickedImagePath!),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackCategoryIcon(product, primaryColor, radius),
        ),
      );
    }

    if (product.customImagePath != null && product.customImagePath!.isNotEmpty) {
      final file = File(product.customImagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            file,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackCategoryIcon(product, primaryColor, radius),
          ),
        );
      }
    }

    return _buildFallbackCategoryIcon(product, primaryColor, radius);
  }

  Widget _buildFallbackCategoryIcon(CustomerProduct product, Color primaryColor, double radius) {
    final isBev = product.category.toLowerCase().contains('bev') ||
        product.category.toLowerCase().contains('coffee');
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          isBev ? LucideIcons.coffee : LucideIcons.utensils,
          color: primaryColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildKioskCartDock(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.7),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.shoppingBag, color: primaryColor, size: 13),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '2 items in tray',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    '${_draftSettings.currencySymbol}438',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(_draftSettings.borderRadius * 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order',
                  style: CustomerThemeHelper.font(
                    _draftSettings,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(LucideIcons.arrowRight, size: 10, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLivePreviewModal(BuildContext context, CustomerViewState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _buildRightSideLiveKioskScreen(state),
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
                      onChanged: (val) => setState(() => _draftSettings = _draftSettings.copyWith(promoBannerTitle: val)),
                      decoration: const InputDecoration(
                        labelText: 'Offer Headline',
                        hintText: 'e.g. 🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
                        prefixIcon: Icon(LucideIcons.flame, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _promoSubtitleCtrl,
                      onChanged: (val) => setState(() => _draftSettings = _draftSettings.copyWith(promoBannerSubtitle: val)),
                      decoration: const InputDecoration(
                        labelText: 'Offer Subtitle / Terms',
                        hintText: 'e.g. Freshly crafted to order. Tap any meal to customize with favorite dips.',
                        prefixIcon: Icon(LucideIcons.info, size: 16),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Builder(builder: (context) {
                      final promoStyles = <String, String>{
                        'fire': 'Flame Orange / Fire',
                        'gold': 'Regal Gold / Saffron',
                        'indigo': 'Electric Indigo',
                        'emerald': 'Fresh Emerald',
                      };
                      if (!promoStyles.containsKey(_draftSettings.promoBannerStyle)) {
                        promoStyles[_draftSettings.promoBannerStyle] = _draftSettings.promoBannerStyle;
                      }

                      return Row(
                        children: [
                          const Icon(LucideIcons.palette, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Banner Theme Visual Style:',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _draftSettings.promoBannerStyle,
                            items: promoStyles.entries.map((e) {
                              return DropdownMenuItem<String>(value: e.key, child: Text(e.value));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _draftSettings = _draftSettings.copyWith(promoBannerStyle: val));
                              }
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 28),
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
                    const SizedBox(height: 14),
                    TextField(
                      controller: _attractSubtitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Attract Screen Tagline',
                        hintText: 'e.g. Explore our handcrafted gourmet menu, customize & checkout in seconds',
                        prefixIcon: Icon(LucideIcons.sparkles, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      final timeouts = <int, String>{
                        15: '15 Seconds (Rapid Demo)',
                        30: '30 Seconds',
                        45: '45 Seconds',
                        60: '60 Seconds (1 Min)',
                        90: '90 Seconds',
                        120: '120 Seconds (2 Min)',
                        180: '180 Seconds (3 Min)',
                        300: '300 Seconds (5 Min)',
                      };
                      if (!timeouts.containsKey(_draftSettings.idleTimeoutSeconds)) {
                        timeouts[_draftSettings.idleTimeoutSeconds] =
                            '${_draftSettings.idleTimeoutSeconds} Seconds';
                      }

                      return Row(
                        children: [
                          const Icon(LucideIcons.clock, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Inactivity Timeout to Attract Screen:',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: _draftSettings.idleTimeoutSeconds,
                            items: timeouts.entries.map((e) {
                              return DropdownMenuItem<int>(value: e.key, child: Text(e.value));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _draftSettings = _draftSettings.copyWith(idleTimeoutSeconds: val));
                              }
                            },
                          ),
                        ],
                      );
                    }),
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
    final currencySymbols = [
      {'sym': '₹', 'label': '₹ INR (Indian Rupee)'},
      {'sym': '\$', 'label': '\$ USD (US Dollar)'},
      {'sym': '€', 'label': '€ EUR (Euro)'},
      {'sym': '£', 'label': '£ GBP (British Pound)'},
      {'sym': 'AED', 'label': 'AED (UAE Dirham)'},
    ];
    if (!currencySymbols.any((c) => c['sym'] == _draftSettings.currencySymbol)) {
      currencySymbols.add({
        'sym': _draftSettings.currencySymbol,
        'label': '${_draftSettings.currencySymbol} (Custom)',
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Self-Ordering & Cart Workflow'),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Enable Customer Self-Ordering',
                      'Allows visitors to browse and place their own orders on the kiosk',
                      _draftSettings.enableSelfOrdering,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableSelfOrdering: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Enable Tray / Shopping Cart Panel',
                      'Display persistent side tray or bottom cart sheet',
                      _draftSettings.enableCart,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableCart: val)),
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
                      'Enable Upsell Recommendations',
                      'Suggest fries, drinks & dips when adding main gourmet items',
                      _draftSettings.enableUpsellRecommendations,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableUpsellRecommendations: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Audio & Sound Feedback Effects',
                      'Play pleasant micro-chimes on item add, tap and checkout confirmation',
                      _draftSettings.enableSoundEffects,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableSoundEffects: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildSectionTitle('Customer Details & Table Assignment'),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Collect Customer Contact Details',
                      'Ask for Customer Name and Phone Number at checkout',
                      _draftSettings.collectCustomerDetails,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(collectCustomerDetails: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Require Customer Phone (Mandatory)',
                      'Block checkout until a valid phone number is entered for SMS updates',
                      _draftSettings.requireCustomerPhone,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(requireCustomerPhone: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Ask for Table Number',
                      'Prompt customer to enter table number for table-side dining service',
                      _draftSettings.showTableNumberInput,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showTableNumberInput: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Require Table Number for Dine-In',
                      'Make table number required when Dine In is chosen',
                      _draftSettings.requireTableNumber,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(requireTableNumber: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildSectionTitle('Currency, Taxes & Item Badges'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Currency Symbol',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _draftSettings.currencySymbol,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(LucideIcons.coins, size: 16),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: currencySymbols.map((c) {
                                  return DropdownMenuItem(value: c['sym'], child: Text(c['label']!, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _draftSettings = _draftSettings.copyWith(currencySymbol: val));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tax / GST Display Mode',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Builder(builder: (context) {
                                final taxModes = <String, String>{
                                  'breakdown': 'Detailed Breakdown (Subtotal + Tax)',
                                  'inclusive': 'Inclusive in Price (All-Inclusive)',
                                  'hidden': 'Hide Tax Details on Kiosk',
                                };
                                if (!taxModes.containsKey(_draftSettings.taxDisplayMode)) {
                                  taxModes[_draftSettings.taxDisplayMode] = _draftSettings.taxDisplayMode;
                                }
                                return DropdownButtonFormField<String>(
                                  value: _draftSettings.taxDisplayMode,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(LucideIcons.receipt, size: 16),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: taxModes.entries.map((e) {
                                    return DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _draftSettings = _draftSettings.copyWith(
                                            taxDisplayMode: val,
                                            showGstBreakdown: val == 'breakdown',
                                          ));
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      'Show Calorie Info (kcal Tag)',
                      'Display calorie count on applicable food items',
                      _draftSettings.showCalories,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showCalories: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Show Estimated Prep Time Tag on Cards',
                      'Display preparation estimate (e.g. 10-15m) on items',
                      _draftSettings.showPrepTimeBadge,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showPrepTimeBadge: val)),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Enable Dietary Badges & Filter Bar',
                      'Display Pure Veg (Green Dot) and Non-Veg (Red Mark) tags + quick filter bar',
                      _draftSettings.enableDietaryFilters,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(enableDietaryFilters: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildSectionTitle('Fulfillment, Timer & Token Mode'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchTile(
                      'Show Live Kitchen Countdown Timer',
                      'Display animated countdown clock on order completion screen',
                      _draftSettings.showPreparationTimer,
                      (val) => setState(() => _draftSettings = _draftSettings.copyWith(showPreparationTimer: val)),
                    ),
                    const Divider(height: 24),
                    Builder(builder: (context) {
                      final slipModes = <String, String>{
                        'Digital Token Only': 'Digital Token (K-1024)',
                        'Token + Kitchen Chits': 'Token + Kitchen Ticket',
                        'Full Detailed Bill': 'Full Detailed Invoice',
                      };
                      if (!slipModes.containsKey(_draftSettings.kitchenSlipMode)) {
                        slipModes[_draftSettings.kitchenSlipMode] = _draftSettings.kitchenSlipMode;
                      }

                      return Row(
                        children: [
                          const Icon(LucideIcons.receipt, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Order Slip / Token Generation Mode:',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _draftSettings.kitchenSlipMode,
                            items: slipModes.entries.map((e) {
                              return DropdownMenuItem<String>(value: e.key, child: Text(e.value));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _draftSettings = _draftSettings.copyWith(kitchenSlipMode: val));
                              }
                            },
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _prepTimeCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final mins = int.tryParse(val.trim());
                        if (mins != null) {
                          setState(() => _draftSettings = _draftSettings.copyWith(defaultPreparationMinutes: mins));
                        }
                      },
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
    final seenIds = <String>{};
    final uniqueProducts = products.where((p) => seenIds.add(p.id)).toList();
    if (uniqueProducts.isEmpty) {
      return Center(
        child: Text(
          'No products found in the catalog.',
          style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        ),
      );
    }

    final currentProduct = uniqueProducts.firstWhere(
      (p) => p.id == (_selectedProductId ?? uniqueProducts.first.id),
      orElse: () => uniqueProducts.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner: One-Click Gourmet Presets
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.sparkles, size: 26, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One-Click High-Res Gourmet Food Photography',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Instantly assign studio-quality food photography across your burgers, beverages, artisan pizzas and desserts.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _applyGourmetFoodPresets,
                      icon: const Icon(LucideIcons.camera, size: 15),
                      label: const Text('Apply HD Presets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF047857),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildSectionTitle('Customize Product Card Photography'),
              const SizedBox(height: 6),
              Text(
                'Select any item to upload a custom high-resolution photo from your device or revert to catalog default.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Picker Dropdown
                    Text(
                      'Select Product to Customize:',
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
                          value: currentProduct.id,
                          isExpanded: true,
                          items: uniqueProducts.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Row(
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${p.category} — ${CustomerThemeHelper.formatPrice(_draftSettings, p.price)})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  if (p.customImagePath != null && p.customImagePath!.isNotEmpty) ...[
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'CUSTOM IMAGE',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              setState(() {
                                _selectedProductId = newId;
                                _selectedProductForImage =
                                    uniqueProducts.firstWhere((p) => p.id == newId, orElse: () => currentProduct);
                                _pickedImagePath = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Image Preview Area
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Box
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: _buildImagePreviewWidget(currentProduct),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Actions & Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentProduct.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentProduct.description.isNotEmpty
                                    ? currentProduct.description
                                    : 'No description provided.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 18),

                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImageForSelectedProduct,
                                    icon: const Icon(LucideIcons.uploadCloud, size: 15),
                                    label: const Text('Choose File'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (_pickedImagePath != null)
                                    ElevatedButton.icon(
                                      onPressed: _saveProductImage,
                                      icon: const Icon(LucideIcons.check, size: 15),
                                      label: const Text('Save This Image'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        textStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  OutlinedButton.icon(
                                    onPressed: _resetProductImage,
                                    icon: const Icon(LucideIcons.rotateCcw, size: 14, color: Color(0xFF6B7280)),
                                    label: const Text('Reset to Default'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF374151),
                                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildImagePreviewWidget(CustomerProduct product) {
    if (_pickedImagePath != null && File(_pickedImagePath!).existsSync()) {
      return Image.file(
        File(_pickedImagePath!),
        fit: BoxFit.cover,
      );
    }
    if (product.customImagePath != null &&
        product.customImagePath!.isNotEmpty &&
        File(product.customImagePath!).existsSync()) {
      return Image.file(
        File(product.customImagePath!),
        fit: BoxFit.cover,
      );
    }
    if (product.networkImageUrl != null && product.networkImageUrl!.isNotEmpty) {
      return Image.network(
        product.networkImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image, size: 36, color: Color(0xFF9CA3AF)),
          SizedBox(height: 6),
          Text(
            'No Image',
            style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: CATALOG VISIBILITY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCatalogVisibilityTab(CustomerViewState state) {
    final products = state.products;
    final hiddenIds = state.hiddenProductIds;
    final featuredIds = state.featuredProductIds;

    final filtered = products.where((p) {
      final q = _visibilitySearchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    final activeCount = products.length - hiddenIds.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Catalog Item Visibility & Highlighting'),
              const SizedBox(height: 6),
              Text(
                'Control which items appear on the customer kiosk. Hide out-of-stock items or star Chef Specials to pin them to the top.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              // Summary Stats Bar
              Row(
                children: [
                  _buildStatBadge(
                    'Active On Kiosk',
                    activeCount.toString(),
                    const Color(0xFF16A34A),
                    const Color(0xFFF0FDF4),
                    LucideIcons.eye,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    'Hidden Items',
                    hiddenIds.length.toString(),
                    const Color(0xFFDC2626),
                    const Color(0xFFFEF2F2),
                    LucideIcons.eyeOff,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    'Featured Specials',
                    featuredIds.length.toString(),
                    const Color(0xFFD97706),
                    const Color(0xFFFFFBEB),
                    LucideIcons.star,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search & Filter
              TextField(
                controller: _visibilitySearchCtrl,
                onChanged: (val) => setState(() => _visibilitySearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search catalog by name or category...',
                  prefixIcon: const Icon(LucideIcons.search, size: 16),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              const SizedBox(height: 16),

              // Product Items List
              Container(
                decoration: _cardDecoration,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final product = filtered[i];
                    final isHidden = hiddenIds.contains(product.id);
                    final isFeatured = featuredIds.contains(product.id) || product.isFeatured;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Status icon
                          Icon(
                            isHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: isHidden ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 14),

                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isHidden ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                                      ),
                                    ),
                                    if (isFeatured) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '★ BEST SELLER',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.category} • ${CustomerThemeHelper.formatPrice(_draftSettings, product.price)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action: Star as Featured
                          IconButton(
                            icon: Icon(
                              isFeatured ? LucideIcons.star : LucideIcons.star,
                              size: 17,
                              color: isFeatured ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                            ),
                            tooltip: isFeatured ? 'Remove from Specials' : 'Mark as Best Seller Special',
                            onPressed: () {
                              ref.read(customerViewProvider.notifier).toggleFeaturedProduct(product.id);
                            },
                          ),

                          // Action: Toggle Visibility
                          IconButton(
                            icon: Icon(
                              isHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 17,
                              color: isHidden ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                            ),
                            tooltip: isHidden ? 'Make Visible on Kiosk' : 'Hide from Kiosk',
                            onPressed: () {
                              ref.read(customerViewProvider.notifier).toggleProductVisibility(product.id, isHidden);
                            },
                          ),
                        ],
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

  Widget _buildStatBadge(String label, String value, Color color, Color bg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
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
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARED STYLING HELPERS
  // ═══════════════════════════════════════════════════════════════
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Color(_draftSettings.primaryColorValue),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
