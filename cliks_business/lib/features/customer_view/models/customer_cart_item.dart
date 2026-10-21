import 'customer_product_model.dart';

class CustomerCartItem {
  final CustomerProduct product;
  int quantity;
  final String? selectedVariant;
  final List<String> selectedAddOns;
  final String specialInstructions;
  final double extraPrice;

  CustomerCartItem({
    required this.product,
    this.quantity = 1,
    this.selectedVariant,
    this.selectedAddOns = const [],
    this.specialInstructions = '',
    this.extraPrice = 0.0,
  });

  double get unitPrice => product.price + extraPrice;
  double get lineTotal => unitPrice * quantity;
  double get lineGst => lineTotal * product.gstRate;

  CustomerCartItem copyWith({
    CustomerProduct? product,
    int? quantity,
    String? selectedVariant,
    List<String>? selectedAddOns,
    String? specialInstructions,
    double? extraPrice,
  }) {
    return CustomerCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      extraPrice: extraPrice ?? this.extraPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedVariant': selectedVariant,
      'selectedAddOns': selectedAddOns,
      'specialInstructions': specialInstructions,
      'extraPrice': extraPrice,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  factory CustomerCartItem.fromJson(Map<String, dynamic> json) {
    return CustomerCartItem(
      product: CustomerProduct.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedVariant: json['selectedVariant']?.toString(),
      selectedAddOns: (json['selectedAddOns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions']?.toString() ?? '',
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
