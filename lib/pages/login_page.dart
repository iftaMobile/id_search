// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:id_search/pages/first_page.dart';
import 'package:id_search/services/session_manager.dart';
import 'package:id_search/services/session_sandbox.dart'; // ← neu
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    // 1) Sind wir schon eingeloggt? (Session-ID + Username prüfen)
    final storedSesId  = await SessionManager.instance.storedSesId;
    final storedUsernm = await SessionManager.instance.storedUsername;
    if (storedSesId != null &&
        storedSesId.isNotEmpty &&
        storedUsernm != null &&
        storedUsernm.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/logout');
      return;
    }

    // 2) Validierung
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Bitte Username und Passwort eingeben.');
      return;
    }

    // 3) Ladezustand anzeigen
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 4) Session-ID vom Server holen
      final String sesId = await SessionManager.instance.getSesId(
        username: user,
        password: pass,
      );

      // **NEU**: Token in Secure Storage persistent ablegen
      await SessionSandbox().saveSession(sesId);

      // 5) Session-ID UND Username in SharedPreferences speichern
      await SessionManager.instance.setSession(
        sesId: sesId,
        username: user,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isVerified', true);


      // 6) Weiterleiten zur ersten Seite (oder HomeScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstPage()),
      );
    } catch (e) {
      setState(() {
        _error = 'Login fehlgeschlagen: ${e.toString()}';
        _isLoading = false;
      });
    }
  } // ← Hier war zuvor die schließende Klammer zu wenig


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Benutzername'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _onLogin,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Login'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                setState(() => _isLoading = true);

                // Session löschen
                await SessionManager.instance.clearSession();

                // Erst dann zur FirstPage navigieren
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const FirstPage()),
                );
              },
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Anonym fortfahren'),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}