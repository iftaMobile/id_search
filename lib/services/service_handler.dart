import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ServiceHandler {
  static const int GET  = 1;
  static const int POST = 2;

  /// Macht einen HTTP-Request und liefert den Response-Body als String zurück.
  /// Wir fügen Debug-Prints für URL, Parameter, Statuscode und Body hinzu.
  Future<String> makeServiceCall(
      String url,
      int method, [
        Map<String, String>? params,
      ]) async {
    http.Response response;

    if (method == POST) {
      // x-www-form-urlencoded Body zusammenbauen
      final body = params?.entries
          .map((e) =>
      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&') ??
          '';

      debugPrint('🟡 POST → $url');
      debugPrint('   ↳ Body: $body');

      response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
    } else {
      // GET mit optional angehängten Query-Parametern
      final uri = params != null
          ? Uri.parse(url).replace(queryParameters: params)
          : Uri.parse(url);

      debugPrint('🟡 GET → $uri');
      response = await http.get(uri);
    }

    debugPrint('🔵 Statuscode: ${response.statusCode}');
    debugPrint('🔵 Body:\n${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      // Optional: Redirect-Location loggen, falls vorhanden
      final location = response.headers['location'];
      if (location != null) {
        debugPrint('🔴 Redirect-Location: $location');
      }
      throw Exception(
          'HTTP-Fehler ${response.statusCode} beim Aufruf von $url');
    }
  }
}



// Ein Singleton-Client, der Cookies persistiert
class CookieHttpClient {
  static final CookieHttpClient _instance = CookieHttpClient._();
  late final HttpClient httpClient;

  CookieHttpClient._() {
    httpClient = HttpClient()..badCertificateCallback = (_,_ ,__)=>(true);
    // HttpClient verwaltet Cookies automatisch für die Session
  }

  factory CookieHttpClient() => _instance;
}
