import 'order_item_model.dart';

enum PaymentMethod { tunai, qris, digital }

class OrderModel {
  final String id;
  final String orderNumber;
  final String cashierName;
  final List<OrderItemModel> items;
  final PaymentMethod paymentMethod;
  final String paymentStatus; // 'paid', 'pending', 'cancelled'
  final int subtotal;
  final int discount;
  final int tax;
  final int total;
  final int cashReceived;
  final int change;
  final DateTime createdAt;
  final String? customerName;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.cashierName,
    required this.items,
    required this.paymentMethod,
    this.paymentStatus = 'paid',
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.cashReceived,
    required this.change,
    required this.createdAt,
    this.customerName,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'cashierName': cashierName,
        'items': items.map((e) => e.toJson()).toList(),
        'paymentMethod': paymentMethod.name,
        'paymentStatus': paymentStatus,
        'subtotal': subtotal,
        'discount': discount,
        'tax': tax,
        'total': total,
        'cashReceived': cashReceived,
        'change': change,
        'createdAt': createdAt.toIso8601String(),
        'customerName': customerName,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        cashierName: json['cashierName'] as String,
        items: (json['items'] as List)
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == json['paymentMethod'],
          orElse: () => PaymentMethod.tunai,
        ),
        paymentStatus: json['paymentStatus'] as String? ?? 'paid',
        subtotal: (json['subtotal'] as num).toInt(),
        discount: (json['discount'] as num?)?.toInt() ?? 0,
        tax: (json['tax'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num).toInt(),
        cashReceived: (json['cashReceived'] as num).toInt(),
        change: (json['change'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        customerName: json['customerName'] as String?,
      );
}

