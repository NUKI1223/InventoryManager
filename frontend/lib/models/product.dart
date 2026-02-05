class Product {
  final int id;
  final String name;
  final String sku;
  final int currentStock;
  final double price;
  final String? imagePath;
  final int? categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.currentStock,
    required this.price,
    this.imagePath,
    this.categoryId,
    this.categoryName,
  });

  String get imageUrl => imagePath ?? '';

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    int? currentStock,
    double? price,
    String? imagePath,
    int? categoryId,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      currentStock: currentStock ?? this.currentStock,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      currentStock: json['currentStock'],
      price: (json['price'] as num).toDouble(),
      imagePath: json['imagePath'],
      categoryId: category?['id'],
      categoryName: category?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'description': '',
      'currentStock': currentStock,
      'price': price,
      'imagePath': imagePath,
      'categoryId': categoryId,
    };
  }
}
