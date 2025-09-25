// Gebaut von Marc
import 'login_required_page.dart';
import 'package:flutter/material.dart';
import 'package:id_search/pages/login_page.dart';
import 'package:id_search/pages/profile_page.dart';
import 'package:id_search/pages/search_page_id.dart';
import 'package:id_search/pages/search_page_transponder.dart';
import 'datenschutz_page.dart';
import 'package:id_search/services/api_service.dart';
import 'package:id_search/services/session_manager.dart';
import 'package:id_search/models/UserData.dart';
// import 'package:ifta_mobile/LoginPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ueber_page.dart';
// import 'ChipSuche.dart';
import 'dart:math' as math;
import 'tattoo_search_page.dart';
// import 'IdSuche.dart';
import 'registrierung_page.dart';
// import 'Kundendaten.dart';
import 'animal_selection_page.dart';
import 'logout_page.dart';
import 'identification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_page.dart';
// import 'storageHelper.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  final String sesid = 'dein_vorhandener_sesid_wert';
  @override
  void initState() {
    super.initState();
  }

  Future<List<Animal>> _loadAnimals() async {
    final raw = await ApiService.fetchCustomerData(
      sesid: (await SessionManager.instance.storedSesId)!,
      adrId: (await SessionManager.instance.storedAdrId)!,
    );
    final matches = (raw['IFTA_MATCH'] as List).cast<Map<String, dynamic>>();
    return matches.map(Animal.fromJson).toList();
  }

  Future<bool> _isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isVerified') ?? false;
  }





  Widget _buildGameButton({
    required String imagePath,
    required String label,
    required double imageSize,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: SizedBox(
              height: imageSize,
              width: imageSize,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6), // 👈 kleiner Abstand zum Text
          Text(
            label,
            style: const TextStyle(fontSize: 22), // Optional: kleinere Schrift
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFTA Mobile', style: TextStyle(fontSize: 27, fontFamily: "VarelaRound")),
        toolbarHeight: 60,
          actions: [
            FutureBuilder<String?>(
              future: SessionManager.instance.storedSesId,
              builder: (ctx, snapshot) {
                final isLoggedIn = snapshot.data?.isNotEmpty == true;

                return IconButton(
                  icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      isLoggedIn ? '/logout' : '/login',
                    ).then((_) {
                      // Nach Pop oder Replace: Widget neu aufbauen
                      setState(() {});
                    });
                  },
                );
              },
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
      drawer: Builder(
        builder: (context) {
          final double drawerWidth = math.min(
            MediaQuery.of(context).size.width / 2,
            210,
          );



          return SizedBox(
            width: drawerWidth,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 123,
                    child: DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFF287233),
                      ),
                      child: const Text(
                        'Einstellungen',
                        style: TextStyle(fontSize: 23, fontFamily: "VarelaRound",color: Colors.white),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Homepage',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    leading: const Icon(Icons.public),  // optional: Icon hinzufügen
                    onTap: () async {
                      // Definiere die Ziel-URL
                      final Uri url = Uri.parse('https://www.tierregistrierung.de/index.php?module=Pagesetter&func=viewpub&pid=1&tid=10');

                      // Prüfe, ob das Gerät die URL öffnen kann
                      if (await canLaunchUrl(url)) {
                        // Öffne externen Browser
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Optional: Fehlerbehandlung
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konnte die Webseite nicht öffnen.')),
                        );
                      }
                    },
                  ),

                  FutureBuilder<String?>(
                    future: SessionManager.instance.storedSesId,
                    builder: (ctx, snap) {
                      final isLoggedIn = snap.hasData && snap.data!.isNotEmpty;

                      return ListTile(
                        leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
                        title: Text(
                          isLoggedIn ? 'Logout' : 'Login',
                          style: const TextStyle(fontFamily: 'VarelaRound'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              isLoggedIn ? const LogoutPage() : const LoginPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),


                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(
                      'Über Ifta Mobile',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UeberPage()),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text(
                      'Datenschutz',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Datenschutz()),
                    ),
                  ),
                  /*ListTile(
                    leading: const Icon(Icons.perm_identity),
                    title: const Text(
                      'Identification',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IdentificationPage()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.question_mark),
                    title: const Text(
                      'Test Page',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestPage()),
                    ),
                  ),*/
                ],
              ),
            ),
          );
        },
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double imageSize = screenWidth * 0.38;

          return Column(
            children: [
              const Spacer(flex: 2), // 🧭 Platz oben
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 👈 added vertical padding
                  child: GridView.count(
                    shrinkWrap: true,
                   // physics: (),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 35,
                    childAspectRatio: 1.1,
                    children: [
                      // your buttons

                      _buildGameButton(
                        imagePath: 'assets/images/Button1_200x200px.png',
                        label: 'Chip Suche',
                        imageSize: imageSize,
                        onPressed: () async {

                          final prefs = await SharedPreferences.getInstance();
                          final verified = prefs.getBool('isVerified') ?? false;
                          final phone = prefs.getString('userPhone') ?? 'Keine Nummer gespeichert';

                          debugPrint('🔍 Chip Suche → isVerified = $verified');
                          debugPrint('📞 Gespeicherte Telefonnummer: $phone');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => verified
                                  ? const TransponderSearchPage()
                                  : const IdentificationPage(),
                            ),
                          );
                        },
                      ),

                      _buildGameButton(
                        imagePath: 'assets/images/Button2_200x200px.png',
                        label: 'Tattoo Suche',
                        imageSize: imageSize,
                        onPressed: () async {
                          final verified = await _isVerified();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => verified
                                  ? TattooSearchPage()
                                  : const IdentificationPage(),
                            ),
                          );
                        },
                      ),

                      _buildGameButton(
                        imagePath: 'assets/images/Button3_200x200px.png',
                        label: 'ID Suche',
                        imageSize: imageSize,
                        onPressed: () async {
                          final verified = await _isVerified();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => verified
                                  ? const SearchPageId()
                                  : const IdentificationPage(),
                            ),
                          );
                        },
                      ),
                      _buildGameButton(
                        imagePath: 'assets/images/Button4_200x200px.png',
                        label: 'Kunden Daten',
                        imageSize: imageSize,
                        onPressed: () async {
                          final sesid = await SessionManager.instance.storedSesId;

                          if (sesid != null && sesid.isNotEmpty) {
                            // eingeloggt → Tier-Auswahl öffnen
                            final animals = await _loadAnimals();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnimalSelectionScreen(animals: animals),
                              ),
                            );
                          } else {
                            // nicht eingeloggt → Hinweis-Seite
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginRequiredPage()),
                            );
                          }
                        },
                      ),

                      _buildGameButton(
                        imagePath: 'assets/images/Button5_200x200px.png',
                        label: 'Über Ifta',
                        imageSize: imageSize,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UeberPage()),
                        ),
                      ),
                      _buildGameButton(
                        imagePath: 'assets/images/Button5_200x200px.png',
                        label: 'Registrieren',
                        imageSize: imageSize,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TierRegistrierungPage(sesid: sesid)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3), // 🧭 Platz unten
            ],
          );
        },
      ),


    );
  }
}