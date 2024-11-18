class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final productData = json.containsKey('product') ? json['product'] : json; // Maneja ambos casos
    final categoryData = productData['category'] ?? {}; // Maneja valores nulos de 'category'

    return Product(
      id: productData['id'] ?? 0, // Predeterminado a 0 si 'id' es null
      name: productData['name'] ?? 'Unknown', // Predeterminado a 'Unknown'
      description: productData['description'] ?? 'No description available',
      imageUrl: productData['imageUrl'] ?? '', // Predeterminado a una cadena vacía
      price: json['price'] != null ? json['price'].toDouble() : 0.0, // Maneja valores nulos
      categoryId: categoryData['id']?.toString() ?? 'Unknown', // Maneja valores nulos y lo convierte a String
    );
  }
}

