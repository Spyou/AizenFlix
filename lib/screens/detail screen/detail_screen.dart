import 'package:anilist_test/controllers/user_controller.dart';
import 'package:anilist_test/models/anime_model.dart';
import 'package:anilist_test/models/episode_list_model.dart';
import 'package:anilist_test/screens/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/details_controller.dart';
import '../../models/anime_detail_model.dart';

class DetailScreen extends StatefulWidget {
  final int animeId;
  const DetailScreen({super.key, required this.animeId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  final DetailsController controller = Get.put(DetailsController());
  final UserController userController = Get.find<UserController>();

  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchAnimeDetails(widget.animeId).then((_) {
        // Fetch additional data after the initial fetch
        controller.fetchAnimePaheEpisodes(
          controller.animeDetails.value?.title ?? "",
        );
      });
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 250 && !_isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = true;
        });
      } else if (_scrollController.offset <= 250 && _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = false;
        });
      }
    });

    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    if (Get.isRegistered<DetailsController>()) {
      Get.delete<DetailsController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: Obx(
        () => FloatingActionButton(
          backgroundColor: theme.primary,
          child: Icon(
            color: theme.onSecondary,
            controller.sortOrder.value == 'episode_asc'
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
          onPressed: () {
            // Toggle between asc and desc
            if (controller.sortOrder.value == 'episode_asc') {
              controller.sortOrder.value = 'episode_desc';
            } else {
              controller.sortOrder.value = 'episode_asc';
            }

            // Reload episodes with new order
            controller.fetchAnimePaheEpisodes(controller.lastTitle ?? '');
          },
        ),
      ),

      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final AnimeDetailModel? anime = controller.animeDetails.value;
        if (anime == null) {
          return Center(
            child: Text(
              "Failed to load details",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.black,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.shareUri(
                          Uri.parse(
                            anime.trailerUrl ??
                                "https://anilist.co/anime/${anime.id}",
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.bookmark_border_rounded),
                      onPressed: () {
                        showAddAnimeDialog(anime.id);
                      },
                    ),
                  ],
                  title:
                      _isAppBarCollapsed
                          ? Text(
                            anime.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                anime.bannerImage ?? anime.imageUrl!,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                  Colors.black,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          left: 20,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: anime.imageUrl!,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 150,
                                    child: Text(
                                      anime.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Episodes: ${anime.episodes ?? "N/A"}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Genres: ${anime.genres.take(3).join(", ")}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: Container(
                      color: Colors.black,
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        dividerColor: const Color.fromARGB(83, 255, 255, 255),
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: theme.primary,
                        tabs: [
                          Tab(text: "Episodes"),
                          Tab(text: "Cast"),
                          Tab(text: "Similar"),
                          Tab(text: "Related"),
                          Tab(text: "Details"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildEpisodesTab(),
              buildVerticalCastList(),
              Obx(() {
                if (controller.similarAnime.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return buildVerticalGridList(controller.similarAnime);
              }),

              Obx(() {
                if (controller.similarAnime.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return buildVerticalGridList(controller.relatedAnime);
              }),

              buildMoreDetailsTab(anime),
            ],
          ),
        );
      }),
    );
  }

  // ✅ Section Title
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ✅ Episode Tab Widget using your Episode Model
  Widget _buildEpisodesTab() {
    return Obx(() {
      final List<Data> episodes = controller.animePaheEpisodes.cast<Data>();

      if (episodes.isEmpty) {
        return const Center(
          child: Text(
            "No episodes found",
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!controller.isFetchingMore.value &&
              controller.hasMoreEpisodes.value &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.fetchAnimePaheEpisodes(
              controller.lastTitle!,
              loadMore: true,
            );
          }
          return true;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: episodes.length + 1,
          itemBuilder: (context, index) {
            if (index == episodes.length) {
              return Obx(
                () =>
                    controller.isFetchingMore.value
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : const SizedBox.shrink(),
              );
            }

            final episode = episodes[index];
            return InkWell(
              onTap: () {
                Get.to(
                  () => VideoPlayerScreen(
                    animeSession: controller.animeSessionId.value,
                    episodeSession: episode.session!,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: episode.snapshot ?? "",
                            width: 130,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Episode ${episode.episode}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              episode.duration?.replaceFirst(
                                    RegExp(r'^00:'),
                                    '',
                                  ) ??
                                  "N/A",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      episode.disc ?? "No description available",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ✅ Vertical Cast List
  Widget buildVerticalCastList() {
    return Obx(() {
      if (controller.castList.isEmpty) {
        return Center(
          child: Text(
            "No cast data available",
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: controller.castList.length,
        itemBuilder: (context, index) {
          final cast = controller.castList[index];

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // ✅ Character Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: cast.characterImage ?? "",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(width: 15),

                // ✅ Character & Voice Actor Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character Name
                    Text(
                      cast.characterName ?? "Unknown",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 4),

                    // Voice Actor Name
                    if (cast.voiceActorName != null) ...[
                      Text(
                        "V/A: ${cast.voiceActorName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                Spacer(),

                // ✅ Voice Actor Image
                if (cast.voiceActorImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: cast.voiceActorImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  // ✅ More Details Tab
  Widget buildMoreDetailsTab(AnimeDetailModel anime) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle("Description"),
            Text(
              anime.description?.replaceAll("<br>", "") ??
                  "No description available",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 20),
            // buildSectionTitle("Status"),
            // Text(
            //   anime.trailerUrl ?? "N/A",
            //   style: TextStyle(fontSize: 14, color: Colors.white70),
            // ),
            // buildSectionTitle("Genres"),
            // Container(
            //   color: Colors.red,
            //   height: 130,
            //   width: double.infinity,
            //   child: GridView.builder(
            //     padding: EdgeInsets.all(10),
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 3,
            //       crossAxisSpacing: 10,
            //       mainAxisSpacing: 10,
            //       childAspectRatio: 2.5,
            //     ),
            //     itemCount: anime.genres.length,
            //     itemBuilder: (context, index) {
            //       return Chip(
            //         label: Text(
            //           anime.genres[index],
            //           style: TextStyle(color: Colors.white),
            //         ),
            //         backgroundColor: Colors.grey[800],
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         padding: EdgeInsets.symmetric(horizontal: 10),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildVerticalGridList(List<AnimeModel> animeList) {
    if (animeList.isEmpty) {
      return Center(
        child: Image.network(
          "https://image.winudf.com/v2/image1/Y29tLm5vdGhpbmcuc21hcnRjZW50ZXJfaWNvbl8xNjY3Mjc0NTAxXzAwNg/icon.png?w=156&fakeurl=1",
          width: 100,
          height: 100,
          filterQuality: FilterQuality.high,
          fit: BoxFit.cover,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];

        return InkWell(
          splashFactory: InkRipple.splashFactory,
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // ✅ Remove the previous instance of DetailsController
            if (Get.isRegistered<DetailsController>()) {
              Get.delete<DetailsController>(force: true);
            }

            // ✅ Navigate to a new DetailScreen with a fresh instance
            Get.to(
              transition: Transition.fadeIn,
              () => DetailScreen(animeId: anime.id),
              binding: BindingsBuilder(() {
                Get.put(DetailsController());
              }),
              preventDuplicates: false, // ✅ Ensures a new controller is created
            );
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
                    imageUrl: anime.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: Text(
                  anime.title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
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
    );
  }

  void showAddAnimeDialog(int animeId) {
    final UserController userController = Get.find<UserController>();

    Get.defaultDialog(
      title: "Add Anime to List",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      content: Column(
        children: [
          statusButton("Watching", "CURRENT", animeId),
          statusButton("Completed", "COMPLETED", animeId),
          statusButton("Paused", "PAUSED", animeId),
          statusButton("Dropped", "DROPPED", animeId),
          statusButton("Planning", "PLANNING", animeId),
        ],
      ),

      textConfirm: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.grey,
      onConfirm: () => Get.back(),
    );
  }

  /// ✅ Helper function to create buttons inside dialog
  Widget statusButton(String label, String status, int animeId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () async {
          await userController.addAnime(animeId, status);
          Get.back(result: true);
        },
        child: Text(label),
      ),
    );
  }
}
