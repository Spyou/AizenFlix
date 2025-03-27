import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String clientId = "24763";
  static const String clientSecret = "ekKcOMZZHqpBGoDEmC8Bsoy4HRVTj5w0MeT4XM7H";
  static const String redirectUri = "anilist://auth";
  static const String tokenUrl = "https://anilist.co/api/v2/oauth/token";
  static const String graphqlUrl = "https://graphql.anilist.co";

  /// ✅ Exchange Code for Access Token
  Future<String?> exchangeCodeForToken(String code) async {
    var response = await http.post(
      Uri.parse(tokenUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "grant_type": "authorization_code",
        "client_id": clientId,
        "client_secret": clientSecret,
        "redirect_uri": redirectUri,
        "code": code,
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData["access_token"];
    } else {
      print("❌ Token Exchange Failed: ${response.body}");
      return null;
    }
  }

  /// ✅ Fetch AniList Viewer Info (Gets User ID)
  Future<int?> getUserId(String token) async {
    String query = '''
    query {
      Viewer {
        id
        name
      }
    }
    ''';

    var response = await http.post(
      Uri.parse(graphqlUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"query": query}),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData["data"]["Viewer"]["id"];
    } else {
      print("❌ Failed to Fetch User ID: ${response.body}");
      return null;
    }
  }

  /// ✅ Fetch Anime List (Fixed Variables & Query)
  /// ✅ Fetch User's Anime List (Uses the Correct Status Enum)
  Future<Map<String, dynamic>?> getUserAnime({
    required int userId,
    required String accessToken,
    String? status,
    String sort = "UPDATED_AT_DESC",
    int perPage = 10,
    int page = 1,
  }) async {
    const String apiUrl = "https://graphql.anilist.co";

    String query = '''
  query (\$userId: Int, \$status: MediaListStatus, \$sort: [MediaListSort], \$perPage: Int, \$page: Int) {
    MediaListCollection(userId: \$userId, type: ANIME) {
      lists {
        name
        entries {
          media {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            bannerImage
            description
            episodes
            status
            updatedAt
          }
        }
      }
    }
  }
''';

    Map<String, dynamic> variables = {
      "userId": userId,
      "status": status,
      "sort": [sort],
      "perPage": perPage,
      "page": page,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"query": query, "variables": variables}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('errors')) {
          print("❌ API Error: ${jsonResponse['errors']}");
          return null;
        } else {
          print("✅ User Anime List Fetched Successfully");
          return jsonResponse['data'];
        }
      } else {
        print("❌ Failed to fetch user anime: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user anime list: $e");
      return null;
    }
  }
}
