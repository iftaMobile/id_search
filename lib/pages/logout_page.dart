import 'package:flutter/material.dart';
import 'package:id_search/services/session_manager.dart';
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
            // snapshot.data ist jetzt null oder empty → „nicht eingeloggt“
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
                    await SessionManager.instance.clearSession();
                    // Stack clearen → HomePage neu instanziieren
                    Navigator.of(context).pushNamedAndRemoveUntil('/first', (r) => false);
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