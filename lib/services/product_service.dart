import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/product.dart';

class ProductService {
  // static const String productsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/products';
  // static const String storeProductsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/storeProducts';
  static const String _storeProductsUrl =
      'https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net/api/v1/stores';
  static const String _productsUrl =
      'https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net/api/v1/products';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Future<List<Product>> fetchStoreProducts(int storeId) async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) throw Exception('User token is missing.');

    try {
      final url = Uri.parse('$_storeProductsUrl/$storeId/products');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        _logger.e(
            'Failed to fetch store products. Status: ${response.statusCode}');
        throw Exception('Failed to fetch store products.');
      }
    } catch (e) {
      _logger.e('Error fetching store products: $e');
      rethrow;
    }
  }


  Future<Product> fetchProductById(int productId) async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) throw Exception('User token is missing.');

    try {
      final url = Uri.parse('$_productsUrl/$productId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data); // Se utiliza el JSON directamente
      } else {
        _logger.e('Failed to fetch product. Status: ${response.statusCode}');
        throw Exception('Failed to fetch product details.');
      }
    } catch (e) {
      _logger.e('Error fetching product details: $e');
      rethrow;
    }
  }

}
