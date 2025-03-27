import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://graphql.anilist.co";

  /// Generic function to send GraphQL queries
  static Future<Map<String, dynamic>?> fetchAnime(
    String query,
    Map<String, dynamic> variables,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query, "variables": variables}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ API Error: ${response.statusCode}");
        print("🔹 Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ API Request Failed: $e");
      return null;
    }
  }
}
