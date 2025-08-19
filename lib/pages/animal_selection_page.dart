import 'package:flutter/material.dart';
import 'profile_page.dart';
import '../models/UserData.dart';

class AnimalSelectionScreen extends StatelessWidget {
  final List<Animal> animals;

  const AnimalSelectionScreen({Key? key, required this.animals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tier auswählen')),
      body: ListView.separated(
        itemCount: animals.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (ctx, i) {
          final animal = animals[i];
          return ListTile(
            leading: Icon(Icons.pets),
            title: Text(animal.name),
            subtitle: Text('${animal.species}, ${animal.breed}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(animal: animal),
                ),
              );
            },
          );
        },
      ),
    );
  }
}