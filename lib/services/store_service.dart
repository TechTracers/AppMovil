import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lock_item/services/user_service.dart';
import 'package:logger/logger.dart';
import '../models/store.dart';

class StoreService {
  // static const String _baseUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/stores';
  static const String _baseUrl =
      'https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net/api/v1/stores';

  final UserService _userService = UserService();
  final Logger _logger = Logger();

  Future<List<Store>> fetchStores() async {
    try {
      final token = await _userService.getToken();

      // Log para verificar si el token se obtiene correctamente
      if (token == null) {
        _logger.e('Token is null. Please log in.');
        throw Exception('Token is null. Please log in.');
      } else {
        _logger.i('Token retrieved successfully: $token');
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Store.fromJson(json)).toList();
      } else {
        _logger.e('Failed to fetch stores. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch stores. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching stores: $e');
      rethrow;
    }
  }
}
