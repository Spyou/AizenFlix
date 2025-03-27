import 'package:anilist_test/screens/detail%20screen/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_controller.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final SearchControllerHero searchController = Get.put(SearchControllerHero());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Search Anime",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: searchController.updateQuery,
              decoration: InputDecoration(
                fillColor: const Color.fromARGB(255, 30, 30, 30),
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear_rounded),
                  onPressed: () {
                    searchController.searchQuery.value = "";
                  },
                ),
                contentPadding: EdgeInsets.all(8),
                hintText: "Search...",
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (searchController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (searchController.searchResults.isEmpty) {
                return Center(child: Text("No results found"));
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6,
                ),
                itemCount: searchController.searchResults.length,
                itemBuilder: (context, index) {
                  final anime = searchController.searchResults[index];
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
              );
            }),
          ),
        ],
      ),
    );
  }
}




// Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.vertical(
//                                 top: Radius.circular(10),
//                               ),
//                               child: Image.network(
//                                 anime['coverImage']['large'],
//                                 fit: BoxFit.cover,
//                                 errorBuilder:
//                                     (context, error, stackTrace) =>
//                                         Icon(Icons.image_not_supported),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.all(4),
//                             child: Text(
//                               anime['title']['english'] ??
//                                   anime['title']['romaji'] ??
//                                   "Unknown",
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),