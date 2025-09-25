import 'dart:math';
import 'package:flutter/material.dart';
import 'first_page.dart';

final randomizer = Random();

class Datenschutz extends StatefulWidget {
  const Datenschutz({Key? key}) : super(key: key);

  @override
  State<Datenschutz> createState() => _Datenschutz();
}

class _Datenschutz extends State<Datenschutz> {
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
            icon: const Icon(Icons.login,),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FirstPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history,),
            onPressed: () {},
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Datenschutz und Sicherheit Ihrer Daten',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Der Schutz Ihrer persönlichen Daten ist uns ein wichtiges Anliegen. '
                  'Diese App erhebt und verarbeitet Ihre Telefonnummer ausschließlich zum Zweck '
                  'der Identitätsprüfung und zur Verbesserung der Nutzererfahrung.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Welche Daten werden erhoben?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Ihre Telefonnummer, die Sie aktiv eingeben.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Wofür werden die Daten verwendet?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Zur einmaligen Verifizierung Ihrer Identität um die Rückführung des gefundenen Tieres zu ermöglichen.\n'
                  '- Zur Speicherung Ihres Verifizierungsstatus, damit Sie sich nicht erneut identifizieren müssen.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Wie werden die Daten gespeichert?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Sicherheit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Wir verwenden technische und organisatorische Maßnahmen, '
                  'um Ihre Daten vor unbefugtem Zugriff zu schützen.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}