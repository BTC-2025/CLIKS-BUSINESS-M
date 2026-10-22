import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_product_model.dart';
import '../models/customer_cart_item.dart';
import '../models/customer_order_model.dart';
import '../models/customer_view_settings_model.dart';
import '../services/customer_view_storage_service.dart';

class CustomerViewState {
  final List<CustomerProduct> products;
  final String selectedCategory;
  final String dietaryFilter; // 'All', 'Veg', 'Non-Veg', 'Specials'
  final String searchQuery;
  final List<CustomerCartItem> cart;
  final CustomerViewSettings settings;
  final Map<String, String> customImages; // productId -> path
  final List<String> hiddenProductIds;
  final List<String> featuredProductIds;
  final List<CustomerOrder> placedOrders;
  final CustomerOrder? activeOrder;
  final String selectedOrderType; // 'Dine In', 'Takeaway', 'Express'
  final String customerName;
  final String customerPhone;
  final String tableNumber;
  final String selectedPaymentMode;
  final bool isLoading;

  const CustomerViewState({
    this.products = const [],
    this.selectedCategory = 'All Products',
    this.dietaryFilter = 'All',
    this.searchQuery = '',
    this.cart = const [],
    this.settings = const CustomerViewSettings(),
    this.customImages = const {},
    this.hiddenProductIds = const [],
    this.featuredProductIds = const ['burger-01', 'coffee-01', '3', '9', 'truffle-pasta-01', 'choco-lava-01'],
    this.placedOrders = const [],
    this.activeOrder,
    this.selectedOrderType = 'Dine In',
    this.customerName = '',
    this.customerPhone = '',
    this.tableNumber = '',
    this.selectedPaymentMode = 'Pay at Counter',
    this.isLoading = false,
  });

  List<String> get availableCategories {
    final cats = <String>{'All Products'};
    if (featuredProductIds.isNotEmpty) {
      cats.add('★ Best Sellers');
    }
    for (final p in products) {
      if (!hiddenProductIds.contains(p.id) && p.isVisibleInCustomerView) {
        cats.add(p.category);
      }
    }
    return cats.toList();
  }

  List<CustomerProduct> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();

