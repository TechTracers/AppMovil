import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lock_item/shared/storage/secure.dart';

class JwtHandler {
  static String USER_ID_KEY = 'sub';

  final Map<String, dynamic> _decoded;

  JwtHandler._internal(this._decoded);

  factory JwtHandler.from(String token) {
    final parts = JwtDecoder.decode(token);
    if(!parts.containsKey(JwtHandler.USER_ID_KEY)) {
      throw ArgumentError("The token not is valid.");
    }
    return JwtHandler._internal(parts);
  }

  static Future<JwtHandler> fromStorage() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if(token == null) {
      throw ArgumentError("The token does not saved.");
    }
    return JwtHandler.from(token);
  }

  dynamic get(String key) {
    return _decoded[key];
  }

  int getUserId() {
    return int.parse(get(JwtHandler.USER_ID_KEY));
  }
}
