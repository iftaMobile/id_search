// lib/pages/transponder_result_page.dart

import 'package:flutter/material.dart';
import '../models/transponder_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      // 1) Session-ID holen
      final sesid = await SessionManager.instance.getSesId(
        username: 'apiuser',
        password: 'geheimesPasswort',
      );

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