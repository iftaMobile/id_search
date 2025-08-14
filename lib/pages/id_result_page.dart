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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1) Hol Session-ID
      final sesid = await SessionManager.instance.getSesId(
        username: 'apiuser',           // deine echten Credentials
        password: 'geheimesPasswort',  // deine echten Credentials
      );

      // 2) Abruf der IFTA-Daten
      final data = await ApiService.fetchIftaData(
        coin: widget.coin.trim(),
        sesid: sesid,
      );

      // 3) Parsen der beiden Listen
      final infoJsonList = data['ifta_coin_info'] as List<dynamic>;
      final searchJsonList = data['ifta_coin_search'] as List<dynamic>;

      final infoList = infoJsonList
          .map((e) => CoinInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      final searchList = searchJsonList
          .map((e) => CoinSearch.fromJson(e as Map<String, dynamic>))
          .toList();

      // 4) State aktualisieren
      setState(() {
        _info = infoList.isNotEmpty ? infoList.first : null;
        _searchResults = searchList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('IFTA Coin ${widget.coin}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const Text(
              'Search Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Wenn keine Ergebnisse, Hinweis anzeigen…
            if (_searchResults.isEmpty)
              const Expanded(
                child: Center(child: Text('No search results found.')),
              )
            else
            // … sonst ListView
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
                          Text('Tel Nummer: ${item.telefonPriv.isNotEmpty ? item.telefonPriv : '–'}'),
                          Text('Halter: ${item.haltername.isNotEmpty ? item.haltername : '–'}'),
                          Text('Transponder: ${item.transponder ?? '–'}'),
                          Text('${item.rasse ?? '–'}, ${item.farbe ?? '–'}'),
                          Text('Born: ${item.geburt ?? '–'}'),
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