class OrderItemModel {
  final String menuItemId;
  final String name;
  final int unitPrice;
  final int quantity;
  final String? notes;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.notes,
  });

  int get subtotal => unitPrice * quantity;

  OrderItemModel copyWith({
    String? menuItemId,
    String? name,
    int? unitPrice,
    int? quantity,
    String? notes,
  }) {
    return OrderItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'notes': notes,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        menuItemId: json['menuItemId'] as String,
        name: json['name'] as String,
        unitPrice: (json['unitPrice'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
        notes: json['notes'] as String?,
      );
}

