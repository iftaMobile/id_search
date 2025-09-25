// lib/pages/id_result_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../models/coin_info.dart';
import '../models/coin_search.dart';

class IdResultPage extends StatefulWidget {
  final String coin;

  const IdResultPage({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  _IdResultPageState createState() => _IdResultPageState();
}

class _IdResultPageState extends State<IdResultPage> {
  CoinInfo? _info;
  List<CoinSearch> _searchResults = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Prüfe, ob der User eingeloggt ist
      final loggedIn = await SessionManager.instance.isLoggedIn;

      // 2) Wähle das richtige Session-ID-Token
      final sesid = loggedIn
          ? (await SessionManager.instance.storedSesId)!
          : await SessionManager.instance.getAnonymousSesId();

      // 3) Hole die IFTA-Daten
      final data = await ApiService.fetchIftaData(
        coin: widget.coin.trim(),
        sesid: sesid,
      );

      // 4) Guarded JSON-Zugriff
      final rawInfo = data['ifta_coin_info'];
      final rawSearch = data['ifta_coin_search'];

      final infoJsonList = rawInfo is List ? rawInfo : <dynamic>[];
      final searchJsonList = rawSearch is List ? rawSearch : <dynamic>[];

      // 5) Sichere Deserialisierung
      final infoList = infoJsonList
          .whereType<Map<String, dynamic>>()
          .map(CoinInfo.fromJson)
          .toList();

      final searchList = searchJsonList
          .whereType<Map<String, dynamic>>()
          .map(CoinSearch.fromJson)
          .toList();

      // 6) State updaten
      setState(() {
        _info = infoList.isNotEmpty ? infoList.first : null;
        _searchResults = searchList;
        _isLoggedIn = loggedIn;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden: $e';
      });
    } finally {
      setState(() {
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

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('IFTA Coin ${widget.coin}')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('IFTA Coin ${widget.coin}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anzeige der CoinInfo (falls vorhanden)
            if (_info != null) ...[
              Text(
                'Device: ${_info!.device}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Connected: ${_info!.tierConnected}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 32),
            ] else ...[
              const Text(
                'No info available.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const Divider(height: 32),
            ],

            // Suchergebnisse
            const Text(
              'Search Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_searchResults.isEmpty)
              const Expanded(
                child: Center(child: Text('No search results found.')),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final item = _searchResults[i];
                    return ListTile(
                      title: Text(item.tiername ?? '–'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Telefonnummer immer anzeigen
                          Text('Tel Nummer: ${item.telefonPriv.isNotEmpty ? item.telefonPriv : '–'}',),
                          // Rest der Felder nur für eingeloggte User
                          if (_isLoggedIn) ...[
                            Text('Halter: ${item.haltername.isNotEmpty ? item.haltername : '–'}',),
                            Text('Transponder: ${item.transponder ?? '–'}',),
                            Text('Adresse: ${item.strasse ?? '–'}',),
                            Text('Ort: ${item.ort ?? '–'}',),
                          ] else ...[
                            // Hinweis für anonyme User
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Weitere Details nach Login sichtbar.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
