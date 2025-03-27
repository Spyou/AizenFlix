import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String loginUrl;

  const WebViewScreen({super.key, required this.loginUrl});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Start listening for deep links
    _listenForDeepLinks((uri) => _handleDeepLink(uri));

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith("anilist://auth")) {
                  print("🔹 Redirect detected: ${request.url}");
                  _handleDeepLink(Uri.parse(request.url));
                  return NavigationDecision.prevent; // Stop WebView navigation
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.loginUrl));
  }

  /// 🔥 **Listen for Deep Links**
  // void _listenForDeepLinks() {
  //   uriLinkStream.listen(
  //     (Uri? uri) {
  //       if (uri != null && uri.toString().startsWith("anilist://auth")) {
  //         _handleDeepLink(uri);
  //       }
  //     },
  //     onError: (err) {
  //       print("❌ Deep Link Error: $err");
  //     },
  //   );
  // }

  void _listenForDeepLinks(Function(Uri uri) onLink) {
    final AppLinks appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      onLink(uri);
    });
  }

  /// 🔥 **Handle Deep Link Redirect**
  void _handleDeepLink(Uri uri) {
    String? code = uri.queryParameters["code"];
    if (code != null) {
      print("✅ Extracted Auth Code: $code");

      // ✅ Close WebView and pass the code back to AuthController
      Get.find<AuthController>().handleAuthCode(code);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AniList Login")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
