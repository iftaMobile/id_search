import 'package:flutter/material.dart';

import '../models/tattoo_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class TattooResultPage extends StatefulWidget {
  final String leftTattoo;
  final String rightTattoo;

  const TattooResultPage({
    Key? key,
    required this.leftTattoo,
    required this.rightTattoo,
  }) : super(key: key);

  @override
  _TattooResultPageState createState() => _TattooResultPageState();
}

class _TattooResultPageState extends State<TattooResultPage> {
  List<TattooMatch> _leftResults = [];
  List<TattooMatch> _rightResults = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Combines initial + exact tattoo lookup
  Future<List<TattooMatch>> _fetchFullTattoo(String code, String sesid) async {
    try {
      final initial = await ApiService.fetchTattooData(
        tattoo: code,
        sesid: sesid,
      );

      if (initial.isEmpty || initial.first.dbid == null || initial.first.qid == null) {
        return [];
      }

      return await ApiService.fetchExactTattoo(
        dbid: initial.first.dbid!,
        qid: initial.first.qid!,
        tattoo: code,
      );
    } catch (e) {
      debugPrint('Tattoo fetch failed for $code: $e');
      return [];
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sesid = await SessionManager.instance.getSesId(
        username: 'apiuser',
        password: 'geheimesPasswort',
      );

      final results = await Future.wait<List<TattooMatch>>([
        widget.leftTattoo.isNotEmpty
            ? _fetchFullTattoo(widget.leftTattoo, sesid)
            : Future.value(<TattooMatch>[]),
        widget.rightTattoo.isNotEmpty
            ? _fetchFullTattoo(widget.rightTattoo, sesid)
            : Future.value(<TattooMatch>[]),
      ]);

      setState(() {
        _leftResults = results[0];
        _rightResults = results[1];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildSection(String title, List<TattooMatch> list) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text('$title\nKein Eintrag gefunden')),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final m = list[i];
                return ListTile(
                  title: Text(m.tiername ?? '–'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tattoo: ${m.tattoo ?? '–'}'),
                      Text('Halter: ${m.haltername ?? '–'}'),
                      Text('Tel (privat): ${m.telefonPriv ?? '–'}'),
                      Text('Rasse/Farbe: ${m.rasse ?? '–'} / ${m.farbe ?? '–'}'),
                      Text('Geboren: ${m.geburt ?? '–'}'),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: const Text('Tattoo-Ergebnis')),
        body: Center(child: Text('Fehler: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tattoo-Ergebnis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.leftTattoo.isNotEmpty)
              _buildSection('Linkes Ohr: ${widget.leftTattoo}', _leftResults),
            if (widget.rightTattoo.isNotEmpty)
              _buildSection('Rechtes Ohr: ${widget.rightTattoo}', _rightResults),
          ],
        ),
      ),
    );
  }
}