/// Represents a product in the macOS Customer Self-Ordering Kiosk.
/// Reuses pricing, category, and tax logic from the existing POS system,
/// while filtering out confidential owner fields (margins, costs, supplier info).
class CustomerProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String unit;
  final String sku;
  final double gstRate;
  final String description;
  final String? customImagePath;
  final String? networkImageUrl;
  final bool isVisibleInCustomerView;
  final bool isFeatured;
  final bool isVeg;
  final String? dietaryTag; // 'Pure Veg', 'Non-Veg', 'Chef Special', 'Beverage'
  final String? calories; // e.g. '380 kcal'
  final double rating;
  final List<String> availableVariants;
  final List<String> availableAddOns;

  const CustomerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'PCS',
    this.sku = '',
    this.gstRate = 0.18,
    this.description = '',
    this.customImagePath,
    this.networkImageUrl,
    this.isVisibleInCustomerView = true,
    this.isFeatured = false,
    this.isVeg = true,
    this.dietaryTag,
    this.calories,
    this.rating = 4.8,
    this.availableVariants = const ['Regular', 'Large (+₹50)', 'Combo (+₹120)'],
    this.availableAddOns = const ['Extra Dressing', 'Cheese Topping', 'Gift Pack'],
  });

  bool get isAvailable => stock > 0;

  CustomerProduct copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? unit,
    String? sku,
    double? gstRate,
    String? description,
    String? customImagePath,
    String? networkImageUrl,
    bool? isVisibleInCustomerView,
    bool? isFeatured,
    bool? isVeg,
    String? dietaryTag,
    String? calories,
    double? rating,
    List<String>? availableVariants,
    List<String>? availableAddOns,
  }) {
    return CustomerProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      sku: sku ?? this.sku,
      gstRate: gstRate ?? this.gstRate,
      description: description ?? this.description,
      customImagePath: customImagePath ?? this.customImagePath,
      networkImageUrl: networkImageUrl ?? this.networkImageUrl,
      isVisibleInCustomerView:
          isVisibleInCustomerView ?? this.isVisibleInCustomerView,
      isFeatured: isFeatured ?? this.isFeatured,
      isVeg: isVeg ?? this.isVeg,
      dietaryTag: dietaryTag ?? this.dietaryTag,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      availableVariants: availableVariants ?? this.availableVariants,
      availableAddOns: availableAddOns ?? this.availableAddOns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'unit': unit,
      'sku': sku,
      'gstRate': gstRate,
      'description': description,
      'customImagePath': customImagePath,
      'networkImageUrl': networkImageUrl,
      'isVisibleInCustomerView': isVisibleInCustomerView,
      'isFeatured': isFeatured,
      'isVeg': isVeg,
      'dietaryTag': dietaryTag,
      'calories': calories,
      'rating': rating,
      'availableVariants': availableVariants,
      'availableAddOns': availableAddOns,
    };
  }

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    return CustomerProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      unit: json['unit']?.toString() ?? 'PCS',
      sku: json['sku']?.toString() ?? '',
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 0.18,
      description: json['description']?.toString() ?? '',
      customImagePath: json['customImagePath']?.toString(),
      networkImageUrl: json['networkImageUrl']?.toString(),
      isVisibleInCustomerView: json['isVisibleInCustomerView'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      isVeg: json['isVeg'] ?? true,
      dietaryTag: json['dietaryTag']?.toString(),
      calories: json['calories']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      availableVariants: (json['availableVariants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Regular', 'Large (+₹50)', 'Combo (+₹120)'],
      availableAddOns: (json['availableAddOns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Extra Dressing', 'Cheese Topping', 'Gift Pack'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProduct &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
