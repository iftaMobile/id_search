import 'package:flutter/material.dart';
import 'tattoo_result_page.dart';

class TattooSearchPage extends StatefulWidget {
  const TattooSearchPage({Key? key}) : super(key: key);

  @override
  _TattooSearchPageState createState() => _TattooSearchPageState();
}

class _TattooSearchPageState extends State<TattooSearchPage> {
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final left = _leftController.text.trim();
    final right = _rightController.text.trim();

    if (left.isEmpty && right.isEmpty) {
      setState(() {
        _errorText = 'Bitte mindestens ein Tattoo eingeben';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TattooResultPage(
          tattooLeft: left,
          tattooRight: right,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tattoo-Suche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _leftController,
              decoration: const InputDecoration(
                labelText: 'Tattoo linkes Ohr',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rightController,
              decoration: const InputDecoration(
                labelText: 'Tattoo rechtes Ohr',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            if (_errorText != null)
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
              ),
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