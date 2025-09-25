// lib/pages/tattoo_result_page.dart

import 'package:flutter/material.dart';
import '../models/tattoo_match.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import 'tattoo_detail_page.dart';

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
  List<TattooMatch> _results = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loggedIn = await SessionManager.instance.isLoggedIn;
      final sesid    = await SessionManager.instance.getAnonymousSesId();
      final matches  = await ApiService.fetchTattooMatches(
        tattooLeft: widget.tattooLeft.trim(),
        tattooRight: widget.tattooRight.trim(),
        sesid: sesid,
      );

      setState(() {
        _results    = matches;
        _isLoggedIn = loggedIn;
      });
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Laden: $e';
      });
    } finally {
      setState(() {
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
        body: Center(child: Text(_error!)),
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
          itemBuilder: (context, index) {
            final m = _results[index];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(m.tiername ?? '–'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nur für eingeloggte Nutzer
                  if (_isLoggedIn && m.tierart != null)
                    Text('Tierart: ${m.tierart}'),

                  // ID immer anzeigen
                  //Text('ID: ${m.id}'),

                  // Rasse / Farbe
                  Text('Rasse/Farbe: ${m.rasse ?? '–'} / ${m.farbe ?? '–'}'),

                  const SizedBox(height: 8),

                  // Mehr-Infos-Button
                  ElevatedButton(
                    onPressed: _isLoggedIn
                        ? () {
                      final idString = m.id.toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TattooDetailPage(match: m),
                        ),
                      );
                    }
                        : null,
                    child: const Text('Mehr Infos'),
                  ),

                  // Hinweis, wenn nicht eingeloggt
                  if (!_isLoggedIn)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Login erforderlich für mehr Infos.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
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