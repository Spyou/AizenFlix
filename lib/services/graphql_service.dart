import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink('https://graphql.anilist.co');
  static String? authToken; // Store user token

  static final ValueNotifier<GraphQLClient> clientNotifier = ValueNotifier(
    GraphQLClient(link: httpLink, cache: GraphQLCache(store: InMemoryStore())),
  );

  static GraphQLClient getGraphQLClient() {
    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );
  }

  static Future<void> setAuthToken(String token) async {
    authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anilist_token', token);
    _updateClient();
  }

  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('anilist_token');
    _updateClient();
  }

  static void _updateClient() {
    final AuthLink authLink = AuthLink(
      getToken: () async => authToken != null ? 'Bearer $authToken' : null,
    );

    final Link link = authLink.concat(httpLink);

    clientNotifier.value = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }

  static Future<List<dynamic>> searchAnime(String query) async {
    final String searchQuery = """
      query (\$search: String) {
        Page(perPage: 30) {
          media(search: \$search, type: ANIME) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(searchQuery),
      variables: {'search': query},
    );

    try {
      final QueryResult result = await clientNotifier.value.query(
        options,
      ); // ✅ Correct usage

      if (result.hasException) {
        print("GraphQL Error: ${result.exception.toString()}");
        return [];
      }

      final data = result.data?['Page']?['media'];
      return data ?? [];
    } catch (e) {
      print("GraphQL Exception: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getAnimeByGenre(String genre, int page) async {
    final String genreQuery = """
      query (\$page: Int, \$genre: String) {
        Page(page: \$page, perPage: 20) {
          media(genre_in: [\$genre], type: ANIME) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(genreQuery),
      variables: {'page': page, 'genre': genre},
    );

    final QueryResult result = await clientNotifier.value.query(options);

    if (result.hasException) {
      print("GraphQL Error: ${result.exception.toString()}");
      return [];
    }

    return result.data?['Page']?['media'] ?? [];
  }

  static Future<Map<String, dynamic>?> fetchUserData() async {
    const String query = """
    query {
      Viewer {
        id
        name
        avatar {
          large
        }
        statistics {
          anime {
            count
            meanScore
            minutesWatched
            episodesWatched
          }
        }
        mediaListOptions {
          scoreFormat
        }
      }
    }
  """;

    final QueryOptions options = QueryOptions(document: gql(query));

    final QueryResult result = await clientNotifier.value.query(options);

    if (result.hasException) {
      print("❌ GraphQL Error: ${result.exception.toString()}");
      return null;
    }

    return result.data?['Viewer'];
  }

  static Future<List<dynamic>> fetchUserAnimeList(int userId) async {
    const String query = """
  query (\$userId: Int) {
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
          }
        }
      }
    }
  }
  """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'userId': userId},
    );

    final QueryResult result = await GraphQLService.clientNotifier.value.query(
      options,
    );

    if (result.hasException) {
      print("❌ GraphQL Error (Anime Lists): ${result.exception.toString()}");
      return [];
    }

    print("📥 RAW RESPONSE (Anime Lists): ${result.data}");

    List<dynamic> animeLists =
        result.data?['MediaListCollection']?['lists'] ?? [];

    return animeLists;
  }

  static Future<List<dynamic>> fetchUserFavorites({int page = 1}) async {
    const String query = """
query {
  Viewer {
    id
    name
    avatar {
      large
    }
    favourites {
      anime {
        edges {
          node {  # ✅ Change from 'node' to 'media'
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
          }
        }
      }
    }
  }
}
""";

    final QueryOptions options = QueryOptions(document: gql(query));

    final QueryResult result = await GraphQLService.clientNotifier.value.query(
      options,
    );

    if (result.hasException) {
      print("❌ GraphQL Error (Favorites): ${result.exception.toString()}");
      return [];
    }

    print("📥 RAW RESPONSE (Favorites): ${result.data}");

    List<dynamic> favorites =
        result.data?['Viewer']?['favourites']?['anime']?['edges'] ?? [];

    // Extract actual anime nodes
    List<dynamic> parsedFavorites =
        favorites.map((fav) => fav['node']).toList();

    print("✅ Parsed Favorites: ${parsedFavorites.length} found");

    return parsedFavorites;
  }

  static Future<bool> addAnimeToList(int animeId, String status) async {
    const String mutation = """
  mutation (\$animeId: Int, \$status: MediaListStatus) {
    SaveMediaListEntry(mediaId: \$animeId, status: \$status) {
      id
      status
    }
  }
  """;

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        "animeId": animeId,
        "status":
            status
                .toUpperCase(), // Ensure it's in uppercase (e.g., WATCHING, COMPLETED)
      },
    );

    try {
      final QueryResult result = await clientNotifier.value.mutate(options);

      if (result.hasException) {
        print("❌ GraphQL Error: ${result.exception.toString()}");
        return false;
      }

      print("✅ Anime Added Successfully: ${result.data}");
      return true;
    } catch (e) {
      print("🚨 Error Adding Anime: $e");
      return false;
    }
  }
}
