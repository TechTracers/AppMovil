class Store {
  final int id;
  final String name;
  final String imageUrl;

  Store({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}
