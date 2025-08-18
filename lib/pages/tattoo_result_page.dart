// lib/pages/tattoo_result_page.dart

import 'package:flutter/material.dart';
import '../models/transponder_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class TattooResultPage extends StatefulWidget {
  final String tattooLeft;
  final String tattooRight;

  const TattooResultPage({
    Key? key,
    required this.tattooLeft,
    required this.tattooRight,
  }) : super(key: key);

  @override
  _TattooResultPageState createState() => _TattooResultPageState();
}

class _TattooResultPageState extends State<TattooResultPage> {
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
      final sesid = await SessionManager.instance.getAnonymousSesId();

      final matches = await ApiService.fetchTattooData(
        tattooLeft: widget.tattooLeft.trim(),
        tattooRight: widget.tattooRight.trim(),
        sesid: sesid,
      );

      setState(() {
        _results = matches;
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
    final title = 'Tattoo ${widget.tattooLeft} / ${widget.tattooRight}';

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Fehler: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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