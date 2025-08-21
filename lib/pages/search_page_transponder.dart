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

  Future<String?> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
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
      _isLoading = true;
    });

    try {
      // 1) Telefonnummer holen
      final phone = await _loadPhoneNumber();
      if (phone == null || phone.isEmpty) {
        throw Exception('Keine Telefonnummer gespeichert');
      }

      // 1a) Username holen & Fallback auf phone
      final username = await _loadUsername();
      final finderName = (username != null && username.isNotEmpty)
          ? username
          : phone;

      debugPrint('🔍 Loaded username: $username');
      debugPrint('🔍 Final finderName: $finderName');


      // 2) Finder-Log senden (bleibt Telefonnummer)
      await _sendFinderNumber(phone);

      // 3) Session-ID holen
      final sessionId = await _loadSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Keine Session-ID gefunden');
      }

      // 5) Kommentar senden – hier mit dem neuen finderName
      final result = await _postCommentMobile(
        finderName: finderName,
        primaryNumber: phone,
        query: code,
        commentText: '$finderName hat Transponder $code gefunden',  // <-- hier dein Username
        imei: 'BP22.250325.006',
        sessionId: sessionId,
        tag: 'addComment',
      );

      debugPrint('📱 jgetcomments.php-Antwort: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kommentar erfolgreich gepostet')),
      );

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
      setState(() => _isLoading = false);
    }
  }


  // Schritt A: Tier-Detail-Seite laden und authid extrahieren
  // 1) Methode um den commentText ergänzen
  Future<String> _postCommentMobile({
    required String finderName,
    required String primaryNumber,
    required String query,
    required String commentText,     // neu!
    required String imei,
    required String sessionId,
    String? tag,
  }) async {
    final uri = Uri.parse('https://www.tierregistrierung.de/mob_app/jgetcomments.php');

    final body = <String, String>{
      'name': finderName,
      'number': primaryNumber,
      'various': commentText,        // <— hier der Kommentar
      'imei': imei,
      'sesid': sessionId,
      if (tag != null) 'tag': tag,
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