    return products.where((p) {
      // 1. Owner visibility check
      if (hiddenProductIds.contains(p.id) || !p.isVisibleInCustomerView) {
        return false;
      }

      // 2. Category check
      if (selectedCategory == '★ Best Sellers') {
        if (!featuredProductIds.contains(p.id) && !p.isFeatured) return false;
      } else if (selectedCategory != 'All Products') {
        if (p.category.toLowerCase() != selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // 3. Dietary check
      if (dietaryFilter == 'Veg') {
        if (!p.isVeg) return false;
      } else if (dietaryFilter == 'Non-Veg') {
        if (p.isVeg) return false;
      } else if (dietaryFilter == 'Specials') {
        if (!p.isFeatured && !featuredProductIds.contains(p.id)) return false;
      }

      // 4. Search query check
      if (query.isNotEmpty) {
        final matchName = p.name.toLowerCase().contains(query);
        final matchCategory = p.category.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        if (!matchName && !matchCategory && !matchDesc) return false;
      }

      return true;
    }).toList();
  }

  double get cartSubtotal =>
      cart.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get cartGst =>
      cart.fold(0.0, (sum, item) => sum + item.lineGst);

  double get cartTotal => cartSubtotal + cartGst;

  int get cartItemCount =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  int getCartQuantity(String productId) {
    for (final item in cart) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  CustomerViewState copyWith({
    List<CustomerProduct>? products,
    String? selectedCategory,
    String? dietaryFilter,
    String? searchQuery,
    List<CustomerCartItem>? cart,
    CustomerViewSettings? settings,
    Map<String, String>? customImages,
    List<String>? hiddenProductIds,
    List<String>? featuredProductIds,
    List<CustomerOrder>? placedOrders,
    CustomerOrder? activeOrder,
    bool clearActiveOrder = false,
    String? selectedOrderType,
    String? customerName,
    String? customerPhone,
    String? tableNumber,
    String? selectedPaymentMode,
    bool? isLoading,
  }) {
    return CustomerViewState(
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      dietaryFilter: dietaryFilter ?? this.dietaryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      cart: cart ?? this.cart,
      settings: settings ?? this.settings,
      customImages: customImages ?? this.customImages,
      hiddenProductIds: hiddenProductIds ?? this.hiddenProductIds,
      featuredProductIds: featuredProductIds ?? this.featuredProductIds,
      placedOrders: placedOrders ?? this.placedOrders,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      selectedOrderType: selectedOrderType ?? this.selectedOrderType,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      tableNumber: tableNumber ?? this.tableNumber,
      selectedPaymentMode: selectedPaymentMode ?? this.selectedPaymentMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CustomerViewNotifier extends StateNotifier<CustomerViewState> {
  final CustomerViewStorageService _storage = CustomerViewStorageService();

  CustomerViewNotifier() : super(const CustomerViewState()) {
    _initializeCatalog();
  }

  Future<void> _initializeCatalog() async {
    // 1. Initial product list matching the existing POS catalog + restaurant kiosk menu
    final initialList = [
      // Restaurant & Kiosk Specials
      const CustomerProduct(
        id: 'burger-01',
        name: 'Crispy Gourmet Chicken Burger',
        category: 'Food & Dining',
        price: 249.00,
        stock: 50,
        unit: 'PLATE',
        description: 'Tender crispy chicken breast topped with fresh lettuce, molten cheddar & signature garlic aioli sauce.',
        isFeatured: true,
        isVeg: false,
        dietaryTag: 'Non-Veg',
        calories: '580 kcal',
        rating: 4.9,
        networkImageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['Regular (Single Patty)', 'Double Cheese Patty (+₹70)', 'Meal Combo with Fries (+₹110)'],
        availableAddOns: ['Extra Melted Cheese', 'Crispy Bacon Strip', 'Jalapeño Crunch', 'Spicy Dip'],
      ),
      const CustomerProduct(
        id: 'pizza-02',
        name: 'Artisan Cheesy Margherita 9"',
        category: 'Food & Dining',
        price: 389.00,
        stock: 35,
        unit: 'PCS',
        description: 'Hand-stretched sourdough crust with San Marzano tomato sauce, fresh buffalo mozzarella & sweet basil.',
        isFeatured: true,
        isVeg: true,
        dietaryTag: 'Pure Veg',
        calories: '440 kcal',
        rating: 4.8,
        networkImageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['9-Inch Medium', '12-Inch Large (+₹120)', 'Cheese Burst Crust (+₹60)'],
        availableAddOns: ['Olives & Mushrooms', 'Extra Mozzarella', 'Chili Flakes Sachet'],
      ),
      const CustomerProduct(
        id: 'fries-03',
        name: 'Crispy Golden Peri-Peri Fries',
        category: 'Food & Dining',
        price: 129.00,
        stock: 80,
        unit: 'PACK',
        description: 'Golden crunchy potato fries tossed in zesty peri-peri herbs with creamy mayo.',
        isFeatured: false,
        isVeg: true,
        dietaryTag: 'Pure Veg',
        calories: '310 kcal',
        rating: 4.7,
        networkImageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['Regular', 'Large (+₹40)'],
        availableAddOns: ['Cheese Sauce', 'Smoky BBQ Sauce', 'Garlic Dip'],
      ),
      const CustomerProduct(
        id: 'truffle-pasta-01',
        name: 'Creamy Truffle Wild Mushroom Pasta',
        category: 'Food & Dining',
        price: 349.00,
        stock: 40,
        unit: 'PLATE',
        description: 'Fettuccine pasta in velvety white truffle reduction with button mushrooms, parmesan & crushed pepper.',
        isFeatured: true,
        isVeg: true,
        dietaryTag: 'Chef Special',
        calories: '490 kcal',
        rating: 4.9,
        networkImageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['Regular Portion', 'Large Bowl (+₹80)'],
        availableAddOns: ['Garlic Herb Bread (2 Pcs)', 'Extra Parmesan Snow', 'Chili Flakes'],
      ),
      const CustomerProduct(
        id: 'coffee-01',
        name: 'Signature Iced Caramel Frappe',
        category: 'Beverages',
        price: 189.00,
        stock: 60,
        unit: 'CUP',
        description: 'Rich dark espresso blended with cream, sea-salt caramel syrup and topped with whipped foam.',
        isFeatured: true,
        isVeg: true,
        dietaryTag: 'Beverage',
        calories: '220 kcal',
        rating: 4.9,
        networkImageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['Regular (350ml)', 'Large (500ml) (+₹40)'],
        availableAddOns: ['Oat Milk Swap (+₹30)', 'Extra Espresso Shot (+₹35)', 'Vanilla Drizzle'],
      ),
      const CustomerProduct(
        id: 'drink-02',
        name: 'Fresh Mint Lime Sparkling Soda',
        category: 'Beverages',
        price: 119.00,
        stock: 75,
        unit: 'CUP',
        description: 'Freshly squeezed key lime, crushed garden mint leaves and carbonated mountain water.',
        isFeatured: false,
        isVeg: true,
        dietaryTag: 'Beverage',
        calories: '90 kcal',
        rating: 4.6,
        networkImageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: 'choco-lava-01',
        name: 'Warm Belgian Molten Choco Lava',
        category: 'Food & Dining',
        price: 149.00,
        stock: 45,
        unit: 'PCS',
        description: 'Decadent dark chocolate sponge cake with hot melted ganache core, served warm.',
        isFeatured: true,
        isVeg: true,
        dietaryTag: 'Chef Special',
        calories: '340 kcal',
        rating: 5.0,
        networkImageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600&auto=format&fit=crop&q=80',
        availableVariants: ['Single Cake', 'A La Mode (Vanilla Scoop) (+₹40)'],
        availableAddOns: ['Extra Fudge Sauce', 'Roasted Almond Flakes'],
      ),

      // Reused existing POS products
      const CustomerProduct(
        id: '2',
        name: 'Apple Organic Fresh',
        sku: 'SKU: app',
        category: 'General',
        price: 500.00,
        stock: 8,
        description: 'Crisp, sweet, organic Himalayan red apples packed with nutrition.',
        isVeg: true,
        dietaryTag: 'Pure Veg',
        calories: '95 kcal',
        rating: 4.8,
        networkImageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '5',
        name: 'Farm Fresh Orange Carrots (1kg)',
        sku: 'SKU: SKU-746095',
        category: 'General',
        price: 526.00,
        stock: 1180,
        description: 'Freshly harvested crunchy farm carrots, washed and pre-graded.',
        isVeg: true,
        dietaryTag: 'Pure Veg',
        calories: '80 kcal',
        rating: 4.7,
        networkImageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '10',
        name: 'Farm Fresh Pure Milk 1L',
        sku: 'SKU: MILK-101',
        category: 'General',
        price: 65.00,
        stock: 140,
        description: 'Pure homogenized whole milk rich in calcium and natural proteins.',
        isVeg: true,
        dietaryTag: 'Pure Veg',
        calories: '150 kcal',
        rating: 4.9,
        networkImageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '1',
        name: 'Digital POS Accessory Pack',
        sku: 'SKU: SKU-3752',
        category: 'Electronics',
        price: 4399.00,
        stock: 416,
        description: 'Complete high-precision hardware accessory kit.',
        rating: 4.6,
        networkImageUrl: 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '8',
        name: 'Ultra-Fast Performance Laptop',
        sku: 'SKU: j- rcn',
        category: 'Electronics',
        price: 54000.00,
        stock: 72,
        description: 'Sleek aluminum chassis with 16GB RAM and lightning fast NVMe SSD storage.',
        rating: 4.9,
        networkImageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '9',
        name: 'Apple MacBook Pro M3',
        sku: 'SKU: MAC-02',
        category: 'Electronics',
        price: 124999.00,
        stock: 15,
        description: 'Stunning Liquid Retina XDR display with incredible all-day battery efficiency.',
        isFeatured: true,
        rating: 5.0,
        networkImageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '11',
        name: 'Insulated Thermal Bottle 750ml',
        sku: 'SKU: BOT-99',
        category: 'General',
        price: 799.00,
        stock: 55,
        description: 'Double-walled vacuum insulated stainless steel keeps drinks ice-cold for 24 hours.',
        rating: 4.8,
        networkImageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600&auto=format&fit=crop&q=80',
      ),
      const CustomerProduct(
        id: '12',
        name: 'Sport Athletic Running Shoes',
        sku: 'SKU: FW-11',
        category: 'Footwear',
        price: 1899.00,
        stock: 20,
        description: 'Breathable fly-knit upper with responsive shock-absorbing cushioning.',
        rating: 4.7,
        networkImageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
      ),
    ];

    // 2. Load persistent config from disk if available
    final savedData = await _storage.loadConfiguration();
    if (savedData != null) {
      CustomerViewSettings settings = state.settings;
      if (savedData['settings'] is Map<String, dynamic>) {
        settings = CustomerViewSettings.fromJson(savedData['settings']);
      }

      Map<String, String> customImages = {};
      if (savedData['customImages'] is Map) {
        customImages = Map<String, String>.from(savedData['customImages']);
      }

      List<String> hiddenProductIds = [];
      if (savedData['hiddenProductIds'] is List) {
        hiddenProductIds = (savedData['hiddenProductIds'] as List)
            .map((e) => e.toString())
            .toList();
      }

      List<String> featuredProductIds = state.featuredProductIds;
      if (savedData['featuredProductIds'] is List) {
        featuredProductIds = (savedData['featuredProductIds'] as List)
            .map((e) => e.toString())
            .toList();
      }

      // Apply custom images to products
      final updatedProducts = initialList.map((p) {
        if (customImages.containsKey(p.id)) {
          return p.copyWith(customImagePath: customImages[p.id]);
        }
        return p;
      }).toList();

      state = state.copyWith(
        products: updatedProducts,
        settings: settings,
        customImages: customImages,
        hiddenProductIds: hiddenProductIds,
        featuredProductIds: featuredProductIds,
      );
    } else {
      state = state.copyWith(products: initialList);
    }
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setDietaryFilter(String filter) {
    state = state.copyWith(dietaryFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> applyVisualThemePreset(String presetKey) async {
    int primary = 0xFF059669;
    int accent = 0xFFF59E0B;
    bool isDark = false;

    switch (presetKey) {
      case 'emerald_gourmet':
        primary = 0xFF059669; // Fresh Emerald
        accent = 0xFFF59E0B;  // Amber Gold
        isDark = false;
        break;
      case 'tokyo_amber':
        primary = 0xFFEA580C; // Warm Flame Orange
        accent = 0xFFFBBF24;  // Golden Sunrise
        isDark = false;
        break;
      case 'cyber_indigo':
        primary = 0xFF4F46E5; // Cyber Electric Indigo
        accent = 0xFF06B6D4;  // Neon Cyan
        isDark = false;
        break;
      case 'ruby_velvet':
        primary = 0xFFBE123C; // Rose & Ruby Velvet
        accent = 0xFFFB7185;  // Coral Glow
        isDark = false;
        break;
      case 'sunset_gold':
        primary = 0xFFD97706; // Regal Saffron
        accent = 0xFF92400E;  // Warm Espresso
        isDark = false;
        break;
      case 'midnight_luxury':
        primary = 0xFF10B981; // Mint Platinum
        accent = 0xFF34D399;  // Emerald Glow
        isDark = true;
        break;
    }

    final updated = state.settings.copyWith(
      themePreset: presetKey,
      primaryColorValue: primary,
      accentColorValue: accent,
      isDarkMode: isDark,
    );
    await updateSettings(updated);
  }

  Future<void> applyGourmetFoodPresets() async {
    // Curated high quality food photography URLs for the kiosk items
    final presets = {
      'burger-01': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
      'pizza-02': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80',
      'fries-03': 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600&auto=format&fit=crop&q=80',
      'truffle-pasta-01': 'https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=600&auto=format&fit=crop&q=80',
      'coffee-01': 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=600&auto=format&fit=crop&q=80',
      'drink-02': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&auto=format&fit=crop&q=80',
      'choco-lava-01': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600&auto=format&fit=crop&q=80',
      '2': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80',
      '5': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
      '10': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&auto=format&fit=crop&q=80',
    };

    final updatedProducts = state.products.map((p) {
      if (presets.containsKey(p.id)) {
        return p.copyWith(networkImageUrl: presets[p.id]);
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedProducts);
  }

  void setOrderType(String type) {
    state = state.copyWith(selectedOrderType: type);
  }

  void setCustomerInfo({String? name, String? phone, String? table}) {
    state = state.copyWith(
      customerName: name ?? state.customerName,
      customerPhone: phone ?? state.customerPhone,
      tableNumber: table ?? state.tableNumber,
    );
  }

  void setPaymentMode(String mode) {
    state = state.copyWith(selectedPaymentMode: mode);
  }

  void addToCart(
    CustomerProduct product, {
    int quantity = 1,
    String? variant,
    List<String> addOns = const [],
    String instructions = '',
    double extraPrice = 0.0,
  }) {
    if (quantity <= 0) return;

    final existingIndex = state.cart.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedVariant == variant &&
        item.specialInstructions == instructions);

    if (existingIndex >= 0) {
      final updatedCart = List<CustomerCartItem>.from(state.cart);
      final currentItem = updatedCart[existingIndex];
      final newQuantity = currentItem.quantity + quantity;

      // Stock clamp check
      if (newQuantity <= product.stock) {
        updatedCart[existingIndex] =
            currentItem.copyWith(quantity: newQuantity);
        state = state.copyWith(cart: updatedCart);
      }
    } else {
      final newItem = CustomerCartItem(
        product: product,
        quantity: quantity,
        selectedVariant: variant,
        selectedAddOns: addOns,
        specialInstructions: instructions,
        extraPrice: extraPrice,
      );
      state = state.copyWith(cart: [...state.cart, newItem]);
    }
  }

  void incrementCartItem(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final item = state.cart[index];
    if (item.quantity >= item.product.stock) return;

    final updated = List<CustomerCartItem>.from(state.cart);
    updated[index] = item.copyWith(quantity: item.quantity + 1);
    state = state.copyWith(cart: updated);
  }

  void decrementCartItem(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final item = state.cart[index];
    final updated = List<CustomerCartItem>.from(state.cart);

    if (item.quantity > 1) {
      updated[index] = item.copyWith(quantity: item.quantity - 1);
    } else {
      updated.removeAt(index);
    }
    state = state.copyWith(cart: updated);
  }

  void removeFromCart(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final updated = List<CustomerCartItem>.from(state.cart);
    updated.removeAt(index);
    state = state.copyWith(cart: updated);
  }

  void clearCart() {
    state = state.copyWith(cart: []);
  }

  CustomerOrder placeOrder() {
    final orderNum = 1000 + Random().nextInt(8999);
    final orderId = 'K-$orderNum';

    final order = CustomerOrder(
      orderId: orderId,
      items: List<CustomerCartItem>.from(state.cart),
      subtotal: state.cartSubtotal,
      gst: state.cartGst,
      totalAmount: state.cartTotal,
      customerName: state.customerName.isEmpty ? 'Guest Customer' : state.customerName,
      customerPhone: state.customerPhone,
      orderType: state.selectedOrderType,
      tableOrToken: state.tableNumber,
      paymentMode: state.selectedPaymentMode,
      paymentStatus: state.selectedPaymentMode == 'UPI QR Code' ? 'Payment Completed' : 'Payment Pending',
      orderStatus: 'Preparing your order',
      createdAt: DateTime.now(),
      estimatedPrepMinutes: state.settings.defaultPreparationMinutes,
    );

    // Deduct stock from products in catalog
    final updatedProducts = state.products.map((p) {
      final cartItem = state.cart.firstWhere(
        (ci) => ci.product.id == p.id,
        orElse: () => CustomerCartItem(product: p, quantity: 0),
      );
      if (cartItem.quantity > 0) {
        return p.copyWith(stock: max(0, p.stock - cartItem.quantity));
      }
      return p;
    }).toList();

    state = state.copyWith(
      products: updatedProducts,
      placedOrders: [order, ...state.placedOrders],
      activeOrder: order,
      cart: [], // Clear cart after placing order
    );

    return order;
  }

  void resetActiveOrder() {
    state = state.copyWith(clearActiveOrder: true);
  }

  // ═══════════════════════════════════════════════════════════════
  // OWNER SETTINGS & IMAGE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  Future<void> updateSettings(CustomerViewSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _saveConfig();
  }

  Future<void> setProductCustomImage(String productId, String imagePath) async {
    final updatedImages = Map<String, String>.from(state.customImages);
    updatedImages[productId] = imagePath;

    final updatedProducts = state.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(customImagePath: imagePath);
      }
      return p;
    }).toList();

    state = state.copyWith(
      products: updatedProducts,
      customImages: updatedImages,
    );
    await _saveConfig();
  }

  Future<void> removeProductCustomImage(String productId) async {
    final updatedImages = Map<String, String>.from(state.customImages);
    updatedImages.remove(productId);

    final updatedProducts = state.products.map((p) {
      if (p.id == productId) {
        return CustomerProduct(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          stock: p.stock,
          unit: p.unit,
          sku: p.sku,
          gstRate: p.gstRate,
          description: p.description,
          customImagePath: null,
          networkImageUrl: p.networkImageUrl,
          isVisibleInCustomerView: p.isVisibleInCustomerView,
          isFeatured: p.isFeatured,
          availableVariants: p.availableVariants,
          availableAddOns: p.availableAddOns,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(
      products: updatedProducts,
      customImages: updatedImages,
    );
    await _saveConfig();
  }

  Future<void> toggleProductVisibility(String productId, [bool? isVisible]) async {
    final updatedHidden = List<String>.from(state.hiddenProductIds);
    final targetVisible = isVisible ?? updatedHidden.contains(productId);
    if (!targetVisible) {
      if (!updatedHidden.contains(productId)) updatedHidden.add(productId);
    } else {
      updatedHidden.remove(productId);
    }

    state = state.copyWith(hiddenProductIds: updatedHidden);
    await _saveConfig();
  }

  Future<void> toggleProductFeatured(String productId, bool isFeatured) async {
    final updatedFeatured = List<String>.from(state.featuredProductIds);
    if (isFeatured) {
      if (!updatedFeatured.contains(productId)) updatedFeatured.add(productId);
    } else {
      updatedFeatured.remove(productId);
    }

    state = state.copyWith(featuredProductIds: updatedFeatured);
    await _saveConfig();
  }

  Future<void> toggleFeaturedProduct(String productId) async {
    final isCurrentlyFeatured = state.featuredProductIds.contains(productId);
    await toggleProductFeatured(productId, !isCurrentlyFeatured);
  }

  Future<void> resetProductImage(String productId) => removeProductCustomImage(productId);

  Future<void> _saveConfig() async {
    await _storage.saveConfiguration(
      settings: state.settings,
      customImages: state.customImages,
      hiddenProductIds: state.hiddenProductIds,
      featuredProductIds: state.featuredProductIds,
    );
  }
}

final customerViewProvider =
    StateNotifierProvider<CustomerViewNotifier, CustomerViewState>(
  (ref) => CustomerViewNotifier(),
);
