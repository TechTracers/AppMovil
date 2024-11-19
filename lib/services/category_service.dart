import 'package:logger/logger.dart';

import '../shared/services/https_service.dart';

class CategoryService extends HttpsService {
  //static const String categoriesUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/categories';
  static String url = HttpsService.produceUrl("product-categories");

  static String produceUrl(String end, {List<String>? others}) {
    String base = "$url/$end";
    return others == null ? base : '$base/${others.join("/")}';
  }

  final Logger _logger = Logger();

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await iterableGet(
          converter: (category) => {
                'id': category['id'] ?? 0,
                'name': category['name'] ?? 'Unknown',
              });

      return response;
    } catch (e) {
      _logger.e('Error fetching categories: $e');
      rethrow;
    }
  }

  @override
  String getUrl() {
    return CategoryService.url;
  }
}
