import 'package:lock_item/shared/services/https_service.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';
import '../models/store.dart';

class StoreService extends HttpsService {
  // static const String _baseUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/stores';
  static String url = HttpsService.produceUrl("stores");

  static String produceUrl(String end, {List<String>? others}) {
    String base = "$url/$end";
    return others == null ? base : '$base/${others.join("/")}';
  }

  final Logger _logger = Logger();

  Future<List<Store>> fetchStores() async {
    try {
      final stores = await iterableGet(converter: Store.fromJson);
      return stores;
    } catch (e) {
      _logger.e('Error fetching stores: $e');
      rethrow;
    }
  }

  Future<List<Product>> fetchProducts(int storeId) async {
    try {
      final products = await iterableGet(
          url: produceUrl(storeId.toString(), others: ["products"]),
          converter: Product.fromJson);

      return products;
    } catch (e) {
      _logger.e('Error fetching stores: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final products = await iterableGet(
          url: produceUrl("products"), converter: Product.fromJson);

      return products;
    } catch (e) {
      _logger.e('Error fetching stores: $e');
      rethrow;
    }
  }

  @override
  String getUrl() {
    return StoreService.url;
  }
}
