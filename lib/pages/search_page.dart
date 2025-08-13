// lib/pages/search_page.dart

import 'package:flutter/material.dart';
import 'ifta_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _coinController = TextEditingController();

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final coin = _coinController.text.trim();
    if (coin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Coin-Nummer eingeben.')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin suchen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _coinController,
              decoration: const InputDecoration(
                labelText: 'Coin-Nummer',
                hintText: 'z.B. 123456',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
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