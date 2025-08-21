import 'package:flutter/material.dart';
import 'package:id_search/pages/first_page.dart';                // ← neu
import 'package:id_search/services/session_manager.dart';
import 'package:id_search/services/session_sandbox.dart';         // ← neu
import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            if (user == null || user.isEmpty) {
              return const Text('Du bist nicht eingeloggt.');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Du bist als $user eingeloggt.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    // 1) SharedPreferences/In-Memory löschen
                    await SessionManager.instance.clearSession();
                    // 2) Secure Storage löschen
                    await SessionSandbox().clearSession();

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isVerified', false);

                    // 3) Stack clearen und zurück zu FirstPage
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