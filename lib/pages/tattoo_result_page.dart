// lib/pages/tattoo_result_page.dart

import 'package:flutter/material.dart';
import '../models/tattoo_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class TattooResultPage extends StatefulWidget {
  final String tattoo;
  const TattooResultPage({Key? key, required this.tattoo}) : super(key: key);

  @override
  _TattooResultPageState createState() => _TattooResultPageState();
}

class _TattooResultPageState extends State<TattooResultPage> {
  List<TattooMatch> _results = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sesid = await SessionManager.instance.getSesId(
        username: 'apiuser',
        password: 'geheimesPasswort',
      );
      final list = await ApiService.fetchTattooData(
        tattoo: widget.tattoo,
        sesid: sesid,
      );
      setState(() {
        _results = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Tattoo ${widget.tattoo}')),
        body: Center(child: Text('Fehler: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Tattoo ${widget.tattoo}')),
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
                  Text('Tattoo: ${m.tattoo ?? '–'}'),
                  Text('Halter: ${m.haltername ?? '–'}'),
                  Text('Tel: ${m.telefonPriv ?? '–'}'),
                  Text('Rasse/Farbe: ${m.rasse ?? '–'}, ${m.farbe ?? '–'}'),
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