import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/anime_model.dart';
import '../services/api_service.dart';

class HomeController extends GetxController {
  var trendingAnime = <AnimeModel>[].obs;
  var recentlyUpdatedAnime = <AnimeModel>[].obs;
  var topRatedAnime = <AnimeModel>[].obs;
  var trendingMovies = <AnimeModel>[].obs;
  var userAnimeList = <AnimeModel>[].obs;
  var popularAnime = <AnimeModel>[].obs;
  var mostFavourite = <AnimeModel>[].obs;

  var isLoadingPopular = false.obs; //Loading state
  var currentPage = 1.obs;

  var hasMoreAnime = true.obs; //Prevent infinite calls when no more data

  @override
  void onInit() {
    super.onInit();
    fetchTrendingAnime();
    fetchTrendingMovies(); // Fetch Trending Movies
    fetchRecentlyUpdatedAnime();
    fetchTopRatedAnime(); // Fetch Top Rated Anime
    fetchContinueWatching(userId: 1); // Fetch Continue Watching List
    fetchPopularAnime(); // Load first page on start
    fetchMostFavouriteAnime();
  }

  Future<void> fetchTrendingAnime({int page = 1}) async {
    const String query = """
      query (\$page: Int) {
        Page(page: \$page, perPage: 40) {
          media(type: ANIME, sort: TRENDING_DESC, isAdult: false) {
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
            genres
            status
            averageScore
          }
        }
      }
    """;

    final response = await ApiService.fetchAnime(query, {"page": page});
    if (response != null && response['data'] != null) {
      var animeList =
          response['data']['Page']['media']
              .map<AnimeModel>((item) => AnimeModel.fromJson(item))
              .toList();
      trendingAnime.assignAll(animeList);
    }
  }

  Future<void> fetchRecentlyUpdatedAnime({int page = 1}) async {
    const String query = """
      query (\$page: Int) {
        Page(page: \$page, perPage: 40) {
          media(type: ANIME, sort: UPDATED_AT_DESC, isAdult: false) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            description
            episodes
            status
          }
        }
      }
    """;

    final response = await ApiService.fetchAnime(query, {"page": page});
    if (response != null && response['data'] != null) {
      var animeList =
          response['data']['Page']['media']
              .map<AnimeModel>((item) => AnimeModel.fromJson(item))
              .toList();
      recentlyUpdatedAnime.assignAll(animeList);
    }
  }

  // ✅ Fetch Top Rated Anime
  Future<void> fetchTopRatedAnime({int page = 1}) async {
    const String query = """
      query (\$page: Int) {
        Page(page: \$page, perPage: 40) {
          media(type: ANIME, sort: SCORE_DESC, isAdult: false) {
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
            genres
            status
            averageScore
          }
        }
      }
    """;

    final response = await ApiService.fetchAnime(query, {"page": page});
    if (response != null && response['data'] != null) {
      var animeList =
          response['data']['Page']['media']
              .map<AnimeModel>((item) => AnimeModel.fromJson(item))
              .toList();
      topRatedAnime.assignAll(animeList);
    }
  }

  // ✅ Fetch Trending Movies
  Future<void> fetchTrendingMovies({int page = 1}) async {
    const String query = """
    query (\$page: Int) {
      Page(page: \$page, perPage: 40) {
        media(type: ANIME, format: MOVIE, sort: TRENDING_DESC, isAdult: false) {
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
          genres
          status
          averageScore
        }
      }
    }
  """;

    final response = await ApiService.fetchAnime(query, {"page": page});

    if (response != null) {
      debugPrint("✅ API Raw Response: $response"); // 🔥 Debug API Response

      if (response['data'] != null && response['data']['Page'] != null) {
        var movieList =
            response['data']['Page']['media']
                .map<AnimeModel>((item) => AnimeModel.fromJson(item))
                .toList();

        trendingMovies.assignAll(movieList);
        trendingMovies.refresh(); // ✅ Force UI Update

        debugPrint("🎬 Loaded ${trendingMovies.length} Trending Movies");
      } else {
        debugPrint("❌ No movies found in API response.");
      }
    } else {
      debugPrint("❌ API Response is null.");
    }
  }

  // ✅ Fetch Popular Anime with Pagination
  Future<void> fetchPopularAnime({bool isLoadMore = false}) async {
    if (isLoadingPopular.value || !hasMoreAnime.value) return;

    isLoadingPopular.value = true;

    const String query = """
      query (\$page: Int) {
        Page(page: \$page, perPage: 20) {  
          media(type: ANIME, sort: POPULARITY_DESC, isAdult: false) {
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
            genres
            status
            averageScore
          }
        }
      }
    """;

    final response = await ApiService.fetchAnime(query, {
      "page": currentPage.value,
    });

    if (response != null && response['data'] != null) {
      var animeList =
          response['data']['Page']['media']
              .map<AnimeModel>((item) => AnimeModel.fromJson(item))
              .toList();

      if (animeList.isEmpty) {
        hasMoreAnime.value = false;
      } else {
        if (isLoadMore) {
          popularAnime.addAll(animeList);
        } else {
          popularAnime.assignAll(animeList);
        }
        currentPage.value++;
      }
    } else {
      debugPrint("❌ API Response is null or invalid");
    }

    isLoadingPopular.value = false;
  }

  // User Continue Watching List

  Future<List<AnimeModel>> fetchContinueWatching({required int userId}) async {
    const String query = """
    query (\$userId: Int!) {
      MediaListCollection(userId: \$userId, type: ANIME, status: CURRENT) {
        lists {
          name
          entries {
            id
            progress
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
              genres
              status
              averageScore
            }
          }
        }
      }
    }
  """;

    final response = await ApiService.fetchAnime(query, {"userId": userId});

    if (response != null) {
      debugPrint("✅ API Raw Response: $response");

      if (response['data'] != null &&
          response['data']['MediaListCollection'] != null) {
        var lists = response['data']['MediaListCollection']['lists'] as List;
        List<AnimeModel> continueWatchingList = [];

        for (var list in lists) {
          var entries = list['entries'] as List;
          for (var entry in entries) {
            var anime = AnimeModel.fromJson(entry['media']);
            anime.progress = entry['progress'];
            continueWatchingList.add(anime);
          }
        }

        // Update your UI with continueWatchingList
        // For example:
        // continueWatching.assignAll(continueWatchingList);
        // continueWatching.refresh();

        debugPrint(
          "🎬 Loaded ${continueWatchingList.length} Continue Watching entries",
        );

        return continueWatchingList;
      } else {
        debugPrint("❌ No entries found in API response.");
      }
    } else {
      debugPrint("❌ API Response is null.");
    }

    // Return empty list as fallback
    return [];
  }

  // Fetch Most Favourite Anime
  Future<void> fetchMostFavouriteAnime({int page = 1}) async {
    const String query = """
      query (\$page: Int) {
        Page(page: \$page, perPage: 40) {
          media(type: ANIME, sort: FAVOURITES_DESC, isAdult: false) {
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
            genres
            status
            averageScore
            favourites
          }
        }
      }
    """;

    final response = await ApiService.fetchAnime(query, {"page": page});
    if (response != null && response['data'] != null) {
      var animeList =
          response['data']['Page']['media']
              .map<AnimeModel>((item) => AnimeModel.fromJson(item))
              .toList();
      mostFavourite.assignAll(animeList);
    }
  }
}
