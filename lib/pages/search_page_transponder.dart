// lib/pages/transponder_search_page.dart

import 'package:flutter/material.dart';
import 'transponder_result_page.dart';

class TransponderSearchPage extends StatefulWidget {
  const TransponderSearchPage({Key? key}) : super(key: key);

  @override
  _TransponderSearchPageState createState() => _TransponderSearchPageState();
}

class _TransponderSearchPageState extends State<TransponderSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorText = 'Bitte einen Transponder-Code eingeben';
      });
      return;
    }
    setState(() {
      _errorText = null;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransponderResultPage(transponder: input),
      ),
    );
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
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Transponder-Code',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _onSearch(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Suchen'),
            ),
          ],
        ),
      ),
    );
  }
}