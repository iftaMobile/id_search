// lib/main.dart

import 'package:flutter/material.dart';
import 'package:id_search/pages/first_page.dart';
import 'pages/login_page.dart';
import 'pages/ueber_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
      home: const LoginPage(),
      routes: {
        '/ueber':    (_) => const UeberPage(),
        '/history': (_) => const FirstPage(),
        '/login':   (_) => const LoginPage(),
      },
    );
  }
}