import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({Key? key}) : super(key: key);

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final _phoneController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndProceed() async {
    final phone = _phoneController.text.trim();

    // Simple regex for German mobile numbers (starts with +49 or 01...)
    final phoneRegex = RegExp(r'^(\+49|0)[1-9][0-9]{7,}$');

    if (!phoneRegex.hasMatch(phone)) {
      setState(() => _errorText = 'Bitte gültige Telefonnummer im Format +49... oder 01... eingeben die mindestens 11 Stellen hat');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVerified', true);
    await prefs.setString('userPhone', phone);

    debugPrint('✅ Telefonnummer gespeichert: $phone');
    Navigator.pushReplacementNamed(context, '/first');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identitätsprüfung')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zur Sicherheit benötigen wir Ihre Telefonnummer.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefonnummer',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _verifyAndProceed(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _verifyAndProceed,
              icon: const Icon(Icons.check),
              label: const Text('Weiter'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ihre Telefonnummer wird ausschließlich zur Identitätsprüfung gespeichert',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}