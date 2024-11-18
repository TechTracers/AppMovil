import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CategoryService {
  //static const String categoriesUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/categories';
  static const String _categoriesUrl =
      'https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net/api/v1/product-categories';


  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) throw Exception('User token is missing.');

    try {
      final response = await http.get(
        Uri.parse(_categoriesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((category) {
          return {
            'id': category['id'] ?? 0,
            'name': category['name'] ?? 'Unknown',
          };
        }).toList();
      } else {
        _logger.e('Failed to fetch categories. Status: ${response.statusCode}');
        throw Exception('Failed to fetch categories.');
      }
    } catch (e) {
      _logger.e('Error fetching categories: $e');
      rethrow;
    }
  }
}
