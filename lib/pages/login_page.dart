// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:id_search/pages/first_page.dart';
import 'package:id_search/pages/search_page_id.dart';
import 'package:id_search/services/session_manager.dart';
import 'id_result_page.dart';

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
      final sesid = await SessionManager.instance.getSesId(
        username: user,
        password: pass,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstPage()),
      );

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onLoginAnon() async {
    setState(() => _isLoading = true);

    try {
      final sesid = await SessionManager.instance.getAnonymousSesId();
      // now sesid is stored and you can navigate on exactly the same path
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstPage()),
      );
    } catch (e) {
      setState(() {
        _error = 'Fehler beim anonymen Login: $e';
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
            // … your existing Username/Password fields …
            const SizedBox(height: 24),

            // regular login button
            ElevatedButton(
              onPressed: _isLoading ? null : _onLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Login'),
            ),

            // new: anon button
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isLoading ? null : _onLoginAnon,
              child: const Text('Anonym fortfahren'),
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
