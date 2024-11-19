import 'dart:convert';
import 'package:lock_item/shared/services/https_service.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';

class ProductService extends HttpsService {
  static String url = HttpsService.produceUrl("products");

  static String produceUrl(String end, {List<String>? others}) {
    String base = "$url/$end";
    return others == null ? base : '$base/${others.join("/")}';
  }

  final Logger _logger = Logger();

  Future<Product> fetchProductById(int productId) async {
    try {
      final response = await getById(productId);
      if (response.statusCode != 200) {
        _logger.e('Failed to fetch product. Status: ${response.statusCode}');
        throw Exception('Failed to fetch product details.');
      }
      final data = json.decode(response.body);
      return Product.fromJson(data); // Se utiliza el JSON directamente
    } catch (e) {
      _logger.e('Error fetching product details: $e');
      rethrow;
    }
  }

  @override
  String getUrl() {
    return ProductService.url;
  }
}
