// lib/pages/ifta_result_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/coin_info.dart';
import '../models/coin_search.dart';

class IftaResultPage extends StatefulWidget {
  final String coin;

  const IftaResultPage({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  _IftaResultPageState createState() => _IftaResultPageState();
}

class _IftaResultPageState extends State<IftaResultPage> {
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
      // holt intern die Session-ID und ruft dann den IFTA-Endpoint auf
      final data = await ApiService.fetchIftaData(
        coin: widget.coin,
      );

      final infoList = (data['ifta_coin_info'] as List)
          .map((e) => CoinInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      final searchList = (data['ifta_coin_search'] as List)
          .map((e) => CoinSearch.fromJson(e as Map<String, dynamic>))
          .toList();

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
            _searchResults.isEmpty
                ? const Expanded(
              child: Center(child: Text('No search results found.')),
            )
                : Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final item = _searchResults[i];
                  return ListTile(
                    title: Text(item.tiername),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transponder: ${item.transponder}'),
                        Text('${item.rasse}, ${item.farbe}'),
                        Text('Born: ${item.geburt}'),
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