import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:anilist_test/screens/detail%20screen/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.tabController.index = 0; // Always reset to Watching tab
      userController.fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "MY LIST",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (userController.errorMessage.isNotEmpty) {
          return Center(child: Text(userController.errorMessage.value));
        }

        return Column(
          children: [
            // User Profile Info
            _buildUserProfile(),

            // Tab Bar for Anime Lists
            TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              controller: userController.tabController,
              isScrollable: true,
              padding: EdgeInsets.symmetric(horizontal: 10),
              indicatorPadding: EdgeInsets.symmetric(vertical: 6),
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: "Watching (${userController.watchingList.length})"),
                Tab(text: "Completed (${userController.completedList.length})"),
                Tab(text: "Paused (${userController.pausedList.length})"),
                Tab(text: "Dropped (${userController.droppedList.length})"),
                Tab(text: "Planning (${userController.planningList.length})"),
                Tab(text: "Favorites (${userController.favoritesList.length})"),
                Tab(text: "All (${userController.allAnimeList.length})"),
              ],
            ),

            // Anime List View
            Expanded(
              child: TabBarView(
                controller: userController.tabController,
                children: [
                  _buildAnimeList(userController.watchingList),
                  _buildAnimeList(userController.completedList),
                  _buildAnimeList(userController.pausedList),
                  _buildAnimeList(userController.droppedList),
                  _buildAnimeList(userController.planningList),
                  _buildAnimeList(userController.favoritesList),
                  _buildAnimeList(userController.allAnimeList),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// ✅ User Profile UI
  Widget _buildUserProfile() {
    final user = Get.find<UserController>().userData;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              AuthController().logout();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[800],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: user['avatar']['large'],
                  fit: BoxFit.cover,
                  errorWidget:
                      (context, url, error) => Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['name'] ?? "Unknown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 4),
              Text(
                "Total Anime: ${user['statistics']['anime']['count']}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Episodes Watched: ${user['statistics']['anime']['episodesWatched']}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Anime List UI
  Widget _buildAnimeList(RxList animeList) {
    return Obx(() {
      if (animeList.isEmpty) {
        return Center(child: Text("No anime found"));
      }
      return GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          childAspectRatio: 0.6,
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index]['media'] ?? animeList[index];

          if (anime == null || anime['coverImage'] == null) {
            return Container(
              width: 120,
              height: 160,
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () async {
              final result = await Get.to(
                () => DetailScreen(animeId: anime['id']),
              );
              if (result == true) {
                await userController.fetchUserAnimeList();
                await userController.fetchUserFavorites();
              }
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 120,
                  height: 160,
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: anime['coverImage']['large'] ?? '',
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) =>
                              Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    anime['title']['romaji'],
                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
