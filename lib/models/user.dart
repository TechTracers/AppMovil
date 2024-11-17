class User {
  final int id;
  final String username;
  final String password;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    this.role = "NORMAL", // Valor predeterminado para el rol
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? "NORMAL",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
