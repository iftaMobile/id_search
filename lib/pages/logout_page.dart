// lib/pages/logout_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:id_search/services/session_manager.dart';
import 'package:id_search/services/session_sandbox.dart';
import 'first_page.dart';
import 'login_page.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  late Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = SessionManager.instance.storedUsername;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: FutureBuilder<String?>(
          future: _usernameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            final user = snapshot.data;
            // 1) Nicht eingeloggt
            if (user == null || user.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Du bist nicht eingeloggt.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Zum Login'),
                  ),
                ],
              );
            }

            // 2) Eingeloggt
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Du bist als $user eingeloggt.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    // Session in SharedPreferences und Secure Storage löschen
                    await SessionManager.instance.clearSession();
                    await SessionSandbox().clearSession();

                    // isVerified zurücksetzen
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isVerified', false);

                    // Zur FirstPage navigieren und den Stack löschen
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/first', (r) => false);
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}