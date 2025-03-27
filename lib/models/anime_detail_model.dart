import 'package:anilist_test/models/anime_model.dart';
import 'package:anilist_test/models/cast_model.dart';

class AnimeDetailModel {
  final int id;
  final String title;
  final String? imageUrl;
  final String? bannerImage;
  final String? description;
  final int? episodes;
  final String? status;
  final List<String> genres;
  final int? averageScore;
  final String? studio;
  final String? trailerUrl;
  final List<AnimeModel> similarAnime;
  final List<AnimeModel> relatedAnime;
  final List<CastModel> castList;

  AnimeDetailModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.bannerImage,
    this.description,
    this.episodes,
    this.status,
    required this.genres,
    this.averageScore,
    this.studio,
    this.trailerUrl,
    required this.similarAnime,
    required this.relatedAnime,
    required this.castList,
  });

  factory AnimeDetailModel.fromJson(Map<String, dynamic> json) {
    // ✅ Extract Similar Anime
    List<AnimeModel> similarAnime = [];
    if (json['recommendations']?['edges'] != null) {
      similarAnime =
          (json['recommendations']['edges'] as List)
              .map(
                (edge) =>
                    AnimeModel.fromJson(edge['node']['mediaRecommendation']),
              )
              .toList();
    }

    // ✅ Extract Related Anime
    List<AnimeModel> relatedAnime = [];
    if (json['relations']?['edges'] != null) {
      relatedAnime =
          (json['relations']['edges'] as List)
              .map((edge) => AnimeModel.fromJson(edge['node']))
              .toList();
    }

    // ✅ Extract Cast (Voice Actors)
    List<CastModel> castList = [];
    if (json['characters']?['edges'] != null) {
      castList =
          (json['characters']['edges'] as List)
              .map(
                (edge) =>
                    edge['voiceActors'].isNotEmpty
                        ? CastModel.fromJson(edge['voiceActors'][0])
                        : CastModel(),
              )
              .toList();
    }

    return AnimeDetailModel(
      id: json['id'] ?? 0,
      title: json['title']['romaji'] ?? "Unknown",
      imageUrl: json['coverImage']?['large'],
      bannerImage: json['bannerImage'],
      description: json['description'],
      episodes: json['episodes'],
      status: json['status'],
      genres: (json['genres'] as List?)?.map((e) => e as String).toList() ?? [],
      averageScore: json['averageScore'],
      studio:
          json['studios']['nodes'].isNotEmpty
              ? json['studios']['nodes'][0]['name']
              : "Unknown",
      trailerUrl:
          json['trailer'] != null && json['trailer']['site'] == 'youtube'
              ? 'https://www.youtube.com/watch?v=${json['trailer']['id']}'
              : null,
      similarAnime: similarAnime,
      relatedAnime: relatedAnime,

      castList: castList,
    );
  }
}
