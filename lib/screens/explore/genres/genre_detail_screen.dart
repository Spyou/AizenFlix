import 'package:anilist_test/screens/detail%20screen/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/genre_controller.dart';

class GenreDetailScreen extends StatelessWidget {
  final String genre;
  final GenreController controller = Get.put(GenreController());

  GenreDetailScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    controller.fetchAnimeByGenre(genre); // Fetch first page

    return Scaffold(
      appBar: AppBar(
        title: Text(
          genre,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.animeList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoading.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.fetchMoreAnime();
            }
            return false;
          },
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              childAspectRatio: 0.6,
            ),
            itemCount: controller.animeList.length,
            itemBuilder: (context, index) {
              var anime = controller.animeList[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => DetailScreen(animeId: anime['id']));
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
                          imageUrl: anime['coverImage']['large'],
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
                        anime['title']['english'] ??
                            anime['title']['romaji'] ??
                            "Unknown",
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

// Column(
//                   children: [
//                     Image.network(
//                       anime['coverImage']['large'],
//                       height: 120,
//                       fit: BoxFit.cover,
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       anime['title']['romaji'] ?? 'Unknown',
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
