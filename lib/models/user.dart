class User {
  final int id;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String? password; // Password ahora es opcional

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    this.password, // Permite que sea opcional
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? 'N/A',
      name: json['name'] ?? 'N/A',
      lastname: json['lastname'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      password: json['password'], // Si el JSON contiene el password
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password, // Solo incluir si no es null
    };
  }
}
