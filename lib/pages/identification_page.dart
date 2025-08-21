import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({Key? key}) : super(key: key);

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _errorText;
  bool _codeSent = false;
  String? _generatedCode; // Simuliert den SMS-Code

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 6) {
      setState(() => _errorText = 'Bitte gültige Telefonnummer eingeben');
      return;
    }

    // Simuliere 4-stelligen Code
    final code = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    _generatedCode = code;
    _codeSent = true;

    // Hier würdest du den Code per SMS versenden
    debugPrint('📲 SMS-Code gesendet: $code');

    setState(() {
      _errorText = null;
    });
  }

  Future<void> _verifyCode() async {
    final enteredCode = _codeController.text.trim();

    if (enteredCode != _generatedCode) {
      setState(() => _errorText = 'Code ist ungültig oder abgelaufen');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVerified', true);

    // 📞 Telefonnummer speichern
    final phone = _phoneController.text.trim();
    await prefs.setString('userPhone', phone);
    debugPrint('✅ Verifiziert! Telefonnummer gespeichert: $phone');

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
              'Zur Sicherheit benötigen wir Ihre Telefonnummer. Sie erhalten einen 4-stelligen Code per SMS.',
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
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendCode,
              icon: const Icon(Icons.sms),
              label: const Text('Code senden'),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'SMS-Code eingeben',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              ElevatedButton.icon(
                onPressed: _verifyCode,
                icon: const Icon(Icons.verified),
                label: const Text('Verifizieren'),
              ),
            ],
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