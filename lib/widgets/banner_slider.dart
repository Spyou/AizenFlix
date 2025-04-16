import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/anime_model.dart';
import '../screens/detail screen/detail_screen.dart';

class BannerSlider extends StatefulWidget {
  final List<AnimeModel> animeList;
  const BannerSlider({super.key, required this.animeList});

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    final CarouselSliderController carouselController =
        CarouselSliderController(); // ✅ Correct usage
    List<AnimeModel> bannerAnime =
        widget.animeList.take(6).toList(); // Show only 6

    return Column(
      children: [
        // 🔥 Banner Carousel
        CarouselSlider(
          carouselController: carouselController,

          options: CarouselOptions(
            height: 240, // Bigger height for better visuals
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            viewportFraction: 1.0, // Full width
          ),
          items:
              bannerAnime.map((anime) {
                debugPrint("Genres for ${anime.title}: ${anime.genres}");
                debugPrint("Banner Image URL: ${anime.bannerImage}");
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      transition: Transition.fadeIn,

                      () => DetailScreen(animeId: anime.id),
                    );
                  },
                  child: Stack(
                    children: [
                      // ✅ Background Banner Image
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                              theme.surface.withOpacity(0.5),
                              BlendMode.darken,
                            ),
                            image: CachedNetworkImageProvider(
                              anime.bannerImage ??
                                  "https://images8.alphacoders.com/138/1385278.png",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // ✅ Dark Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.surface, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),

                      // Anime Details
                      Positioned(
                        bottom: 40,
                        left: 15,
                        right: 15,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Anime Cover Image
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    anime.imageUrl,
                                    width: 100,
                                    height: 145,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Episodes Count
                                Text(
                                  "Episodes: ${anime.episodes ?? "N/A"}",
                                  style: TextStyle(
                                    color: theme.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 15),

                            // Anime Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    anime.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 2),

                                  // Description (Short)
                                  Text(
                                    anime.description
                                        .replaceAll("<br>", "")
                                        .replaceAll("<i>", "")
                                        .replaceAll("</i>", ""),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 3),
                                  // Status (Releasing/Finished)
                                  Text(
                                    anime.status,
                                    style: TextStyle(
                                      color: theme.primary.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 10),

                                  // Genres
                                  Text(
                                    (anime.genres.isNotEmpty)
                                        ? anime.genres.take(3).join(" • ")
                                        : "No Genres Available",
                                    style: TextStyle(
                                      color: theme.secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),

        // Page Indicator (Bottom Dots)
        SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: bannerAnime.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: theme.primary,
            dotColor: theme.onPrimary.withOpacity(0.5),
          ),
          onDotClicked: (index) {
            carouselController.animateToPage(index);
          },
        ),
      ],
    );
  }
}
