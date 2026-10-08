class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final int price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final bool isAvailable;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    this.isAvailable = true,
  });

  bool get inStock => stock > 0 && isAvailable;

  MenuItemModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    int? price,
    int? stock,
    String? imageUrl,
    String? description,
    bool? isAvailable,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'description': description,
        'isAvailable': isAvailable,
      };

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
        imageUrl: json['imageUrl'] as String?,
        description: json['description'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
      );
}

