// lib/pages/login_required_page.dart

import 'package:flutter/material.dart';
import 'package:id_search/pages/login_page.dart';

class LoginRequiredPage extends StatelessWidget {
  const LoginRequiredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmeldung erforderlich')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Du musst dich anmelden, um Kundendaten einzusehen.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Zur Anmeldung'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}