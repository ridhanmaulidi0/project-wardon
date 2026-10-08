class CategoryModel {
  final String id;
  final String name;
  final String icon;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon = 'coffee',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'coffee',
      );
}

