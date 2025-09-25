import 'package:flutter/material.dart';
import '../models/tattoo_match.dart';

class TattooDetailPage extends StatelessWidget {
  final TattooMatch match;

  const TattooDetailPage({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addressParts = <String>[
      if ((match.strasse ?? '').isNotEmpty) match.strasse!,
      if ((match.plz ?? '').isNotEmpty) match.plz!,
      if ((match.ort ?? '').isNotEmpty) match.ort!,
    ];
    final address =
    addressParts.isEmpty ? '–' : addressParts.join(', ');

    return Scaffold(
      appBar: AppBar(title: const Text('Tier-Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Name: ${match.tiername ?? '–'}'),
            const SizedBox(height: 8),
            if (match.transponder != null)
              Text('Transponder: ${match.transponder}'),
            if (match.tierart != null) ...[
              const SizedBox(height: 8),
              Text('Tierart: ${match.tierart}'),
            ],
            const SizedBox(height: 8),
            Text('Rasse/Farbe: ${match.rasse ?? '–'} / ${match.farbe ?? '–'}'),
            const SizedBox(height: 8),
            Text('Geburt: ${match.geburt ?? '–'}'),
            const SizedBox(height: 8),
            Text('Adresse: $address'),
            const SizedBox(height: 8),
            Text('Halter: ${match.haltername ?? '–'}'),
            const SizedBox(height: 8),
            Text('Tel: ${match.telefonPriv ?? '–'}'),
          ],
        ),
      ),
    );
  }
}