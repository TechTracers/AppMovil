import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lock_item/models/user.dart';
import 'package:logger/logger.dart';

class UserService {
  static const String _baseUrl =
      'https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net/api/v1/users';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  // Iniciar sesión
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Guardar token en SecureStorage
        await _secureStorage.write(key: 'authToken', value: data['token']);

        // Decodificar token y loggear
        final decodedToken = JwtDecoder.decode(data['token']);
        _logger.i('Login successful. Decoded token: $decodedToken');

        return data; // Devuelve los datos del usuario
      } else {
        _logger.e('Error logging in: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error logging in: $e');
      return null;
    }
  }

  // Obtener el token almacenado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  // Decodificar el token almacenado
  Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await getToken();
    if (token == null) {
      _logger.e('No token found in secure storage');
      return null;
    }

    try {
      final decodedToken = JwtDecoder.decode(token);
      if (!decodedToken.containsKey('sub')) {
        _logger.e('Decoded token does not contain "sub" key: $decodedToken');
        return null;
      }
      return decodedToken;
    } catch (e) {
      _logger.e('Error decoding token: $e');
      return null;
    }
  }


  // Cerrar sesión (eliminar token)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'authToken');
    _logger.i('User logged out and token deleted.');
  }

  // Registro de nuevo usuario
  Future<bool> registerUser(User newUser) async {
    final url = Uri.parse(_baseUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser.toJson()),
      );

      if (response.statusCode == 201) {
        _logger.i('User registered successfully: ${response.body}');
        return true;
      } else {
        _logger.e('Error registering user: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('Error registering user: $e');
      return false;
    }
  }

  // Obtencion de datos del usuario activo
  Future<User?> getUserById(int id) async {
    final url = Uri.parse('$_baseUrl/$id'); // Endpoint con el ID del usuario
    try {
      final token = await getToken(); // Obtener el token almacenado
      if (token == null) {
        throw Exception("No token found");
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.i('User data fetched: $data'); // Log para depuración
        return User.fromJson(data); // Convertir a modelo User
      } else {
        _logger.e('Error fetching user data: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching user data: $e');
      return null;
    }
  }
}
