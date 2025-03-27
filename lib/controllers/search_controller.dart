import 'package:get/get.dart';

import '../services/graphql_service.dart';

class SearchControllerHero extends GetxController {
  var searchQuery = ''.obs;
  var searchResults = [].obs;
  var isLoading = false.obs;

  void updateQuery(String query) {
    searchQuery.value = query;
    searchAnime();
  }

  void searchAnime() async {
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    List<dynamic> results = await GraphQLService.searchAnime(searchQuery.value);

    searchResults.value = results;
    isLoading.value = false;
  }
}
