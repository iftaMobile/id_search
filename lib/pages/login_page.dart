// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:id_search/services/session_manager.dart';

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
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Bitte Username und Passwort eingeben.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Benutzer-Login und SesID speichern
      await SessionManager.instance.getSesId(
        username: user,
        password: pass,
      );

      // Auf Profil-Seite weiterleiten
      Navigator.pushReplacementNamed(context, '/first');
    } catch (e) {
      setState(() {
        _error = 'Login fehlgeschlagen: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _onLoginAnon() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Anonymen Login (Geräte-ID als SesID) durchführen
      await SessionManager.instance.getAnonymousSesId();

      // Auf Profil-Seite weiterleiten
      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      setState(() {
        _error = 'Fehler beim anonymen Login: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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
              onPressed: _isLoading ? null : _onLoginAnon,
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