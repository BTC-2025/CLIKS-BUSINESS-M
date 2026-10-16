enum DiscountMode { percentage, flat }

enum PaymentMode { cash, upi, card }

class MobilePosProduct {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  int stock;
  final String unit;
  final double gstRate;
  final String? barcode;

  MobilePosProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'PCS',
    this.gstRate = 0.18,
    this.barcode,
  });

  MobilePosProduct copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stock,
    String? unit,
    double? gstRate,
    String? barcode,
  }) {
    return MobilePosProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      gstRate: gstRate ?? this.gstRate,
      barcode: barcode ?? this.barcode,
    );
  }
}

class MobileCartItem {
  final MobilePosProduct product;
  int quantity;

  MobileCartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class MobileCustomer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gstin;
  final String businessName;
  final int loyaltyPoints;
  final bool isWalkIn;

  const MobileCustomer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.gstin = '',
    this.businessName = '',
    this.loyaltyPoints = 0,
    this.isWalkIn = false,
  });

  static const walkIn = MobileCustomer(
    id: 'walk-in',
    name: 'Walk-in Client',
    phone: '',
    email: '',
    gstin: 'Unregistered',
    businessName: 'Retail Customer',
    loyaltyPoints: 0,
    isWalkIn: true,
  );
}

class MobileHeldCart {
  final String id;
  final MobileCustomer customer;
  final List<MobileCartItem> items;
  final DateTime heldAt;
  final double totalAmount;

  MobileHeldCart({
    required this.id,
    required this.customer,
    required this.items,
    required this.heldAt,
    required this.totalAmount,
  });
}

class MobilePosSale {
  final String billNo;
  final String customer;
  final int itemCount;
  final double totalAmount;
  final String paymentMode;
  final String time;
  final String date;
  final List<MobileCartItem> items;

  MobilePosSale({
    required this.billNo,
    required this.customer,
    required this.itemCount,
    required this.totalAmount,
    required this.paymentMode,
    required this.time,
    this.date = 'Today',
    this.items = const [],
  });
}
