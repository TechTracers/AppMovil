class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int categoryId; // Agregar esta propiedad

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.categoryId, // Asegúrate de inicializarla
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()), // Convertir a double si es necesario
      categoryId: json['categoryId'], // Asignar categoryId desde el JSON
    );
  }
}
