import 'package:flutter/material.dart';
import 'pages/search_page.dart';
import 'package:id_search/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final result = await ApiService.login(
    username: 'testuser',
    password: 'testpass',
  );
  print('Login-Response: $result');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IFTA Suche',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SearchPage(),
    );
  }
}