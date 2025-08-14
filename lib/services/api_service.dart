// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import '../models/coin_info.dart';
import '../models/coin_search.dart';
import '../models/transponder_match.dart';
import '../models/tattoo_match.dart';

class ApiService {
  static const _baseUrl = 'https://www.tierregistrierung.de/mob_app';
  static const _base = 'https://www.tierregistrierung.de/mob_app';


  /// Authentifiziert und gibt eine Session-ID zurück
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login.php').replace(
      queryParameters: {
        'user': username,
        'pw':   password,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Login failed: ${resp.statusCode}');
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;
    final sesid = body['sesid'] as String?;
    if (sesid == null) {
      throw Exception('Login response contains no sesid');
    }

    return sesid;
  }

  /// Holt die IFTA-Coin-Daten (Info + Trefferliste)
  static Future<Map<String, dynamic>> fetchIftaData({
    required String coin,
    required String sesid,
  }) async {
    final uri = Uri.parse('$_baseUrl/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':    'credit',
        'credit': coin,
        'sesid':  sesid,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('IFTA Coin request failed: ${resp.statusCode}');
    }

    return json.decode(resp.body) as Map<String, dynamic>;
  }

  /// Parsed die IFTA-Coin-Info-Liste
  static List<CoinInfo> parseCoinInfoList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map(CoinInfo.fromJson)
        .toList();
  }

  /// Parsed die IFTA-Coin-Search-Liste
  static List<CoinSearch> parseCoinSearchList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map(CoinSearch.fromJson)
        .toList();
  }

  // ----------------------- Transponder-Methoden -----------------------

  /// Liefert eine Geräte-ID (Android-ID oder iOS identifierForVendor)
  static Future<String> _getDeviceId() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return info.id ?? 'flutter-unknown-android-id';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.identifierForVendor ?? 'flutter-unknown-ios-id';
      }
    } catch (_) {
      // Falls irgendwas schiefgeht
    }
    return 'flutter-unknown-device-id';
  }

  /// Holt und parsed das IFTA_MATCH-Array in eine Liste von TransponderMatch
  static Future<List<TransponderMatch>> fetchTransponderData({
    required String transponder,
    required String sesid,
  }) async {
    final deviceId = await _getDeviceId();

    final uri = Uri.parse('$_baseUrl/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':         'search',
        'transponder': transponder,
        'imei':        deviceId,
        'sesid':       sesid,
      },
    );

    // Debug-Logging
    print('→ Transponder-Request: $uri');

    final resp = await http.get(uri);
    print('← Status: ${resp.statusCode}');
    print('← Body: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Transponder request failed: ${resp.statusCode}');
    }

    final raw = json.decode(resp.body) as Map<String, dynamic>;
    final listJson = raw['IFTA_MATCH'] as List<dynamic>? ?? [];

    return listJson
        .cast<Map<String, dynamic>>()
        .map(TransponderMatch.fromJson)
    // Filtert Platzhalter-Einträge mit nur null-Feldern heraus
        .where((m) =>
    m.transponder?.isNotEmpty == true ||
        m.haltername?.isNotEmpty == true ||
        m.tiername?.isNotEmpty == true)
        .toList();
  }

  // static Future<String> _getDeviceId() async {
  //   final plugin = DeviceInfoPlugin();
  //   try {
  //     if (Platform.isAndroid) {
  //       final info = await plugin.androidInfo;
  //       return info.id ?? 'flutter-unknown-android-id';
  //     } else if (Platform.isIOS) {
  //       final info = await plugin.iosInfo;
  //       return info.identifierForVendor ?? 'flutter-unknown-ios-id';
  //     }
  //   } catch (_) {}
  //   return 'flutter-unknown-device-id';
  // }

  /// “Tattoo”-Suche analog zur Transponder-Suche
  static Future<List<TattooMatch>> fetchTattooData({
    required String tattoo,
    required String sesid,
  }) async {
    final deviceId = await _getDeviceId();

    // WICHTIG: passe das `tag`-Feld an deine API-Doku an
    final uri = Uri.parse('$_base/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':    'searchTattoo', // oder: 'tattoo', je nach API
        'tattoo': tattoo,
        'imei':   deviceId,
        'sesid':  sesid,
      },
    );

    print('→ Tattoo-Request: $uri');
    final resp = await http.get(uri);
    print('← Status: ${resp.statusCode}');
    print('← Body: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Tattoo-Request failed: ${resp.statusCode}');
    }

    final raw     = json.decode(resp.body) as Map<String, dynamic>;
    final listKey = raw.containsKey('TATTOO_MATCH')
        ? 'TATTOO_MATCH'
        : raw.containsKey('IFTA_MATCH')
        ? 'IFTA_MATCH'
        : null;

    if (listKey == null) return [];

    final jsonList = raw[listKey] as List<dynamic>? ?? [];
    return jsonList
        .cast<Map<String, dynamic>>()
        .map(TattooMatch.fromJson)
    // filter “null”-Platzhalter raus
        .where((m) =>
    m.tattoo?.isNotEmpty == true ||
        m.haltername?.isNotEmpty == true ||
        m.tiername?.isNotEmpty == true)
        .toList();
  }

}