import 'package:anilist_test/utils/html_parser.dart';

class AnimeModel {
  final int id;
  final String title;
  final String? englishTitle;
  final String description;
  final String imageUrl;
  final String? bannerImage;
  final double rating;
  final List<String> genres;
  final String status;
  final int episodes;
  final String studio;
  final String? trailerUrl;
  final int updatedAt;
  final bool isAdult;
  final int year;
  final String format;
  int? progress;

  AnimeModel({
    required this.id,
    required this.title,
    this.englishTitle,
    required this.description,
    required this.imageUrl,
    this.bannerImage,
    required this.rating,
    required this.genres,
    required this.status,
    required this.episodes,
    required this.studio,
    this.trailerUrl,
    required this.updatedAt,
    required this.isAdult,
    required this.year,
    required this.format,
    this.progress,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    print("🔹 Parsing Anime: $json");

    return AnimeModel(
      id: json['id'] ?? 0,
      title: HtmlParser.removeHtmlTags(json['title']?['romaji'] ?? 'No Title'),
      englishTitle: HtmlParser.removeHtmlTags(json['title']?['english'] ?? ''),
      description: HtmlParser.removeHtmlTags(
        json['description'] ?? 'No Description Available',
      ),
      imageUrl:
          json['coverImage']?['large'] ?? "https://via.placeholder.com/150",
      bannerImage:
          (json['bannerImage'] != null && json['bannerImage'].isNotEmpty)
              ? json['bannerImage']
              : json['coverImage']['large'] ??
                  'https://images8.alphacoders.com/138/1385278.png', // ✅ Fallback Image
      rating:
          (json['averageScore'] != null) ? json['averageScore'] / 10.0 : 0.0,
      genres:
          (json['genres'] as List?)?.map((g) => g.toString()).toList() ??
          [], // Handle null genres
      status: json['status'] ?? 'Unknown',
      episodes:
          json['episodes'] != null
              ? json['episodes'] as int
              : 0, // Fix crash if null
      updatedAt:
          json['updatedAt'] != null
              ? json['updatedAt'] as int
              : 0, // Fix crash if null
      isAdult: json['isAdult'] ?? false,
      year: json['seasonYear'] ?? 0,
      format: json['format'] ?? 'Unknown',
      progress: json['progress'], // Map progress from JSON
      studio:
          (json['studios']?['nodes'] != null &&
                  json['studios']['nodes'].isNotEmpty)
              ? json['studios']['nodes'][0]['name']
              : 'Unknown',
      trailerUrl:
          (json['trailer'] != null && json['trailer']['site'] == 'youtube')
              ? 'https://www.youtube.com/watch?v=${json['trailer']['id']}'
              : null,
    );
  }
}
