import 'dart:math';
import 'package:flutter/material.dart';
// import 'appState.dart';
import 'first_page.dart';
// import 'storageHelper.dart';
// import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final randomizer = Random();

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPage();
}

class _TestPage extends State<TestPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 20,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FirstPage()),
          ),
        ),
        title: const Text('Datenschutz', style: TextStyle(fontSize: 27)),
        actions: [
          IconButton(
            icon: SizedBox(
              height: 37,
              child: Icon(Icons.login),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FirstPage()),
            ),
          ),
          IconButton(
            icon: SizedBox(
              height: 42,
              child: Icon(Icons.history),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text('Verifizierung zurücksetzen'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isVerified', false);
                debugPrint('🔒 isVerified wurde auf FALSE gesetzt');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verifizierungsstatus zurückgesetzt')),
                );
              },
            ),

        ),
      ),

    );
  }
}