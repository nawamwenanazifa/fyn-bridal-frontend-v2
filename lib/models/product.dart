class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;
  final int? categoryId;
  final String? color;
  final bool inStock;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.categoryId,
    this.color,
    this.inStock = true,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? json['category_name'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['main_image'] ?? '',
      categoryId: json['category_id'],
      color: json['color'],
      inStock: json['in_stock'] ?? true,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  get mainImage => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'color': color,
      'in_stock': inStock,
      'is_featured': isFeatured,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
    int? categoryId,
    String? color,
    bool? inStock,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      color: color ?? this.color,
      inStock: inStock ?? this.inStock,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}