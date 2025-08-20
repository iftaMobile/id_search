import 'dart:io';
import 'package:flutter/material.dart';
import 'first_page.dart';
// import 'LoginPage.dart';
// WebView-Package
import 'package:webview_flutter/webview_flutter.dart';
// Optional: für Android-spezifische Features
import 'package:webview_flutter_android/webview_flutter_android.dart';

class TierRegistrierungPage extends StatefulWidget {
  final String sesid;
  const TierRegistrierungPage({Key? key, required this.sesid}) : super(key: key);

  @override
  State<TierRegistrierungPage> createState() => _TierRegistrierungPageState();
}

class _TierRegistrierungPageState extends State<TierRegistrierungPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // 1. Erstelle Plattformspezifische CreationParams
    final PlatformWebViewControllerCreationParams params =
    const PlatformWebViewControllerCreationParams();

    // 2. Baue den Controller
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JS erlauben
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _showLoading(true),
          onPageFinished: (_) => _showLoading(false),
          onNavigationRequest: (req) => NavigationDecision.navigate,
        ),
      );

    // 3. Android-Optimierungen (optional)
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // 4. URL laden
    final url = Uri.https(
      'tierregistrierung.de',
      '/index.php',
      {
        'module': 'if_tierreg',
        'func': 'register',
        'regart': 'strange',
        'comefrom': 'mobile',
        'sesid': widget.sesid,
      },
    );
    _controller.loadRequest(url);
  }

  bool _isLoading = true;
  void _showLoading(bool flag) => setState(() => _isLoading = flag);

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
        title: const Text('Tierregistrieren', style: TextStyle(fontSize: 27)),
        actions: [

        ],
      ),
      body: Stack(
        children: [
          // Das neue WebView-Widget
          WebViewWidget(controller: _controller),

          // Optional: Lade-Indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
