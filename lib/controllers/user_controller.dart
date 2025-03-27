import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../services/graphql_service.dart';

class UserController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = true.obs;
  var userData = {}.obs;
  var userId = 0.obs;
  var errorMessage = "".obs;

  // Anime Lists
  var watchingList = [].obs;
  var completedList = [].obs;
  var pausedList = [].obs;
  var droppedList = [].obs;
  var planningList = [].obs;
  var favoritesList = [].obs;
  var allAnimeList = [].obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 7, vsync: this);
    fetchUserData();
    Future.delayed(Duration.zero, fetchUserAnimeList); // ✅ No more errors
    fetchUserFavorites(); // Fetch favorites separately
  }

  final authController = Get.find<AuthController>();

  /// ✅ Fetch user profile and anime lists
  Future<void> fetchUserData() async {
    isLoading(true);
    try {
      var user = await GraphQLService.fetchUserData();

      if (user != null) {
        userData.value = user;
        userId.value = user['id'];
        await fetchUserAnimeList(); // 👈 fetch anime lists
        await fetchUserFavorites(); // 👈 fetch favorites

        // Fetch anime lists
        await fetchUserAnimeList();
      } else {
        errorMessage.value = "No user data found.";
      }
    } catch (e) {
      errorMessage.value = "Error fetching user data.";
      print("❌ User Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Fetch user's categorized anime list
  Future<void> fetchUserAnimeList() async {
    if (authController.userId.value == 0) {
      print("🚨 ERROR: User ID is 0, fetching failed.");
      return;
    }

    try {
      print(
        "🔹 Fetching Anime List for User ID: ${authController.userId.value}",
      );

      var animeLists = await GraphQLService.fetchUserAnimeList(
        authController.userId.value,
      );

      if (animeLists.isNotEmpty) {
        allAnimeList.value =
            animeLists.expand((list) => list['entries'] ?? []).toList();

        watchingList.value =
            animeLists
                .where((list) => list['name'] == "Watching")
                .expand((list) => list['entries'])
                .toList();
        completedList.value =
            animeLists.firstWhereOrNull(
              (list) => list['name'] == "Completed",
            )?['entries'] ??
            [];
        pausedList.value =
            animeLists.firstWhereOrNull(
              (list) => list['name'] == "Paused",
            )?['entries'] ??
            [];
        droppedList.value =
            animeLists.firstWhereOrNull(
              (list) => list['name'] == "Dropped",
            )?['entries'] ??
            [];
        planningList.value =
            animeLists.firstWhereOrNull(
              (list) => list['name'] == "Planning",
            )?['entries'] ??
            [];

        print("✅ Anime Lists Successfully Loaded!");
      } else {
        print("⚠️ WARNING: No Anime Found for This User.");
      }
    } catch (e) {
      print("❌ Error Fetching User Anime List: $e");
    }
  }

  Future<void> fetchUserFavorites() async {
    try {
      print("🔹 Fetching User Favorites...");
      var favorites = await GraphQLService.fetchUserFavorites(page: 1);

      if (favorites.isNotEmpty) {
        favoritesList.value = favorites;
        print("✅ Favorites Loaded: ${favorites.length}");
      } else {
        print("⚠️ WARNING: No Favorites Found.");
      }
    } catch (e) {
      print("❌ Error Fetching Favorites: $e");
    }
  }

  Future<void> addAnime(int animeId, String status) async {
    final Map<String, String> statusMapping = {
      "WATCHING": "CURRENT",
      "COMPLETED": "COMPLETED",
      "PAUSED": "PAUSED",
      "DROPPED": "DROPPED",
      "PLANNING": "PLANNING",
    };

    if (!statusMapping.containsKey(status)) return;

    final gqlStatus = statusMapping[status]!;

    const String mutation = """
    mutation (\$mediaId: Int, \$status: MediaListStatus) {
      SaveMediaListEntry(mediaId: \$mediaId, status: \$status) {
        id
        status
      }
    }
  """;

    final result = await GraphQLService.clientNotifier.value.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'mediaId': animeId, 'status': gqlStatus},
      ),
    );

    if (result.hasException) {
      print("❌ GraphQL Error: ${result.exception.toString()}");
      return;
    }

    print("✅ Successfully added anime with status: $gqlStatus");

    // ✅ This is IMPORTANT
    await fetchUserAnimeList();
    await fetchUserFavorites();
    update(); // ⬅️ Notify GetBuilder or Obx if needed
  }
}
