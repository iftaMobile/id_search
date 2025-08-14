// lib/pages/tattoo_search_page.dart

import 'package:flutter/material.dart';
import 'tattoo_result_page.dart';

class TattooSearchPage extends StatefulWidget {
  const TattooSearchPage({Key? key}) : super(key: key);

  @override
  _TattooSearchPageState createState() => _TattooSearchPageState();
}

class _TattooSearchPageState extends State<TattooSearchPage> {
  final _ctrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final code = _ctrl.text.trim();
    if (code.isEmpty) {
      setState(() => _err = 'Bitte Tattoo-Code eingeben');
      return;
    }
    setState(() => _err = null);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TattooResultPage(tattoo: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tattoo-Suche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              labelText: 'Tattoo-Code',
              errorText: _err,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _onSearch,
            icon: const Icon(Icons.search),
            label: const Text('Suchen'),
          ),
        ]),
      ),
    );
  }
}