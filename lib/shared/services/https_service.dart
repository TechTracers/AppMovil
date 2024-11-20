import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:lock_item/shared/storage/secure.dart';

abstract class HttpsService {
  //final String baseUri = "";
  static const hostUrl =
      "https://lockitem-abaje5g7dagcbsew.canadacentral-01.azurewebsites.net";
  static const apiVersion = "api/v1";

  static String produceUrl(String end, {List<String>? others}) {
    String base = "$hostUrl/$apiVersion/$end";
    return others == null ? base : '$base/${others.join("/")}';
  }

  @protected
  final SecureStorage storage = SecureStorage();

  @protected
  String getUrl();

  @protected
  Map<String, String> getRawHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @protected
  Future<Map<String, String>> getHeaders() async {
    final token = await storage.getToken();
    final raw = getRawHeaders();
    if (token != null) raw['Authorization'] = 'Bearer $token';
    return raw;
  }

  @protected
  Future<http.Response> get({String? url}) async {
    final headers = await getHeaders();
    url ??= getUrl();
    return await http.get(Uri.parse(url), headers: headers);
  }

  @protected
  Future<http.Response> getById(int id) {
    return get(url: "${getUrl()}/$id");
  }

  @protected
  Future<http.Response> post(
      {String? url, required Map<String, dynamic> body}) async {
    final headers = await getHeaders();
    url ??= getUrl();
    return await http.post(Uri.parse(url),
        headers: headers, body: json.encode(body));
  }

  @protected
  Future<http.Response> rawPost(
      {String? url, required Map<String, dynamic> body}) {
    final headers = getRawHeaders();
    url ??= getUrl();
    return http.post(Uri.parse(url), headers: headers, body: json.encode(body));
  }

  @protected
  List<Ty> responseMap<Ty>(
          String body, Ty Function(Map<String, dynamic>) converter) =>
      (jsonDecode(body) as Iterable).map((item) => converter(item)).toList();

  @protected
  Future<List<Ty>> iterableGet<Ty>(
      {String? url,
      required Ty Function(Map<String, dynamic>) converter}) async {
    final result = await get(url: url);
    return result.statusCode == HttpStatus.ok
        ? responseMap(result.body, converter)
        : List.empty();
  }

  @protected
  Future<http.Response> put(
      {String? url, required Map<String, dynamic> body}) async {
    final headers = await getHeaders();
    url ??= getUrl();
    return await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }
}
