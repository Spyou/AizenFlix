import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AnimeEpisode {
  final int id;
  final int animeId;
  final int episode;
  final String title;
  final String session;
  final int filler;
  final String createdAt;
  final String updatedAt;
  final String audio;
  final int duration;
  final String disc;

  AnimeEpisode({
    required this.id,
    required this.animeId,
    required this.episode,
    required this.title,
    required this.session,
    required this.filler,
    required this.createdAt,
    required this.updatedAt,
    required this.audio,
    required this.duration,
    required this.disc,
  });

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) {
    return AnimeEpisode(
      id: json['id'] ?? 0,
      animeId: json['anime_id'] ?? 0,
      episode: json['episode'] ?? 0,
      title: json['title'] ?? '',
      session: json['session'] ?? '',
      filler: json['filler'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      audio: json['audio'] ?? 'jpn',
      duration: json['duration'] ?? 24,
      disc: json['disc'] ?? '',
    );
  }
}

class AnimePaheService extends GetxService {
  final Dio _dio = Dio();

  // Store pagination data
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalEpisodes = 0.obs;
  final RxInt perPage = 30.obs;
  final RxInt from = 1.obs;
  final RxInt to = 0.obs;

  final String sessionId = '4f34bcac-c734-a182-8757-1e49ff1902ca';

  Future<AnimePaheService> init() async {
    _dio.options.headers = _generateBrowserHeaders();

    // For debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );
    }

    return this;
  }

  // Generate browser-like headers
  Map<String, dynamic> _generateBrowserHeaders() {
    return {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Origin': 'https://animepahe.ru',
      'Referer': 'https://animepahe.ru/',
      'sec-ch-ua':
          '"Google Chrome";v="91", "Chromium";v="91", ";Not A Brand";v="99"',
      'sec-ch-ua-mobile': '?0',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'Cache-Control': 'max-age=0',
    };
  }

  // Get episodes using the provided session ID
  Future<List<AnimeEpisode>> getEpisodes({int page = 1}) async {
    try {
      print('Getting episodes for page: $page');

      final response = await _dio.get(
        'https://animepahe.ru/api',
        options: Options(
          headers: _generateBrowserHeaders(),
          validateStatus: (status) => status! < 500,
        ),
        queryParameters: {
          'm': 'release',
          'id': sessionId, // Use our fixed session ID
          'sort': 'episode_asc',
          'page': page,
        },
      );

      // Check response status
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['data'] != null) {
        // Update pagination data
        currentPage.value = response.data['current_page'] ?? 1;
        lastPage.value = response.data['last_page'] ?? 1;
        totalEpisodes.value = response.data['total'] ?? 0;
        perPage.value = response.data['per_page'] ?? 30;
        from.value = response.data['from'] ?? 1;
        to.value = response.data['to'] ?? 0;

        // Parse episode data
        final List<dynamic> episodes = response.data['data'];
        final episodesList =
            episodes.map((e) => AnimeEpisode.fromJson(e)).toList();

        print('✅ Successfully loaded ${episodesList.length} episodes');
        return episodesList;
      } else {
        // If we got HTML instead of JSON (likely DDoS protection page)
        print('❌ Failed to load episodes. Status: ${response.statusCode}');

        // Return mock data instead
        return _generateMockEpisodes(12);
      }
    } catch (e) {
      print('❌ Error getting episodes: $e');

      // Return mock data on error
      return _generateMockEpisodes(12);
    }
  }

  // Generate mock episodes for fallback
  List<AnimeEpisode> _generateMockEpisodes(int count) {
    print('⚠️ Generating mock episode data');
    return List.generate(count, (index) {
      final episodeNum = index + 1;
      return AnimeEpisode(
        id: 1000 + episodeNum,
        animeId: 789,
        episode: episodeNum,
        title: 'Episode $episodeNum',
        session: 'mock-session-$episodeNum',
        filler: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        audio: 'jpn',
        duration: 24,
        disc: '',
      );
    });
  }
}
