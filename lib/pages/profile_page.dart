// lib/pages/profile_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:id_search/services/api_service.dart';
import 'package:id_search/services/session_manager.dart';
import 'package:id_search/models/UserData.dart';  // assumes User.fromMatchJson is defined here

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = _loadUserData();
  }

  Future<User> _loadUserData() async {
    final sesid = await SessionManager.instance.storedSesId;
    if (sesid == null) {
      // kein sesId → Login erzwingen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Future.error('Keine Session gefunden');
    }

    // adrId aus Prefs oder aus API nachladen
    var adrId = await SessionManager.instance.storedAdrId;
    if (adrId == null) {
      adrId = await ApiService.fetchAdrId(sesid: sesid);
      await SessionManager.instance.saveAdrId(adrId);
    }

    debugPrint('🛠️ Loading profile with sesid=$sesid   adrId=$adrId');

    // Profil‐Daten einholen
    final raw = await ApiService.fetchCustomerData(
      sesid: sesid,
      adrId: adrId,
    );
    debugPrint('🛠️ Raw profile JSON: $raw');

    final matches = raw['IFTA_MATCH'] as List<dynamic>? ?? [];
    if (matches.isEmpty) {
      throw Exception('Keine Profildaten gefunden für adrId $adrId');
    }

    final firstMatch = matches.first as Map<String, dynamic>;
    return User.fromMatchJson(firstMatch);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionManager.instance.clearSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(user.name),
                ),
                ListTile(
                  title: const Text('Straße'),
                  subtitle: Text(user.street),
                ),
                ListTile(
                  title: const Text('PLZ / Ort'),
                  subtitle: Text('${user.zip} ${user.city}'),
                ),
                ListTile(
                  title: const Text('E-Mail'),
                  subtitle: Text(user.email),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}