import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService {
  // URLs base de los endpoints
  static const String productsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/products';
  static const String storeProductsUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/storeProducts';

  // Método para obtener productos de una tienda específica
  Future<List<Product>> fetchStoreProducts(int storeId) async {
    try {
      // Obtén los datos de ambos endpoints
      final productsResponse = await http.get(Uri.parse(productsUrl));
      final storeProductsResponse = await http.get(Uri.parse(storeProductsUrl));

      // Asegúrate de que ambas respuestas sean exitosas
      if (productsResponse.statusCode == 200 && storeProductsResponse.statusCode == 200) {
        // Decodifica las respuestas JSON
        List<dynamic> productsData = json.decode(productsResponse.body);
        List<dynamic> storeProductsData = json.decode(storeProductsResponse.body);

        // Lista para almacenar los productos filtrados
        List<Product> filteredProducts = [];

        // Filtrar productos por `storeId`
        for (var storeProduct in storeProductsData) {
          if (storeProduct['storeId'] == storeId) {
            // Busca el producto correspondiente en la lista de productos
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
                price: storeProduct['price'].toDouble(), // Convertir el precio a double si no lo es
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
}