import 'dart:io';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:convert';

class CommentService {
  final HttpClient _client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  /// 1) GET holen, Cookies setzen und authid extrahieren
  Future<String> _fetchAuthId() async {
    final uri = Uri.parse('https://www.tierregistrierung.de/index.php?module=EZComments&func=create&EZComments_modname=if_tiere&EZComments_objectid=415040');
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(const Utf8Decoder()).join();

    // HTML parsen
    final document = parse(body);
    final input = document.querySelector('input[name="authid"]') as Element?;
    if (input == null) {
      throw Exception('authid nicht gefunden');
    }
    return input.attributes['value'] ?? '';
  }

  /// 2) Kommentar per POST senden
  Future<void> postComment({
    required String transponder,
    required String telefon,
    required String kommentarText,
  }) async {
    final authId = await _fetchAuthId();

    // Request aufbauen
    final uri = Uri.parse('https://www.tierregistrierung.de/index.php?module=EZComments&func=create');
    final request = await _client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');

    // Body zusammenbauen
    final formData = {
      'authid': authId,
      'EZComments_redirect': 'https://www.tierregistrierung.de/index.php?module=if_tiere&func=otherpet&tier_id=415040&other_dbs=1',
      'EZComments_modname': 'if_tiere',
      'EZComments_objectid': '415040',
      'transponder': transponder,
      'telefon_finder': telefon,
      'kommentar': kommentarText,
      'status': 'offen',
    };
    final body = formData.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    request.write(body);
    final response = await request.close();

    print('🔵 POST-Status: ${response.statusCode}');
    final location = response.headers.value('location');
    if (location != null) print('🔴 Redirect nach: $location');

    if (response.statusCode != 200) {
      throw Exception('Kommentar fehlgeschlagen (${response.statusCode})');
    }

    final respBody = await response.transform(const Utf8Decoder()).join();
    print('✅ Kommentar erfolgreich, Antwort:\n$respBody');
  }
}