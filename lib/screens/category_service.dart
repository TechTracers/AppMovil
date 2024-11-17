import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  // URL del endpoint para obtener las categorías
  static const String categoriesUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/categories';

  // Método para obtener las categorías desde la API
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      // Realiza la solicitud HTTP GET
      final response = await http.get(Uri.parse(categoriesUrl));

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        List<dynamic> categoriesData = json.decode(response.body);

        // Convierte los datos a una lista de Map<String, dynamic>
        return categoriesData.map((category) {
          return {
            'id': category['id'],
            'name': category['name'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Manejo de errores
      print('Error fetching categories: $e');
      rethrow;
    }
  }
}
