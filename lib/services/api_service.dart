// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import '../models/coin_info.dart';
import '../models/coin_search.dart';
import '../models/transponder_match.dart';
import '../models/tattoo_match.dart';

class ApiService {
  static const String _baseMobApp = 'https://www.tierregistrierung.de/mob_app';
  static const String _baseExact  = 'https://www.tierregistrierung.de/tier_search2';

  /// 1) Login → Session-ID
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

  /// 2) IFTA-Coin-Daten (Info + Trefferliste)
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


  static List<CoinInfo> parseCoinInfoList(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map(CoinInfo.fromJson).toList();
  }

  static List<CoinSearch> parseCoinSearchList(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map(CoinSearch.fromJson).toList();
  }

  /// 3a) Öffentliches Device-ID API (wrapper für _getDeviceId)
  static Future<String> getDeviceId() => _getDeviceId();

  /// 3b) Geräte-ID (ANDROID_ID bzw. identifierForVendor)
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
      // fallback
    }
    return 'flutter-unknown-device-id';
  }

  /// 4a) Transponder-Suche (mob_app)
  static Future<List<TransponderMatch>> fetchTransponderData({
    required String transponder,
    required String sesid,
  }) async {
    final imei = await _getDeviceId();
    final uri = Uri.parse('$_baseMobApp/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':         'search',
        'transponder': transponder,
        'imei':        imei,
        'sesid':       sesid,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Transponder request failed: ${resp.statusCode}');
    }

    final raw      = json.decode(resp.body) as Map<String, dynamic>;
    final listJson = raw['IFTA_MATCH'] as List<dynamic>? ?? [];
    return listJson
        .cast<Map<String, dynamic>>()
        .map(TransponderMatch.fromJson)
        .where((m) =>
    m.transponder?.isNotEmpty == true ||
        m.haltername?.isNotEmpty   == true ||
        m.tiername?.isNotEmpty     == true)
        .toList();
  }

  /// 4b) Tattoo-Suche (mob_app)
  ///     liefert dbid/qid, falls vorhanden (ansonsten leere Liste)
  static Future<List<TattooMatch>> fetchTattooData({
    required String tattoo,
    required String sesid,
  }) async {
    final imei = await _getDeviceId();
    final uri = Uri.parse('$_baseMobApp/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':         'search',
        'transponder': tattoo, // ✅ use 'transponder' instead of 'tattoo'
        'imei':        imei,
        'sesid':       sesid,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Tattoo request failed: ${resp.statusCode}');
    }

    final raw      = json.decode(resp.body) as Map<String, dynamic>;
    final listJson = raw['IFTA_MATCH'] as List<dynamic>? ?? [];
    return listJson
        .cast<Map<String, dynamic>>()
        .map(TattooMatch.fromJson)
        .where((m) =>
    m.dbid?.isNotEmpty == true && m.qid?.isNotEmpty == true)
        .toList();
  }

  /// 5a) Exakte Transponder-Abfrage (tier_search2)
  static Future<List<TransponderMatch>> fetchExactTransponder({
    required String dbid,
    required String qid,
    required String transponder,
  }) async {
    final uri = Uri.parse('$_baseExact/wwdb_exact.php').replace(
      queryParameters: {
        'dbid':        dbid,
        'qid':         qid,
        'transponder': transponder,
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Exact transponder request failed: ${resp.statusCode}');
    }

    final raw      = json.decode(resp.body) as Map<String, dynamic>;
    final listJson = raw['IFTA_MATCH'] as List<dynamic>? ?? [];
    return listJson
        .cast<Map<String, dynamic>>()
        .map(TransponderMatch.fromJson)
        .where((m) =>
    m.transponder?.isNotEmpty == true ||
        m.haltername?.isNotEmpty   == true ||
        m.tiername?.isNotEmpty     == true)
        .toList();
  }

  /// 5b) Exakte Tattoo-Abfrage (tier_search2)
  static Future<List<TattooMatch>> fetchExactTattoo({
    required String dbid,
    required String qid,
    required String tattoo,
  }) async {
    final uri = Uri.parse('$_baseExact/wwdb_exact.php').replace(
      queryParameters: {
        'dbid':   dbid,
        'qid':    qid,
        'tattoo': tattoo,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Exact tattoo request failed: ${resp.statusCode}');
    }

    final raw      = json.decode(resp.body) as Map<String, dynamic>;
    final listJson = raw['IFTA_MATCH'] as List<dynamic>? ?? [];

    return listJson
        .cast<Map<String, dynamic>>()
        .map(TattooMatch.fromJson)
        .where((m) =>
    (m.tattoo?.isNotEmpty == true) ||
        (m.haltername?.isNotEmpty == true) ||
        (m.tiername?.isNotEmpty == true))
        .toList();
  }

}