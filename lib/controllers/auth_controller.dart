import 'package:anilist_test/services/graphql_service.dart';
import 'package:app_links/app_links.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/introduction/auth/webview_screen.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  RxBool isLoggedIn = false.obs;
  RxString accessToken = "".obs;
  RxInt userId = 0.obs;
  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    listenForDeepLinks();
  }

  /// ✅ Listen for OAuth Redirects
  void listenForDeepLinks() {
    // uriLinkStream.listen(
    //   (Uri? uri) async {
    //     if (uri != null && uri.toString().startsWith("anilist://auth")) {
    //       String? code = uri.queryParameters["code"];
    //       if (code != null) {
    //         print("🔹 Received Auth Code: $code");
    //         await handleAuthCode(code);
    //       }
    //     }
    //   },
    //   onError: (err) {
    //     print("❌ Deep Link Error: $err");
    //   },
    // );

    AppLinks().uriLinkStream.listen((uri) async {
      if (uri.toString().startsWith("anilist://auth")) {
        String? code = uri.queryParameters["code"];
        if (code != null) {
          print("🔹 Received Auth Code: $code");
          await handleAuthCode(code);
        }
      }
    });
  }

  /// ✅ Start AniList Login Flow
  void login() async {
    final url =
        "https://anilist.co/api/v2/oauth/authorize?client_id=${AuthService.clientId}&redirect_uri=anilist://auth&response_type=code";
    Get.to(() => WebViewScreen(loginUrl: url));
  }

  /// ✅ Handle OAuth Code & Exchange for Token
  Future<void> handleAuthCode(String code) async {
    print("🔹 Exchanging Code for Token...");
    String? token = await _authService.exchangeCodeForToken(code);

    if (token != null) {
      print("✅ Received Token: $token"); // <- Debugging token
      accessToken.value = token;
      isLoggedIn.value = true;

      await saveToken(token);
      await GraphQLService.setAuthToken(
        token,
      ); // ✅ Pass token to GraphQLService

      fetchUserAnimeInfo();
      print("✅ Login Successful! Token: $token");
      Get.offAllNamed('/HomeScreen');
    } else {
      print("❌ Token Exchange Failed");
    }
  }

  /// ✅ Fetch User's Anime List
  Future<void> fetchUserAnimeInfo() async {
    try {
      if (accessToken.value.isEmpty) {
        print("⚠️ Access Token is missing.");
        return;
      }

      // Decode JWT to extract user ID
      String token = accessToken.value;
      try {
        final decodedToken = JWT.decode(token);
        int? userId = int.tryParse(decodedToken.payload['sub'].toString());

        if (userId == null) {
          print("🚨 Error: User ID is null or invalid in JWT payload.");
          return;
        }

        print("🔹 Extracted User ID: $userId");

        // Fetch user anime list (now passing the token!)
        var data = await _authService.getUserAnime(
          userId: userId,
          accessToken: token,
        );

        if (data != null) {
          userInfo.value = data;
          print("✅ User Anime Data: ${userInfo.value}");
        } else {
          print("❌ Failed to Fetch Anime");
        }
      } catch (e) {
        print("🚨 Error Decoding JWT: $e");
      }
    } catch (e) {
      print("🚨 Unexpected Error Fetching User Anime: $e");
    }
  }

  /// ✅ Logout
  Future<void> logout() async {
    await removeToken();
    accessToken.value = "";
    isLoggedIn.value = false;
    userInfo.clear();
    Get.offAllNamed('/LoginScreen');
  }

  /// ✅ Persist Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
  }

  /// ✅ Check Login State at Start
  Future<void> checkLoginStatus() async {
    String? token = await getToken();

    if (token != null && token.isNotEmpty) {
      accessToken.value = token;
      isLoggedIn.value = true;

      int? fetchedUserId = await _authService.getUserId(token);
      if (fetchedUserId != null) {
        userId.value = fetchedUserId;
        fetchUserAnimeInfo();
        print("✅ User is already logged in");

        /// ✅ Check if navigation is inside a valid widget tree
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/HomeScreen');
        });
      } else {
        print("❌ Failed to Fetch User ID");
      }
    } else {
      print("🔹 No saved token found. Showing Login Screen.");

      /// ✅ Ensure navigation happens inside a widget tree
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/LoginScreen');
      });
    }
  }
}
