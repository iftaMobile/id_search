// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/ifta_login.php',
    ).replace(queryParameters: {
      'tag':      'login',
      'uname':    username,
      'password': password,
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Login fehlgeschlagen: ${resp.statusCode}');
    }

    // Debug: siehe komplettes JSON im Log
    print('LOGIN JSON: ${resp.body}');

    // Dynamisch decodieren
    final dynamic decoded = json.decode(resp.body);
    late Map<String, dynamic> result;

    if (decoded is List) {
      // Array-Wurzel: nimm das erste Element
      result = Map<String, dynamic>.from(decoded.first as Map);
    } else if (decoded is Map) {
      // Objekt-Wurzel: direkt casten
      result = Map<String, dynamic>.from(decoded);
    } else {
      throw Exception('Unerwartetes Login-Format: ${decoded.runtimeType}');
    }

    // Jetzt nur noch auf sesid prüfen
    final sesid = result['sesid'];
    if (sesid == null || sesid is! String) {
      throw Exception('Login-Error: ${resp.body}');
    }

    return sesid;
  }

// … dein fetchIftaData bleibt unverändert …

  /// IFTA-Daten abrufen (unsere alte Methode, wird weiterverwendet)
  static Future<Map<String, dynamic>> fetchIftaData({
    required String coin,
    required String sesid,
  }) async {
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

    // 1) Roh-JSON ausgeben
    print('=== IFTA RAW JSON ===\n${resp.body}\n=== end RAW ===');

    // 2) JSON dekodieren
    final dynamic decoded = json.decode(resp.body);
    late Map<String, dynamic> parsed;
    if (decoded is Map) {
      parsed = decoded.cast<String, dynamic>();
    } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      parsed = (decoded.first as Map).cast<String, dynamic>();
    } else {
      parsed = {};
    }

    // 3) Welche Keys hat das Map wirklich?
    print('parsed.keys: ${parsed.keys.toList()}');

    // 4) Raw-Listen holen – sowohl Groß- als auch Klein-Key abfragen
    final List<dynamic> rawInfo = parsed['IFTA_COIN_INFO']
    as List<dynamic>? ??
        parsed['ifta_coin_info'] as List<dynamic>? ??
        [];
    final List<dynamic> rawSearch = parsed['IFTA_COIN_SEARCH']
    as List<dynamic>? ??
        parsed['ifta_coin_search'] as List<dynamic>? ??
        [];

    // 5) Listengrößen ausgeben
    print('rawInfo.length: ${rawInfo.length}');
    print('rawSearch.length: ${rawSearch.length}');

    // 6) endgültige Struktur zurückgeben
    return {
      'ifta_coin_info': rawInfo,
      'ifta_coin_search': rawSearch,
    };
  }
}

