import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
//961001200037076import 'LoginPage.dart';

import 'package:url_launcher/url_launcher.dart';

class UeberPage extends StatefulWidget {
  const UeberPage({Key? key}) : super(key: key);

  @override
  State<UeberPage> createState() => _UeberPageState();
}

class _UeberPageState extends State<UeberPage> {
  late final WebViewController _webController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // WebView-Controller aufsetzen
    final params = const PlatformWebViewControllerCreationParams();
    _webController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      );

    // Android-spezifisch: Debugging erlauben
    if (_webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    // Lokales Asset laden
    _webController.loadFlutterAsset('assets/anleitung.html');
  }

  Future<void> _openHomepage() async {
    final uri = Uri.parse('https://www.tierregistrierung.de');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Über die App'),
            SizedBox(height: 2),
            Text(
              'Anleitung & Info',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Homepage',
            icon: const Icon(Icons.public),
            onPressed: _openHomepage,
          ),
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigiere zur History-Seite
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            tooltip: 'Login',
            icon: const Icon(Icons.login),
            onPressed: () {
              // Navigiere zur Login-Seite
              Navigator.pushNamed(context, '/login');
            },
          ),
          SizedBox(width: 20,)
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}