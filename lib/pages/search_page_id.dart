// lib/pages/search_page.dart

import 'package:flutter/material.dart';
import 'id_result_page.dart';

class SearchPageId extends StatefulWidget {
  const SearchPageId({super.key});

  @override
  _SearchPageIdState createState() => _SearchPageIdState();
}

class _SearchPageIdState extends State<SearchPageId> {
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
        builder: (_) => IdResultPage(coin: coin),
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