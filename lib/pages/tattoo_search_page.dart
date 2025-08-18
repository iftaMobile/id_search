// lib/pages/tattoo_search_page.dart

import 'package:flutter/material.dart';
import 'tattoo_result_page.dart';  // <-- Import der Result-Page

class TattooSearchPage extends StatefulWidget {
  @override
  _TattooSearchPageState createState() => _TattooSearchPageState();
}

class _TattooSearchPageState extends State<TattooSearchPage> {
  final TextEditingController _tattooController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _tattooController.dispose();
    super.dispose();
  }

  void _searchTattoo() {
    FocusScope.of(context).unfocus();
    final code = _tattooController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _error = 'Bitte einen Tattoo-Code eingeben';
      });
      return;
    }

    // Navigation zur Result-Page – links befüllt, rechts leer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TattooResultPage(
          leftTattoo: code,
          rightTattoo: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tattoo-Suche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tattooController,
              decoration: InputDecoration(
                labelText: 'Tattoo-Code',
                errorText: _error,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchTattoo(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _searchTattoo,
              child: Text('Suche starten'),
            ),
            // optional: hier könnten weiterhin lokale Ergebnisse stehen,
            // wir lassen sie aber weg, da die Result-Page alles übernimmt.
          ],
        ),
      ),
    );
  }
}