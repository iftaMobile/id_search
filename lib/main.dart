// lib/main.dart

import 'package:flutter/material.dart';
import 'package:id_search/pages/first_page.dart';
import 'package:id_search/pages/login_page.dart';
import 'package:id_search/pages/ueber_page.dart';
import 'package:id_search/pages/profile_page.dart';           // ← your ProfilePage
import 'package:id_search/services/session_manager.dart';
import 'pages/animal_selection_page.dart';
import 'pages/animal_selection_page.dart';
// ← our session helper

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // check if we already have a stored sesid (login or anonymous)
      future: SessionManager.instance.storedSesId,
      builder: (context, snapshot) {
        // still waiting for SharedPreferences
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final hasSession = snapshot.data != null && snapshot.data!.isNotEmpty;

        return MaterialApp(
          title: 'IFTA Mobile',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF287233),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            primarySwatch: Colors.green,
            fontFamily: 'VarelaRound',
          ),

          // decide the initial screen based on session
          home:   // ← user is “logged in” → show profile
              const FirstPage(),     // ← no session → your existing entry page

          routes: {
            '/ueber':    (_) => const UeberPage(),
            '/first': (_) => const FirstPage(),
            '/login':   (_) => const LoginPage(),



          },
        );
      },
    );
  }
}