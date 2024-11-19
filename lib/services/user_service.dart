import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lock_item/models/user.dart';
import 'package:lock_item/shared/services/https_service.dart';
import 'package:logger/logger.dart';

class UserService extends HttpsService {
  static String url = HttpsService.produceUrl("users");

  static String produceUrl(String end, {List<String>? others}) {
    String base = "$url/$end";
    return others == null ? base : '$base/${others.join("/")}';
  }

  final Logger _logger = Logger();

  // Iniciar sesión
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response =
          await rawPost(url: produceUrl("login"), body: {"username": username, "password": password});
      if (response.statusCode != 200) {
        _logger.e('Error logging in: ${response.body}');
        return null;
      }
      final data = json.decode(response.body);
      await storage.saveToken(data["token"]);

      final decodedToken = JwtDecoder.decode(data['token']);
      _logger.i('Login successful. Decoded token: $decodedToken');

      return data;
    } catch (e) {
      _logger.e('Error logging in: $e');
      return null;
    }
  }

  // Cerrar sesión (eliminar token)
  Future<void> logout() async {
    await storage.deleteToken();
    _logger.i('User logged out and token deleted.');
  }

  // Registro de nuevo usuario
  Future<bool> registerUser(User user) async {
    try {
      final response = await rawPost(body: user.toJson());
      if (response.statusCode != 201) {
        _logger.e('Error registering user: ${response.body}');
        return false;
      }
      _logger.i('User registered successfully: ${response.body}');
      return true;
    } catch (e) {
      _logger.e('Error registering user: $e');
      return false;
    }
  }

  // Obtencion de datos del usuario activo
  Future<User?> getUserById(int id) async {
    try {
      final response = await getById(id);
      if (response.statusCode != 200) {
        _logger.e('Error fetching user data: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      _logger.i('User data fetched: $data'); // Log para depuración
      return User.fromJson(data); // Convertir a modelo User
    } catch (e) {
      _logger.e('Error fetching user data: $e');
      return null;
    }
  }

  @override
  String getUrl() {
    return UserService.url;
  }
}
