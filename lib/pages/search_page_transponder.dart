// lib/pages/transponder_search_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_manager.dart';
import 'transponder_result_page.dart';

class TransponderSearchPage extends StatefulWidget {
  const TransponderSearchPage({Key? key}) : super(key: key);

  @override
  _TransponderSearchPageState createState() => _TransponderSearchPageState();
}

class _TransponderSearchPageState extends State<TransponderSearchPage> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  // ← Initialized immediately, no late init error
  final http.Client _httpClient = http.Client();

  @override
  void dispose() {
    _controller.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<String?> _loadSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sesid');
  }

  Future<String?> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPhone');
  }

  Future<String?> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _sendFinderNumber(String phone) async {
    final uri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/jwwdblog.php'
          '?tag=log&phone=$phone',
    );
    final resp = await _httpClient.get(
      uri,
      headers: {'User-Agent': 'Mozilla/5.0 (FlutterApp)'},
    );
    debugPrint('🔐 Log-Response: ${resp.statusCode}, Body: ${resp.body}');
  }

  Future<String> _postCommentMobile({
    required String finderName,
    required String primaryNumber,
    required String query,
    required String commentText,
    required String imei,
    required String sessionId,
    String? tag,
  }) async {
    final uri = Uri.parse(
      'https://www.tierregistrierung.de/mob_app/jgetcomments.php',
    );

    // Basis-Body
    final body = <String, String>{
      'name': finderName,
      'number': primaryNumber,
      'various': commentText,
      'imei': imei,
      'sesid': sessionId,
      if (tag != null) 'tag': tag,
    };

    // Dynamischen Key hinzufügen
    final key = (query.length == 15)
        ? 'transponder'
        : (query.length == 8 ? 'iftaid' : 'id');
    body[key] = query;

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

  Future<void> _onSearch() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Bitte einen Transponder-Code eingeben.');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      // 1) Telefonnummer + Username/FinderName
      final phone = await _loadPhoneNumber();
      if (phone == null || phone.isEmpty) {
        throw Exception('Keine Telefonnummer gespeichert.');
      }
      final username = await _loadUsername();
      final finderName = (username?.isNotEmpty == true) ? username! : phone;

      // 2) Logge Finder-Nummer
      await _sendFinderNumber(phone);

      // 3) Session-ID: stored OR anonymous fallback
      var sessionId = await _loadSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        sessionId = await SessionManager.instance.getAnonymousSesId();
      }

      // 4) Kommentar posten
      final commentText = '$finderName hat Transponder $code gefunden';
      await _postCommentMobile(
        finderName: finderName,
        primaryNumber: phone,
        query: code,
        commentText: commentText,
        imei: 'BP22.250325.006',
        sessionId: sessionId,
        tag: 'addComment',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kommentar erfolgreich gepostet')),
      );

      // 5) Weiter zum Ergebnis
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
                    hintText: 'z.B. 000123456789012',
                    errorText: _errorText,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _onSearch,
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