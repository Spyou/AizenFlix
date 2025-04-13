import 'package:anilist_test/models/anime_detail_model.dart';
import 'package:anilist_test/models/anime_model.dart';
import 'package:anilist_test/models/cast_model.dart';
import 'package:anilist_test/models/episode_list_model.dart';
import 'package:anilist_test/services/graphql_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DetailsController extends GetxController {
  var animeDetails = Rxn<AnimeDetailModel>();
  var similarAnime = <AnimeModel>[].obs;
  var relatedAnime = <AnimeModel>[].obs;
  var castList = <CastModel>[].obs;
  var isLoading = true.obs;
  final animePaheEpisodes = [].obs;
  final dio = Dio();
  final RxString animeSessionId = ''.obs;

  fetchAnimeDetails(int animeId) async {
    print("Fetching details for anime ID: $animeId");

    isLoading.value = true;
    animeDetails.value = null;
    similarAnime.clear();
    relatedAnime.clear();
    castList.clear();
    update(); // ✅ Forces UI refresh

    final String query = """
    query {
      Media(id: $animeId, type: ANIME) {
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
        genres
        averageScore
        studios(isMain: true) {
          nodes {
            name
          }
        }

        # ✅ Fetch Similar Anime
        recommendations(sort: RATING_DESC, perPage: 10) {
          edges {
            node {
              mediaRecommendation {
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

        # ✅ Fetch Related Anime
        relations {
          edges {
            relationType
            node {
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

        # ✅ Fetch Cast (Voice Actors)
        characters {
          edges {
            node {
              id
              name {
                full
              }
              image {
                large
              }
            }
            voiceActors(language: JAPANESE) {
              id
              name {
                full
              }
              image {
                large
              }
            }
          }
        }
      }
    }
    """;

    final client = GraphQLService.getGraphQLClient();

    try {
      final result = await client.query(QueryOptions(document: gql(query)));

      if (result.hasException) {
        print("❌ Query Error: ${result.exception}");
        isLoading.value = false;
        return;
      }

      final animeData = result.data?['Media'];
      if (animeData != null) {
        print("✅ Anime details loaded: ${animeData['title']['romaji']}");

        animeDetails.value = AnimeDetailModel.fromJson(animeData);

        update(); // ✅ Ensures UI updates correctly

        // ✅ Extract Similar Anime
        if (animeData['recommendations'] != null) {
          List similarList = animeData['recommendations']['edges'] ?? [];
          similarAnime.assignAll(
            similarList
                .map((item) {
                  if (item['node'] != null &&
                      item['node']['mediaRecommendation'] != null) {
                    return AnimeModel.fromJson(
                      item['node']['mediaRecommendation'],
                    );
                  }
                })
                .whereType<AnimeModel>()
                .toList(),
          );
        }

        // ✅ Extract Related Anime
        if (animeData['relations'] != null) {
          List relatedList = animeData['relations']['edges'] ?? [];
          relatedAnime.assignAll(
            relatedList
                .map((item) {
                  if (item['node'] != null) {
                    return AnimeModel.fromJson(item['node']);
                  }
                })
                .whereType<AnimeModel>()
                .toList(),
          );
        }

        // ✅ Extract Cast List
        if (animeData['characters'] != null) {
          List castEdges = animeData['characters']['edges'] ?? [];
          castList.assignAll(
            castEdges
                .map((edge) {
                  if (edge != null) return CastModel.fromJson(edge);
                })
                .whereType<CastModel>()
                .toList(),
          );
        }

        print("🎭 Cast List Loaded: ${castList.length}");
        print("🎬 Similar Anime Loaded: ${similarAnime.length}");
        print("🔗 Related Anime Loaded: ${relatedAnime.length}");
      } else {
        print("❌ Error: animeData is null");
      }
    } catch (e) {
      print("🚨 Unexpected Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnimePaheEpisodes(String title) async {
    try {
      // Step 1: Search to get session
      final searchResponse = await dio.get(
        'https://animepahe.ru/api?m=search&q=$title',
        options: Options(
          headers: {
            'dnt': '1',
            "Cookie":
                '__ddg1_=XeUxbfS047EW6cQE2JgH; __ddgid_=1V4D1oKj9BEsa9Vn; __ddg2_=3GqHC62yLVyRCgbE; res=1080; aud=jpn; av1=0; __ddg9_=188.113.229.42; latest=6087; ann-fakesite=0; __ddg8_=IYo15fVJlfANjOv3; __ddg10_=1743708714; XSRF-TOKEN=eyJpdiI6InluK1dINmFaR25Uc3N3T2lXTThpdmc9PSIsInZhbHVlIjoiMitUQkx2TCtXbVJwVXdxYXh2WXlFVG44d0VJRGhWVUl5Zmh1eEZuSk9iWUIyTkZyM3JGMWNiSDNsR0ZJMFlTOThPUm9nNXNTU2c5aHNuZFJ2N3dhZ1J6Z3FPUmg4dVBUY3VSOW1wTGtIK096MVhvdGJtWXlwVFBTRExnZ1BLSFgiLCJtYWMiOiJlNDAxZjk1M2U0ODQ1N2M4MTYyNWNhMWYxOTdlMTg1MzQ3ZDc4NGY0NGY3NGFhY2QyZDQ2ZjM0MmI2YzJjNzM2IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5BaGZhaitSa210Tkk2N01nTlBzTUE9PSIsInZhbHVlIjoiWmpkTXFJSUE3eEZSMk1WVmNEME9iVEw5bXQyR1BOdnM1VnJrS0laYmRLcDYxaThZRDNmaDA3NzFpamQvaTVpZlJyLy9JRUhOWnBZZ0I0ZUloVFlNOEFlbmZ2VUErclhBOEVEVWJXUzZRQmppQksvSTVQQjhjR0F3bllrMGM3TnAiLCJtYWMiOiI0ODcxNjdhZDYxZTA4OWQ3YWU4YzA1MThiMjZiMjNlZjUyNTQwOGRkM2QyMGUxZGZmZDAzMDlhZTM0OWU4MjUxIiwidGFnIjoiIn0%3D',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
          },
        ),
      );

      final searchData = searchResponse.data['data'];
      if (searchData == null || searchData.isEmpty) {
        print('❌ No anime found');
        animePaheEpisodes.clear();
        return;
      }

      final sessionId = searchData[0]['session'];
      animeSessionId.value = sessionId; // 👉 store animeSession here

      // Step 2: Fetch episodes using session
      final episodeResponse = await dio.get(
        'https://animepahe.ru/api?m=release&id=$sessionId&sort=episode_asc&page=1&per_page=50',
        options: Options(
          headers: {
            'dnt': '1',
            "Cookie":
                '__ddg1_=XeUxbfS047EW6cQE2JgH; __ddgid_=1V4D1oKj9BEsa9Vn; __ddg2_=3GqHC62yLVyRCgbE; res=1080; aud=jpn; av1=0; __ddg9_=188.113.229.42; latest=6087; ann-fakesite=0; __ddg8_=IYo15fVJlfANjOv3; __ddg10_=1743708714; XSRF-TOKEN=eyJpdiI6InluK1dINmFaR25Uc3N3T2lXTThpdmc9PSIsInZhbHVlIjoiMitUQkx2TCtXbVJwVXdxYXh2WXlFVG44d0VJRGhWVUl5Zmh1eEZuSk9iWUIyTkZyM3JGMWNiSDNsR0ZJMFlTOThPUm9nNXNTU2c5aHNuZFJ2N3dhZ1J6Z3FPUmg4dVBUY3VSOW1wTGtIK096MVhvdGJtWXlwVFBTRExnZ1BLSFgiLCJtYWMiOiJlNDAxZjk1M2U0ODQ1N2M4MTYyNWNhMWYxOTdlMTg1MzQ3ZDc4NGY0NGY3NGFhY2QyZDQ2ZjM0MmI2YzJjNzM2IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5BaGZhaitSa210Tkk2N01nTlBzTUE9PSIsInZhbHVlIjoiWmpkTXFJSUE3eEZSMk1WVmNEME9iVEw5bXQyR1BOdnM1VnJrS0laYmRLcDYxaThZRDNmaDA3NzFpamQvaTVpZlJyLy9JRUhOWnBZZ0I0ZUloVFlNOEFlbmZ2VUErclhBOEVEVWJXUzZRQmppQksvSTVQQjhjR0F3bllrMGM3TnAiLCJtYWMiOiI0ODcxNjdhZDYxZTA4OWQ3YWU4YzA1MThiMjZiMjNlZjUyNTQwOGRkM2QyMGUxZGZmZDAzMDlhZTM0OWU4MjUxIiwidGFnIjoiIn0%3D',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
          },
        ),
      );

      final data = episodeResponse.data;
      if (data == null || data['data'] == null) {
        print("❌ No episode data returned");
        animePaheEpisodes.clear();
        return;
      }

      // Convert to List<Data>
      final model = EpisodeListModel.fromJson(data);
      animePaheEpisodes.assignAll(model.data ?? []);
      print('✅ Episodes loaded: ${animePaheEpisodes.length}');
    } catch (e) {
      print('❌ Error fetching episodes: $e');
      animePaheEpisodes.clear();
    }
  }
}
