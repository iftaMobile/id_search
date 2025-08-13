import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// 1) Login
  ///
  /// Calls ifta_login.php?tag=login&uname=…&password=…
  /// Handles both Array- and Object-root JSON.
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
      throw Exception('Login failed: ${resp.statusCode}');
    }

    // Decode the JSON, which may be an Array or an Object
    final dynamic payload = json.decode(resp.body);
    late Map<String, dynamic> map;
    if (payload is List && payload.isNotEmpty && payload.first is Map) {
      map = Map<String, dynamic>.from(payload.first as Map);
    } else if (payload is Map) {
      map = Map<String, dynamic>.from(payload);
    } else {
      throw Exception('Unexpected login response format: ${payload.runtimeType}');
    }

    final sesid = map['sesid'];
    if (sesid == null || sesid is! String) {
      throw Exception('No sesid in response: ${resp.body}');
    }
    return sesid;
  }

  /// 2) fetchIftaData
  ///
  /// Calls jiftacoins.php?coin=…&sesid=…
  /// Extracts the two lists under the uppercase keys
  /// and re-exports them as lowercase keys for your UI code.
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
      throw Exception('Server error: ${resp.statusCode}');
    }

    // Decode into a Map directly (your JSON root is an Object)
    final Map<String, dynamic> decoded =
    json.decode(resp.body) as Map<String, dynamic>;

    // Pull out the uppercase keys
    final rawInfo = decoded['IFTA_COIN_INFO']   as List<dynamic>? ?? [];
    final rawSearch = decoded['IFTA_COIN_SEARCH'] as List<dynamic>? ?? [];

    // Return them under lowercase keys your UI expects:
    return {
      'ifta_coin_info':   rawInfo,
      'ifta_coin_search': rawSearch,
    };
  }
}