import 'dart:io';
import 'dart:convert';        // für latin1.decoder / utf8.decoder
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'transponder_result_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TransponderSearchPage extends StatefulWidget {
  const TransponderSearchPage({Key? key}) : super(key: key);

  @override
  _TransponderSearchPageState createState() => _TransponderSearchPageState();
}

class _TransponderSearchPageState extends State<TransponderSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  Future<String?> _loadSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sesid');
  }



  // HttpClient mit Zertifikat-Callback, aber keine Cookie-Persistierung
  late final http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
  }

  @override
  void dispose() {
    _controller.dispose();
    _httpClient.close();    // <-- schließe den Client
    super.dispose();
  }

  // 1) Logge die Finder-Telefonnummer (wie jwwdblog.php es erwartet)
  Future<void> _sendFinderNumber(String phone) async {
    final uri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/jwwdblog.php'
          '?tag=log&phone=$phone',
    );
    final resp = await _httpClient.get(
      uri,
      headers: {
        'User-Agent': 'Mozilla/5.0 (FlutterApp)',
      },
    );
    debugPrint('🔐 Log-Response: ${resp.statusCode}, Body: ${resp.body}');
  }

  Future<String?> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('userPhone');  // statt 'phone_number'
    debugPrint('Geladene Telefonnummer: $phone');
    return phone;
  }



  // Ersetze deine bestehende _onSearch()-Methode in _TransponderSearchPageState komplett durch diesen Block:

  /// Wird aufgerufen, wenn der Nutzer auf "Suchen" drückt
  void _onSearch() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Bitte einen Transponder-Code eingeben');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;  // Spinner anzeigen
    });

    try {
      // 1) Telefonnummer aus SharedPreferences holen
      final phone = await _loadPhoneNumber();
      if (phone == null || phone.isEmpty) {
        throw Exception('Keine Telefonnummer gespeichert');
      }

      // 2) Finder-Log an jwwdblog.php senden
      await _sendFinderNumber(phone);

      // 3) Session-ID aus SharedPreferences holen
      final sessionId = await _loadSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Keine Session-ID gefunden');
      }

      // 4) Kommentar-Text bauen
      final commentText = 'Finder‐Nummer $phone hat Transponder $code gefunden';

      // 5) Kommentar über den mobilen Endpoint abschicken
      final result = await _postCommentMobile(
        finderName: phone,
        primaryNumber: phone,
        query: code,
        commentText: commentText,
        imei: 'BP22.250325.006',  // dieselbe IMEI wie bei der Transponder-Suche
        sessionId: sessionId,
        tag: 'addComment',        // falls serverseitig notwendig
      );
      debugPrint('📱 jgetcomments.php-Antwort: $result');

      // 6) Erfolg im UI anzeigen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kommentar erfolgreich gepostet')),
      );

      // 7) Zur Result-Page navigieren
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransponderResultPage(transponder: code),
        ),
      );
    } catch (e) {
      debugPrint('❌ Fehler in _onSearch(): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      setState(() => _isLoading = false);  // Spinner ausblenden
    }
  }


  // Schritt A: Tier-Detail-Seite laden und authid extrahieren
  Future<String> _postCommentMobile({
    required String finderName,
    required String primaryNumber,
    String? secondaryNumber,
    required String query,
    required String commentText,
    required String imei,
    required String sessionId,
    double latitude = 0,
    double longitude = 0,
    String email = 'null',
    String? tag,            // optional
  }) async {
    final uri = Uri.parse('https://www.tierregistrierung.de/mob_app/jgetcomments.php');

    // DEBUG: Body loggen
    final body = <String, String>{
      'name': finderName,
      'various': commentText,
      'number': primaryNumber,
      if (secondaryNumber != null) 'number2': secondaryNumber,
      'imei': imei,
      'email': email,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),

      // WICHTIG:
      'sesid': sessionId,
      if (tag != null) 'tag': tag,

      // Transponder/IFTA/DB-ID
      if (query.length == 15) 'transponder': query
      else if (query.length == 8) 'iftaid': query
      else 'id': query,
    };
    debugPrint('🔍 POST jgetcomments.php → Body: $body');

    final resp = await _httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'Mozilla/5.0 (FlutterApp)',
      },
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception('Mobile-Post-Fehler: ${resp.statusCode}');
    }
    return resp.body;
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transponder-Suche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Transponder-Code',
                    errorText: _errorText,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _onSearch(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Suchen'),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black38,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),

      ),
    );
  }
}


