import 'package:flutter/material.dart';

// Light Mode
const lightBGColor = Colors.white;
const lightPrimaryColor = Color(0xFFD90166);
const lightAppBarColor = Colors.white;
const lighttextColor = Colors.black;
const lightBoxColor = Color(0xFFF5F5F5);
const lightExternalTextColor = Colors.black54;

// Dark Mode

const darkBGColor = Colors.black;
const darkPrimaryColor = Color(0xFFFFD500);
const darkAppBarColor = Colors.black;
const darkTextColor = Colors.white;
const darkBoxColor = Color.fromARGB(255, 34, 34, 34);
const darkExternalTextColor = Colors.white70;

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/details_controller.dart';
// import '../models/anime_detail_model.dart';

// class DetailScreen extends StatefulWidget {
//   final int animeId;
//   const DetailScreen({super.key, required this.animeId});

//   @override
//   _DetailScreenState createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   final DetailsController controller = Get.put(DetailsController());

//   late ScrollController _scrollController;
//   bool _isAppBarCollapsed = false;

//   @override
//   void initState() {
//     super.initState();
//     controller.fetchAnimeDetails(widget.animeId);

//     _scrollController = ScrollController();
//     _scrollController.addListener(() {
//       if (_scrollController.offset > 200 && !_isAppBarCollapsed) {
//         setState(() {
//           _isAppBarCollapsed = true;
//         });
//       } else if (_scrollController.offset <= 200 && _isAppBarCollapsed) {
//         setState(() {
//           _isAppBarCollapsed = false;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final AnimeDetailModel? anime = controller.animeDetails.value;
//         if (anime == null) {
//           return Center(child: Text("Failed to load details"));
//         }

//         return CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // ✅ Collapsing AppBar
//             SliverAppBar(
//               expandedHeight: 300,
//               pinned: true,
//               floating: false,
//               flexibleSpace: FlexibleSpaceBar(
//                 title:
//                     _isAppBarCollapsed
//                         ? Text(
//                           anime.title,
//                           style: TextStyle(
//                             color: theme.onPrimary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         )
//                         : null,
//                 background: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     CachedNetworkImage(
//                       imageUrl:
//                           anime.bannerImage ??
//                           "https://images8.alphacoders.com/138/1385278.png",
//                       fit: BoxFit.cover,
//                       errorWidget:
//                           (context, url, error) =>
//                               Icon(Icons.error, color: Colors.red),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.black.withOpacity(0.7),
//                             Colors.transparent,
//                           ],
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ✅ Anime Info Section
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ✅ Anime Title
//                     Text(
//                       anime.title,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),

//                     // ✅ Anime Genres
//                     Text(
//                       anime.genres.take(3).join(", "), // Show only 3 genres
//                       style: TextStyle(color: Colors.white54, fontSize: 14),
//                     ),
//                     SizedBox(height: 8),

//                     // ✅ Episodes & Status
//                     Row(
//                       children: [
//                         Icon(Icons.play_circle_fill, color: Colors.red),
//                         SizedBox(width: 5),
//                         Text(
//                           "Episodes: ${anime.episodes ?? "N/A"}",
//                           style: TextStyle(fontSize: 14),
//                         ),

//                         SizedBox(width: 20),

//                         Icon(Icons.info, color: Colors.blue),
//                         SizedBox(width: 5),
//                         Text(anime.status!, style: TextStyle(fontSize: 14)),
//                       ],
//                     ),
//                     SizedBox(height: 10),

//                     // ✅ Anime Description
//                     Text(
//                       anime.description!.replaceAll("<br>", ""),
//                       style: TextStyle(fontSize: 14, color: Colors.white70),
//                     ),
//                     SizedBox(height: 20),

//                     // ✅ Similar Anime
//                     _buildSectionTitle("Similar Anime"),
//                     _buildHorizontalList(controller.similarAnime),

//                     // ✅ Related Anime
//                     _buildSectionTitle("Related Anime"),
//                     Obx(() {
//                       return _buildHorizontalList(controller.relatedAnime);
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 8),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildHorizontalList(DetailsController animeList) {
//     if (animeList) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return SizedBox(
//       height: 180,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: animeList.length,
//         itemBuilder: (context, index) {
//           final anime = animeList[index];
//           return GestureDetector(
//             onTap: () {
//               Get.to(() => DetailScreen(animeId: anime.id));
//             },
//             child: Container(
//               width: 120,
//               margin: EdgeInsets.symmetric(horizontal: 8),
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: CachedNetworkImage(
//                       imageUrl: anime,
//                       width: 120,
//                       height: 150,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     anime.title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
