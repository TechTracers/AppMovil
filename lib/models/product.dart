class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()), // Conversión explícita a int
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()), // Conversión explícita a double
    );
  }
}
