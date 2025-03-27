import 'package:anilist_test/controllers/home_controller.dart';
import 'package:anilist_test/screens/detail%20screen/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularAnimeScreen extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  PopularAnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (homeController.popularAnime.isEmpty &&
            homeController.isLoadingPopular.value) {
          return Center(
            child: CircularProgressIndicator(),
          ); // ✅ Show loading initially
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100 &&
                !homeController.isLoadingPopular.value &&
                homeController.hasMoreAnime.value) {
              homeController.fetchPopularAnime(isLoadMore: true);
            }
            return false;
          },
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: homeController.popularAnime.length + 1,
            itemBuilder: (context, index) {
              if (index == homeController.popularAnime.length) {
                return homeController.hasMoreAnime.value
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink(); // Hide if no more data
              }
              final anime = homeController.popularAnime[index];
              return GestureDetector(
                onTap: () => Get.to(() => DetailScreen(animeId: anime.id)),
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
                          imageUrl: anime.imageUrl,
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
                        anime.title,
                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
