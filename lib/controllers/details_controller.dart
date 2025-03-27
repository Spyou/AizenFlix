import 'package:anilist_test/models/anime_detail_model.dart';
import 'package:anilist_test/models/anime_model.dart';
import 'package:anilist_test/models/cast_model.dart';
import 'package:anilist_test/services/graphql_service.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DetailsController extends GetxController {
  var animeDetails = Rxn<AnimeDetailModel>();
  var similarAnime = <AnimeModel>[].obs;
  var relatedAnime = <AnimeModel>[].obs;
  var castList = <CastModel>[].obs;
  var isLoading = true.obs;

  void fetchAnimeDetails(int animeId) async {
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
}
