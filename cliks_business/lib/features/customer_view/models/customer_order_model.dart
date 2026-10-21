import 'customer_cart_item.dart';

class CustomerOrder {
  final String orderId;
  final List<CustomerCartItem> items;
  final double subtotal;
  final double gst;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String orderType;
  final String tableOrToken;
  final String paymentMode;
  final String paymentStatus; // 'Payment Pending', 'Payment Completed'
  final String orderStatus; // 'Order Received', 'Preparing your order', 'Ready for Pickup', 'Completed'
  final DateTime createdAt;
  final int estimatedPrepMinutes;

  const CustomerOrder({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.totalAmount,
    this.customerName = 'Guest Customer',
    this.customerPhone = '',
    this.orderType = 'Dine In',
    this.tableOrToken = '',
    required this.paymentMode,
    this.paymentStatus = 'Payment Pending',
    this.orderStatus = 'Preparing your order',
    required this.createdAt,
    this.estimatedPrepMinutes = 12,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  DateTime get estimatedReadyTime =>
      createdAt.add(Duration(minutes: estimatedPrepMinutes));

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'orderType': orderType,
      'tableOrToken': tableOrToken,
      'paymentMode': paymentMode,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt.toIso8601String(),
      'estimatedPrepMinutes': estimatedPrepMinutes,
    };
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: json['orderId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CustomerCartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName']?.toString() ?? 'Guest Customer',
      customerPhone: json['customerPhone']?.toString() ?? '',
      orderType: json['orderType']?.toString() ?? 'Dine In',
      tableOrToken: json['tableOrToken']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'Pay at Counter',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Payment Pending',
      orderStatus: json['orderStatus']?.toString() ?? 'Preparing your order',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      estimatedPrepMinutes:
          (json['estimatedPrepMinutes'] as num?)?.toInt() ?? 12,
    );
  }
}
