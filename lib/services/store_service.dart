import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';

class StoreService {
  static const String _baseUrl = 'https://my-json-server.typicode.com/Ednoru/arquidb/stores';

  Future<List<Store>> fetchStores() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Store.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      print('Error fetching stores: $e');
      rethrow;
    }
  }
}
