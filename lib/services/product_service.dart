import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String productsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/products';
  static const String storeProductsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/storeProducts';

  Future<List<Product>> fetchStoreProducts(int storeId) async {
    try {
      // Obtén los datos de ambos endpoints
      final productsResponse = await http.get(Uri.parse(productsUrl));
      final storeProductsResponse = await http.get(Uri.parse(storeProductsUrl));

      // Verifica que ambas respuestas sean exitosas
      if (productsResponse.statusCode == 200 && storeProductsResponse.statusCode == 200) {
        // Decodifica los datos
        List<dynamic> productsData = json.decode(productsResponse.body);
        List<dynamic> storeProductsData = json.decode(storeProductsResponse.body);

        // Lista para almacenar los productos filtrados
        List<Product> filteredProducts = [];

        // Filtra los productos por `storeId`
        for (var storeProduct in storeProductsData) {
          if (storeProduct['storeId'] == storeId) {
            // Busca el producto correspondiente
            final product = productsData.firstWhere(
                  (p) => p['id'] == storeProduct['productId'],
              orElse: () => null,
            );

            if (product != null) {
              // Agrega el producto filtrado a la lista
              filteredProducts.add(Product(
                id: product['id'],
                name: product['name'],
                description: product['description'],
                imageUrl: product['imageUrl'],
                price: storeProduct['price'].toDouble(),
                categoryId: product['categoryId'], // Aquí pasamos el categoryId desde el JSON
              ));
            }
          }
        }

        return filteredProducts;
      } else {
        throw Exception('Failed to load data from one or more endpoints');
      }
    } catch (e) {
      // Manejo de errores
      print('Error fetching store products: $e');
      rethrow;
    }
  }

  Future<Product> fetchProductById(int productId) async {
    try {
      final productResponse = await http.get(Uri.parse('$productsUrl/$productId'));
      final storeProductResponse = await http.get(Uri.parse(storeProductsUrl));

      if (productResponse.statusCode == 200 && storeProductResponse.statusCode == 200) {
        final productData = json.decode(productResponse.body);
        final storeProducts = json.decode(storeProductResponse.body);

        final storeProduct = storeProducts.firstWhere(
              (sp) => sp['productId'] == productId,
          orElse: () => null,
        );

        return Product(
          id: productData['id'],
          name: productData['name'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: storeProduct != null ? storeProduct['price'].toDouble() : 0.0,
          categoryId: productData['categoryId'],
        );
      } else {
        throw Exception('Failed to fetch product details');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }
  }

}
