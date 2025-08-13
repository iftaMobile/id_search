import 'package:flutter/material.dart';
import 'ifta_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _coinController  = TextEditingController();
  final _sesidController = TextEditingController();

  void _onSearch() {
    final coin  = _coinController.text.trim();
    final sesid = _sesidController.text.trim();

    if (coin.isEmpty || sesid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte beide Felder ausfüllen.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IftaResultPage(coin: coin),
      ),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    _sesidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transponder-Suche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _coinController,
              decoration: const InputDecoration(
                labelText: 'Transponder (coin)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sesidController,
              decoration: const InputDecoration(
                labelText: 'Session-ID (sesid)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSearch,
              child: const Text('Suchen'),
            ),
          ],
        ),
      ),
    );
  }
}