import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static SecureStorage? _instance;
  static String AUTH_TOKEN = "authToken";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureStorage._internal();

  factory SecureStorage() {
    _instance ??= SecureStorage._internal();
    return _instance!;
  }

  Future<void> save(String key, String? value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  Future<bool> contains(String key) {
    return _storage.containsKey(key: key);
  }

  Future<String?> getToken() {
    return get(SecureStorage.AUTH_TOKEN);
  }

  Future<void> saveToken(String value) {
    return save(SecureStorage.AUTH_TOKEN, value);
  }

  Future<void> deleteToken() {
    return delete(SecureStorage.AUTH_TOKEN);
  }

  Future<bool> containsToken() {
    return contains(SecureStorage.AUTH_TOKEN);
  }
}
