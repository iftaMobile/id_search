// lib/pages/transponder_result_page.dart

import 'package:flutter/material.dart';
import '../models/transponder_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TransponderResultPage extends StatefulWidget {
  final String transponder;

  const TransponderResultPage({
    Key? key,
    required this.transponder,
  }) : super(key: key);

  @override
  _TransponderResultPageState createState() => _TransponderResultPageState();
}

class _TransponderResultPageState extends State<TransponderResultPage> {
  List<TransponderMatch> _results = [];
  bool _isLoading = true;
  String? _error;

  Future<bool> sendFinderNumber(String finderPhone) async {
    // Basis-URL
    const base = 'https://www.tierregistrierung.de/mob_app';
    // Einfach nur tag=log und phone parameter
    final uri = Uri.parse('$base/jwwdblog.php').replace(
      queryParameters: {
        'tag':   'log',
        'phone': finderPhone.trim(),
      },
    );

    // Debug: überprüfe im Log, wie die URL aussieht
    debugPrint('🔐 sendFinderNumber → $uri');
    final res = await http.get(uri);
    debugPrint('🔐 Log-Response: ${res.statusCode}, Body: ${res.body}');
    return res.statusCode == 200;

    // Sende POST (Body bleibt leer, wie in deinem Java-Code)
    final resp = await http.post(uri).timeout(const Duration(seconds: 10));
    return resp.statusCode == 200;
  }

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      // 1) Session-ID holen
      final sesid = await SessionManager.instance.getAnonymousSesId();
      // final sesid = await SessionManager.instance.getSesId(
      //   username: 'apiuser',
      //   password: 'geheimesPasswort',
      // );

      debugPrint('🌐 Anfrage an Server:');
      debugPrint('→ Transponder: ${widget.transponder.trim()}');
      debugPrint('→ Session-ID: $sesid');
      final prefs = await SharedPreferences.getInstance();
      final finderPhone = prefs.getString('userPhone') ?? '';

      // 2) Log-Request VOR der API-Abfrage
      final ok = await sendFinderNumber(finderPhone);
      if (!ok) {
        debugPrint('❌ Log-Request fehlgeschlagen');
        // hier entscheiden: abbrechen oder dennoch weitermachen?
      }


      // 2) Hier das richtige Fetch: liefert List<TransponderMatch>
      final matches = await ApiService.fetchTransponderData(
        transponder: widget.transponder.trim(),
        sesid: sesid,
      );

      setState(() {
        _results = matches;   // matcht List<TransponderMatch>
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Transponder ${widget.transponder}'),
        ),
        body: Center(child: Text('Fehler: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transponder ${widget.transponder}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _results.isEmpty
            ? const Center(child: Text('Kein Eintrag gefunden.'))
            : ListView.separated(
          itemCount: _results.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final m = _results[i];
            return ListTile(
              title: Text(m.tiername ?? '–'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tel: ${m.telefonPriv ?? '–'}'),
                  Text('Halter: ${m.haltername ?? '–'}'),
                  Text(
                    'Rasse/Farbe: ${m.rasse ?? '–'}, ${m.farbe ?? '–'}',
                  ),
                  Text('Geboren: ${m.geburt ?? '–'}'),
                ],
              ),
              isThreeLine: true,
            );
          },
        ),
      ),
    );
  }
}