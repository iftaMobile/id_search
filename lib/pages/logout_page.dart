// lib/pages/logout_page.dart

import 'package:flutter/material.dart';
import 'package:id_search/services/session_manager.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sitzung aktiv')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Du bist bereits eingeloggt.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await SessionManager.instance.clearSession();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Ausloggen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}