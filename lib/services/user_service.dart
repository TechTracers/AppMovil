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
    if (token != null) {
      return JwtDecoder.decode(token);
    }
    return null;
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
}
