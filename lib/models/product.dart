class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String categoryId;
  final String iotUID;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    required this.iotUID,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final productData = json.containsKey('product') ? json['product'] : json;
    final categoryData = productData['category'] ?? {};

    return Product(
      id: productData['id'] ?? 0,
      name: productData['name'] ?? 'Unknown',
      description: productData['description'] ?? 'No description available',
      imageUrl: productData['imageUrl'] ?? '',
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      categoryId: categoryData['id']?.toString() ?? 'Unknown',
      iotUID: json['iotUID'] ?? '',
    );
  }
}

