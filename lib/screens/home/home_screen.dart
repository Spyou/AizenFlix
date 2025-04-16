import 'package:anilist_test/controllers/user_controller.dart';
import 'package:anilist_test/screens/search/search_screen.dart';
import 'package:anilist_test/screens/setting/setting_screen.dart';
import 'package:anilist_test/widgets/banner_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/anime_model.dart';
import '../detail screen/detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController scrollController = Get.put(ScrollController());
  final HomeController homeController = Get.put(HomeController());
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.put(UserController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          final user = Get.find<UserController>().userData;
          return [
            SliverAppBar(
              title: Text(
                "AIZENFLIX",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                  fontFamily: GoogleFonts.contrailOne().fontFamily,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 30,
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(
                            BorderSide(color: Colors.white24),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(48, 94, 94, 94),
                          ),
                        ),
                        icon: Icon(Icons.search_rounded),
                        onPressed: () {
                          // Get.to(() => PopularAnimeScreen());
                          Get.to(() => SearchScreen());
                          // authController.logout();
                        },
                      ),
                      SizedBox(width: 10),
                      Obx(() {
                        final user = Get.find<UserController>().userData;

                        if (user.isEmpty) {
                          return CircleAvatar(
                            radius: 30,
                            child: Icon(
                              Icons.person,
                              size: 30,
                            ), // Default icon when user data isxx not loaded
                          );
                        }

                        return InkWell(
                          onTap: () {
                            // authController.logout();
                            // Get.to(() => MyListScreen());
                            Get.to(() => SettingScreen());
                          },
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 21,
                              backgroundImage: NetworkImage(
                                user['avatar']['large'] ?? "",
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              floating: true,
              snap: true,
              centerTitle: false,
            ),
          ];
        },
        body: Obx(
          () => ListView(
            children: [
              // 🔥 Banner Slider
              BannerSlider(animeList: homeController.trendingAnime),

              // 🔥 Recently Updated Anime
              _buildSectionTitle("Recently Updated"),
              _buildHorizontalList(homeController.recentlyUpdatedAnime),

              // 🔥 Trending Anime
              _buildSectionTitle("Trending Now"),
              _buildHorizontalList(homeController.trendingAnime),

              // ✅ Top Rated Anime Section
              _buildSectionTitle('Top Rated'),
              Obx(() => _buildHorizontalList(homeController.topRatedAnime)),

              // 🎬 Trending Movies
              _buildSectionTitle("Trending Movies"),
              Obx(
                () => _buildHorizontalList(homeController.trendingMovies),
              ), // ✅ Display Trending Movies
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 25.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalList(List<AnimeModel> animeList) {
    var theme = Theme.of(Get.context!).colorScheme;
    if (animeList.isEmpty) return Center(child: CircularProgressIndicator());

    return SizedBox(
      height: 200, // Increased height to fit text
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        scrollDirection: Axis.horizontal,
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await Get.to(
                () => DetailScreen(animeId: animeList[index].id),
                transition: Transition.fadeIn,
              );
              await userController.fetchUserAnimeList();
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
                      imageUrl: animeList[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // ✅ Title at the Bottom
                SizedBox(
                  width: 110,
                  child: Text(
                    animeList[index].title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: theme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
