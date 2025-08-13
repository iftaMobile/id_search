// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiService {
  static Future<Map<String, dynamic>> fetchIftaData({
    required String coin,
  }) async {
    // Hier die fehlenden Argumente ergänzen:
    final sesid = await SessionManager.instance.getSesId(
      username: 'apiuser',           // dein echter Login‐User
      password: 'geheimesPasswort',  // dein echtes Passwort
    );

    final uri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/jiftacoins.php',
    ).replace(queryParameters: {
      'coin':  coin,
      'sesid': sesid,
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Server-Error: ${resp.statusCode}');
    }
    return json.decode(resp.body) as Map<String, dynamic>;
  }

  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final baseUri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/ifta_login.php',
    );
    final uri = baseUri.replace(queryParameters: {
      'tag':   'login',
      'uname': username,
      'pass':  password,
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Login fehlgeschlagen: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonResp = json.decode(resp.body);
    if (jsonResp['status'] != 'ok' || jsonResp['sesid'] == null) {
      throw Exception('Login-Error: ${resp.body}');
    }

    return jsonResp['sesid'] as String;
  }
}