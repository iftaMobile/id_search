// lib/main.dart

import 'package:flutter/material.dart';
import 'package:id_search/services/session_sandbox.dart';
import 'package:id_search/pages/first_page.dart';
import 'package:id_search/pages/login_page.dart';
import 'package:id_search/pages/ueber_page.dart';
import 'package:id_search/pages/profile_page.dart';
import 'package:id_search/pages/logout_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Secure-Storage prüfen
  final storedSesId = await SessionSandbox().loadSession();
  final bool isLoggedIn = storedSesId != null && storedSesId.isNotEmpty;

  // 2) App mit Flag starten
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

      // 3) Home je nach Login-Status
      home: isLoggedIn ? const FirstPage() : const LoginPage(),

      // optionale benannte Routen
      routes: {
        '/login':   (_) => const LoginPage(),
        '/first':   (_) => const FirstPage(),
        '/ueber':   (_) => const UeberPage(),
        //'/profile': (_) => const ProfilePage(),
        '/logout':  (_) => const LogoutPage(),
      },
    );
  }
}