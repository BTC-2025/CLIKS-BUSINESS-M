import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/customer_view_provider.dart';
import '../models/customer_product_model.dart';
import '../models/customer_view_settings_model.dart';
import '../widgets/customer_product_card.dart';
import '../widgets/customer_category_navigation.dart';
import '../widgets/customer_cart_panel.dart';
import '../widgets/customer_product_detail_modal.dart';
import '../widgets/customer_owner_auth_dialog.dart';
import 'customer_checkout_page.dart';
import 'customer_view_settings_page.dart';

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showAttractScreen = false;
  bool _promoBannerDismissed = false;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(customerViewProvider).settings;
      if (settings.enableAttractScreen) {
        setState(() {
          _showAttractScreen = true;
        });
      }
      _resetIdleTimer();
    });
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    final settings = ref.read(customerViewProvider).settings;
    if (!settings.enableAttractScreen) return;

    final timeout = settings.idleTimeoutSeconds > 0 ? settings.idleTimeoutSeconds : 90;
    _idleTimer = Timer(Duration(seconds: timeout), () {
      final cart = ref.read(customerViewProvider).cart;
      if (cart.isEmpty && mounted && !_showAttractScreen) {
        setState(() {
          _showAttractScreen = true;
        });
      }
    });
  }

  void _dismissAttractScreen() {
    if (_showAttractScreen) {
      setState(() {
        _showAttractScreen = false;
      });
      _resetIdleTimer();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showOwnerAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomerOwnerAuthDialog(
        onExitToOwnerPos: () {
          Navigator.of(context).pop(); // Exit Customer Mode back to POS
        },
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const CustomerViewSettingsPage(),
            ),
          );
        },
      ),
    );
  }

  void _openProductDetail(
    CustomerProduct product,
    CustomerViewSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => CustomerProductDetailModal(
        product: product,
        settings: settings,
        onAddToCart: ({
          required int quantity,
          String? variant,
          List<String> addOns = const [],
          String instructions = '',
          double extraPrice = 0.0,
        }) {
          ref.read(customerViewProvider.notifier).addToCart(
                product,
                quantity: quantity,
                variant: variant,
                addOns: addOns,
                instructions: instructions,
                extraPrice: extraPrice,
              );
        },
      ),
    );
  }

  void _navigateToCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const CustomerCheckoutPage(),
      ),
    );
  }

  Widget _buildPromoBanner(CustomerViewSettings settings, Color primaryColor, Color accentColor) {
    if (!settings.showPromoBanner || _promoBannerDismissed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.88),
            accentColor.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.promoBannerTitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  settings.promoBannerSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'SPECIAL OFFER',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _promoBannerDismissed = true),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                LucideIcons.x,
                size: 15,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryFilterRow(
    String activeFilter,
    CustomerViewNotifier notifier,
    Color primaryColor,
    Color accentColor,
    bool isDark,
  ) {
    final filters = [
      {'key': 'All', 'label': 'All Items', 'icon': LucideIcons.utensilsCrossed},
      {'key': 'Veg', 'label': '🌿 Pure Veg', 'icon': LucideIcons.leaf},
      {'key': 'Non-Veg', 'label': '🍗 Non-Veg', 'icon': LucideIcons.drumstick},
      {'key': 'Specials', 'label': "★ Chef's Specials", 'icon': LucideIcons.sparkles},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => notifier.setDietaryFilter(f['key'] as String),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f['icon'] as IconData,
                      size: 12,
                      color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      f['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttractScreenOverlay(CustomerViewSettings settings, Color primaryColor, Color accentColor) {
    return GestureDetector(
      onTap: _dismissAttractScreen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              primaryColor.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.2),
                ),
              ),
            ),

            // Content
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryColor, accentColor]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.utensilsCrossed,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      settings.businessName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      settings.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Pulsing Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accentColor, accentColor.withValues(alpha: 0.9)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.hand, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            settings.attractHeadline,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Tap anywhere on screen to begin order',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerViewProvider);
    final notifier = ref.read(customerViewProvider.notifier);
    final settings = customerState.settings;
    final primaryColor = Color(settings.primaryColorValue);
    final accentColor = Color(settings.accentColorValue);
    final isDark = settings.isDarkMode;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyE, meta: true, shift: true):
            _showOwnerAuthDialog,
        const SingleActivator(LogicalKeyboardKey.keyE, control: true, shift: true):
            _showOwnerAuthDialog,
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        child: Listener(
          onPointerDown: (_) => _resetIdleTimer(),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
                body: SafeArea(
                  child: Column(
                    children: [
                      // ─── 1. KIOSK HEADER ───
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Business Logo / Icon
                            if (settings.showBusinessLogo) ...[
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, accentColor],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.utensilsCrossed,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],

                            // Business Name & Welcome Headline
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (settings.showBusinessName)
                                  Text(
                                    settings.businessName,
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                if (settings.showWelcomeMessage)
                                  Text(
                                    settings.welcomeHeadline,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),

                            const Spacer(),

                            // Order Type Switcher (Dine In / Takeaway)
                            if (settings.allowOrderTypeSelection)
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ['Dine In', 'Takeaway'].map((type) {
                                    final isSelected = customerState.selectedOrderType == type;
                                    return InkWell(
                                      onTap: () => notifier.setOrderType(type),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark ? const Color(0xFF334155) : Colors.white)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.08),
                                                    blurRadius: 4,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              type == 'Dine In' ? LucideIcons.utensils : LucideIcons.packageOpen,
                                              size: 13,
                                              color: isSelected
                                                  ? primaryColor
                                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              type,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                color: isSelected
                                                    ? (isDark ? Colors.white : const Color(0xFF111827))
                                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            const SizedBox(width: 14),

                            // Search Bar
                            Container(
                              width: 220,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.search, size: 14, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: notifier.setSearchQuery,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search items...',
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (customerState.searchQuery.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        _searchController.clear();
                                        notifier.setSearchQuery('');
                                      },
                                      child: const Icon(LucideIcons.x, size: 13, color: Color(0xFF9CA3AF)),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Discreet Owner Lock Button (with key hint)
                            Tooltip(
                              message: 'Owner Exit & Settings (Cmd+Shift+E)',
                              child: InkWell(
                                onTap: _showOwnerAuthDialog,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Icon(
                                    LucideIcons.lockKeyhole,
                                    size: 16,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─── 2. PROMOTIONAL BANNER (ATTRACTIVE OFFER) ───
                      _buildPromoBanner(settings, primaryColor, accentColor),

                      // ─── 3. CATEGORY TABS & DIETARY FILTERS ───
                      if (settings.showProductCategories) ...[
                        const SizedBox(height: 8),
                        CustomerCategoryNavigation(
                          categories: customerState.availableCategories,
                          selectedCategory: customerState.selectedCategory,
                          onSelectCategory: notifier.setSelectedCategory,
                          primaryColor: primaryColor,
                        ),
                      ],

                      // Dietary Filter Bar (Pure Veg / Non-Veg / Specials)
                      if (settings.enableDietaryFilters)
                        _buildDietaryFilterRow(
                          customerState.dietaryFilter,
                          notifier,
                          primaryColor,
                          accentColor,
                          isDark,
                        ),

                      const SizedBox(height: 8),

                      // ─── 4. MAIN PRODUCT CATALOG & CART TRAY ───
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 1050;
                            final visibleProducts = customerState.visibleProducts;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ─── PRODUCT GRID ───
                                Expanded(
                                  child: visibleProducts.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 68,
                                                height: 68,
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  LucideIcons.searchX,
                                                  size: 30,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Text(
                                                'No items found',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : const Color(0xFF374151),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Try searching with another keyword or pick another category.',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.5,
                                                  color: const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : GridView.builder(
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: isWide
                                                ? (constraints.maxWidth > 1400 ? 4 : 3)
                                                : (constraints.maxWidth > 700 ? 3 : 2),
                                            childAspectRatio: 0.74,
                                            crossAxisSpacing: 14,
                                            mainAxisSpacing: 14,
                                          ),
                                          itemCount: visibleProducts.length,
                                          itemBuilder: (context, index) {
                                            final product = visibleProducts[index];
                                            final cartQty = customerState.getCartQuantity(product.id);

                                            return CustomerProductCard(
                                              product: product,
                                              settings: settings,
                                              cartQuantity: cartQty,
                                              onTap: () => _openProductDetail(product, settings),
                                              onAdd: () => notifier.addToCart(product),
                                              onIncrement: () {
                                                final idx = customerState.cart.indexWhere((i) => i.product.id == product.id);
                                                if (idx >= 0) notifier.incrementCartItem(idx);
                                              },
                                              onDecrement: () {
                                                final idx = customerState.cart.indexWhere((i) => i.product.id == product.id);
                                                if (idx >= 0) notifier.decrementCartItem(idx);
                                              },
                                            );
                                          },
                                        ),
                                ),

                                // ─── RIGHT CART PANEL (Wide screens) ───
                                if (isWide && settings.enableCart)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20, bottom: 20),
                                    child: SizedBox(
                                      width: 360,
                                      child: CustomerCartPanel(
                                        cart: customerState.cart,
                                        subtotal: customerState.cartSubtotal,
                                        gst: customerState.cartGst,
                                        total: customerState.cartTotal,
                                        settings: settings,
                                        onIncrement: notifier.incrementCartItem,
                                        onDecrement: notifier.decrementCartItem,
                                        onRemove: notifier.removeFromCart,
                                        onClear: notifier.clearCart,
                                        onCheckout: _navigateToCheckout,
                                        primaryColor: primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating bottom bar on narrower screens
                bottomNavigationBar: (MediaQuery.of(context).size.width < 1050 &&
                        settings.enableCart &&
                        customerState.cart.isNotEmpty)
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _navigateToCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Tray (${customerState.cartItemCount} items) • ₹${customerState.cartTotal.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight, size: 16),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),

              // Full Screen Attract Mode Overlay
              if (_showAttractScreen)
                _buildAttractScreenOverlay(settings, primaryColor, accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
