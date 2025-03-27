import 'package:get/get.dart';

import '../services/graphql_service.dart';

class GenreController extends GetxController {
  var animeList = <dynamic>[].obs;
  var isLoading = false.obs;
  int currentPage = 1;
  String? currentGenre;

  void fetchAnimeByGenre(String genre) async {
    isLoading.value = true;
    currentGenre = genre;
    currentPage = 1;

    List<dynamic> anime = await GraphQLService.getAnimeByGenre(
      genre,
      currentPage,
    );
    animeList.value = anime;
    isLoading.value = false;
  }

  void fetchMoreAnime() async {
    if (isLoading.value) return;

    isLoading.value = true;
    currentPage++;

    List<dynamic> moreAnime = await GraphQLService.getAnimeByGenre(
      currentGenre!,
      currentPage,
    );
    animeList.addAll(moreAnime);
    isLoading.value = false;
  }

  @override
  void dispose() {
    animeList.clear();
    super.dispose();
  }
}
