// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/coin_info.dart';
import '../models/coin_search.dart';
import '../models/transponder_match.dart';
import '../models/tattoo_match.dart';

/// Simple holder for login results
class LoginResult {
  final String sesid;
  final String? adrId;

  LoginResult({ required this.sesid, this.adrId });
}

class ApiService {
  static const String _baseMobApp = 'https://www.tierregistrierung.de/mob_app';

  /// 1) Login → Session-ID (+ optional adr_id if your API returns it)
  static Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseMobApp/ifta_login.php').replace(
      queryParameters: {
        'tag':      'login',
        'uname':    username,
        'password': password,
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Login failed: ${resp.statusCode}');
    }

    final dynamic payload = json.decode(resp.body);

    late Map<String, dynamic> map;
    if (payload is List && payload.isNotEmpty && payload.first is Map) {
      map = Map<String, dynamic>.from(payload.first as Map);
    } else if (payload is Map) {
      map = Map<String, dynamic>.from(payload);
    } else {
      throw Exception('Unexpected login response format: ${payload.runtimeType}');
    }

    final sesid = map['sesid'] as String?;
    if (sesid == null) {
      throw Exception('No sesid in response: ${resp.body}');
    }

    // If your login JSON also carries adr_id, grab it here:
    final adrId = map['adr_id']?.toString();

    return LoginResult(sesid: sesid, adrId: adrId);
  }

  /// 1b) If login doesn’t return adr_id, call this after you have a valid sesid
  static Future<String> fetchAdrId({ required String sesid }) async {
    final raw = await fetchCustomerData(sesid: sesid, adrId: '0');

    // Roh-Antwort prüfen
    debugPrint('🔍 [fetchAdrId] raw JSON: ${jsonEncode(raw)}');

    final matches = (raw['IFTA_MATCH'] as List<dynamic>?) ?? [];
    debugPrint('🔢 [fetchAdrId] IFTA_MATCH count: ${matches.length}');
    if (matches.isEmpty) {
      throw Exception('Keine Einträge in IFTA_MATCH, adrId unbekannt');
    }

    final firstMatch = (matches.first as Map<dynamic, dynamic>)
        .cast<String, dynamic>();
    debugPrint('🗂️ [fetchAdrId] firstMatch keys: ${firstMatch.keys}');
    final adrId = firstMatch['adr_id']?.toString();
    debugPrint('🏷️ [fetchAdrId] extrahiertes adr_id: $adrId');

    if (adrId == null || adrId.isEmpty) {
      throw Exception('adr_id nicht gefunden in IFTA_MATCH[0]');
    }

    return adrId;
  }



  /// 2) IFTA-Coin-Daten (Info + Trefferliste)
  static Future<Map<String, dynamic>> fetchIftaData({
    required String coin,
    required String sesid,
  }) async {
    final uri = Uri.parse('$_baseMobApp/jiftacoins.php').replace(
      queryParameters: {
        'coin':  coin,
        'sesid': sesid,
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Server error: ${resp.statusCode}');
    }
    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    return {
      'ifta_coin_info':   decoded['IFTA_COIN_INFO']   as List<dynamic>? ?? [],
      'ifta_coin_search': decoded['IFTA_COIN_SEARCH'] as List<dynamic>? ?? [],
    };
  }

  static List<CoinInfo> parseCoinInfoList(List<dynamic> jsonList) =>
      jsonList.cast<Map<String, dynamic>>().map(CoinInfo.fromJson).toList();

  static List<CoinSearch> parseCoinSearchList(List<dynamic> jsonList) =>
      jsonList.cast<Map<String, dynamic>>().map(CoinSearch.fromJson).toList();

  /// Device-ID helper
  static Future<String> getDeviceId() => _getDeviceId();
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
    } catch (_) {}
    return 'flutter-unknown-device-id';
  }

  /// Transponder-Suche
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
    (m.transponder?.isNotEmpty == true) ||
        (m.haltername?.isNotEmpty   == true) ||
        (m.tiername?.isNotEmpty     == true))
        .toList();
  }

  /// Tattoo-Suche
  static Future<List<TattooMatch>> fetchTattooMatches({
    required String tattooLeft,
    required String tattooRight,
    required String sesid,
  }) async {
    final uri = Uri.parse('$_baseMobApp/jtatoosresults2.php').replace(
      queryParameters: {
        'tatol': tattooLeft,
        'tator': tattooRight,
        'limit': '50',
        'sesid': sesid,
      },
    );
    final resp = await http.post(uri);
    if (resp.statusCode != 200) {
      throw Exception('Tattoo request failed: ${resp.statusCode}');
    }
    final rawList = (json.decode(resp.body) as Map<String, dynamic>);
    final data = (rawList['results'] ?? rawList['IFTA_MATCH'] ?? []) as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(TattooMatch.fromJson).toList();
  }

  /// 5) Kundendaten/Profile
  static Future<Map<String, dynamic>> fetchCustomerData({
    required String sesid,
    required String adrId,
  }) async {
    final imei = await _getDeviceId();
    final uri = Uri.parse('$_baseMobApp/search_ifta_japp.php').replace(
      queryParameters: {
        'tag':    'search',
        'imei':   imei,
        'sesid':  sesid,
        'adr_id': adrId,
      },
    );

    // <<-- ADD THESE LINES
    debugPrint('🔍 [API] GET $uri');

    final resp = await http.get(uri);

    debugPrint('📥 [API] Status code: ${resp.statusCode}');
    debugPrint('📄 [API] Response body:\n${resp.body}');
    // -->> END ADD

    if (resp.statusCode != 200) {
      throw Exception('Kundendaten-Request fehlgeschlagen: ${resp.statusCode}');
    }

    return json.decode(resp.body) as Map<String, dynamic>;
  }
}