// Gebaut von Marc

import 'package:flutter/material.dart';
import 'package:id_search/pages/login_page.dart';
import 'package:id_search/pages/search_page_id.dart';
import 'package:id_search/pages/search_page_transponder.dart';
import 'datenschutz_page.dart';
// import 'package:ifta_mobile/LoginPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ueber_page.dart';
// import 'ChipSuche.dart';
import 'dart:math' as math;
import 'tattoo_search_page.dart';
// import 'IdSuche.dart';
import 'registrierung_page.dart';
// import 'Kundendaten.dart';
//
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
        actions: <Widget>[
          IconButton(
            icon: SizedBox(
              height: 37,
              child: Icon(Icons.login),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
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

                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text(
                      'Login',
                      style: TextStyle(fontFamily: 'VarelaRound'),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    ),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransponderSearchPage()),
                        ),
                      ),
                      _buildGameButton(
                        imagePath: 'assets/images/Button2_200x200px.png',
                        label: 'Tattoo Suche',
                        imageSize: imageSize,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  TattooSearchPage()),
                        ),
                      ),
                      _buildGameButton(
                        imagePath: 'assets/images/Button3_200x200px.png',
                        label: 'ID Suche',
                        imageSize: imageSize,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchPageId()),
                        ),
                      ),
                      _buildGameButton(
                        imagePath: 'assets/images/Button4_200x200px.png',
                        label: 'Kunden Daten',
                        imageSize: imageSize,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Datenschutz()),
                        ),
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