import 'dart:convert';
import 'package:flutter/foundation.dart';         // for debugPrint
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser; // add in pubspec.yaml: html: ^0.15.0

class TierService {
  /// (1a) Transponder suchen – bleibt unverändert
  Future<bool> searchTransponder(String transponderId) async {
    final uri = Uri.parse(
        'https://www.tierregistrierung.de/api/transponder'
            '?tag=search&transponder=$transponderId'
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    debugPrint('🔍 SEARCH → $uri → status=${res.statusCode}');
    return res.statusCode == 200 && res.body.contains('found');
  }

  /// (1b) Hidden-Formulardaten holen mit echtem HTML-Parser
  Future<Map<String,String>> _fetchFormData(int tierId) async {
    final uri = Uri.parse(
        'https://www.tierregistrierung.de/index.php'
            '?module=if_tiere&func=otherpet'
            '&tier_id=$tierId&other_dbs=1'
    );
    final res = await http.get(uri);
    final html = res.body;

    // Debug: schau dir die ersten 300 Zeichen an
    debugPrint('❗️DEBUG: Form page HTML →\n${html.substring(0, 300)}…');

    // parse das HTML
    final document = htmlParser.parse(html);

    // helper, zieht den value-Attribut von <input name="…">
    String extract(String name) {
      final el = document.querySelector('input[name="$name"]');
      return el?.attributes['value'] ?? '';
    }

    return {
      'authid':               extract('authid'),
      'EZComments_redirect':  extract('EZComments_redirect'),
      'EZComments_modname':   extract('EZComments_modname'),
      'EZComments_objectid':  extract('EZComments_objectid'),
    };
  }

  /// (1c) Kommentar posten
  Future<bool> postFinderComment({
    required int tierId,
    required String finderPhone,
  }) async {
    // 1) hol dir die Form-Daten
    final formData = await _fetchFormData(tierId);

    // 2) prüfe, ob wir wirklich Werte bekommen haben
    debugPrint('❗️DEBUG: Extracted formData → $formData');

    // 3) baue Kommentartext
    final commentText = 'telnr1 Finder.: $finderPhone';

    // 4) bereite body vor
    final body = {
      'authid':              formData['authid']!,
      'EZComments_redirect': formData['EZComments_redirect']!,
      'EZComments_modname':  formData['EZComments_modname']!,
      'EZComments_objectid': formData['EZComments_objectid']!,
      'EZComments_comment':  commentText,
    };

    // 5) Ziel-URI
    final uri = Uri.parse(
        'https://www.tierregistrierung.de/index.php'
            '?module=EZComments&func=create'
    );

    // 6) Debug-Print URL & Body
    debugPrint('❗️DEBUG: POST Comment to → $uri');
    debugPrint('❗️DEBUG: Body → $body');

    // 7) abschicken
    final res = await http.post(
      uri,
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body,
    );

    debugPrint('❗️DEBUG: POST-Response status=${res.statusCode}');
    return res.statusCode == 302 || res.statusCode == 200;
  }
}