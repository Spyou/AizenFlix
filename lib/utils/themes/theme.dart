import 'package:anilist_test/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Mode
var lightTheme = ThemeData(
  // fontFamily: 'Poppins',
  fontFamily: GoogleFonts.poppins().fontFamily,
  useMaterial3: true,
  scaffoldBackgroundColor: lightBGColor,
  colorScheme: const ColorScheme.light(
    surface: lightBGColor,
    primary: lightPrimaryColor,
    onPrimary: lighttextColor,
  ),
);

// Dark Mode
var darkTheme = ThemeData(
  // fontFamily: 'Poppins',
  fontFamily: GoogleFonts.poppins().fontFamily,
  scaffoldBackgroundColor: darkBGColor,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: darkBGColor,
    primary: darkPrimaryColor,
    onPrimary: darkTextColor,
  ),
);

// import 'package:anilist_test/controllers/details_controller.dart';
// import 'package:anilist_test/models/anime_model.dart';
// import 'package:anilist_test/models/cast_model.dart';
// import 'package:anilist_test/utils/html_parser.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DetailScreen extends StatefulWidget {
//   final int animeId;
//   late final DetailsController
//   detailController; // ✅ Declare but initialize later

//   DetailScreen({super.key, required this.animeId}) {
//     detailController = Get.put(
//       DetailsController(),
//       tag: animeId.toString(),
//     ); // ✅ Now it works!
//     detailController.fetchAnimeDetails(animeId);
//   }

//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Anime Details")),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Obx(() => _buildAnimeDetails(widget.detailController)),
            // _buildSectionTitle("Similar Anime"),
            // Obx(() {
            //   if (widget.detailController.animeDetails.value == null) {
            //     return Center(child: CircularProgressIndicator());
            //   }
            //   return _buildHorizontalList(
            //     widget.detailController.animeDetails.value!.similarAnime,
            //   );
            // }),
            // _buildSectionTitle("Related Anime"),
            // Obx(() {
            //   if (widget.detailController.animeDetails.value == null) {
            //     return Center(child: CircularProgressIndicator());
            //   }
            //   return _buildHorizontalList(
            //     widget.detailController.animeDetails.value!.relatedAnime,
            //   );
            // }),

//             _buildSectionTitle("Cast"),
//             Obx(() {
//               if (widget.detailController.animeDetails.value == null) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return _buildCastList(
//                 widget.detailController.animeDetails.value!.castList,
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimeDetails(DetailsController controller) {
//     if (controller.animeDetails.value == null) {
//       return Center(child: CircularProgressIndicator());
//     }

//     final anime =
//         controller.animeDetails.value!; // ✅ Now using AnimeDetailModel
//     return Column(
//       children: [
//         CachedNetworkImage(
//           imageUrl: anime.bannerImage ?? anime.imageUrl!,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: 200,
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             anime.title,
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Text(
//           HtmlParser.removeHtmlTags(
//             anime.description ?? "No description available",
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

  // Widget _buildHorizontalList(List<AnimeModel> animeList) {
  //   if (animeList.isEmpty) {
  //     return Center(child: Text("No data available"));
  //   }

  //   return SizedBox(
  //     height: 220, // ✅ Adjusted height to prevent overflow
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: animeList.length,
  //       itemBuilder: (context, index) {
  //         final anime = animeList[index];

  //         return GestureDetector(
  //           onTap: () {
  //             Get.to(
  //               () => DetailScreen(animeId: anime.id),
  //               preventDuplicates: false,
  //             ); // ✅ Ensures independent instance
  //           },

  //           child: Container(
  //             width: 150,
  //             margin: EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SizedBox(
  //                   height:
  //                       180, // ✅ Wrapping in SizedBox to ensure fixed height
  //                   child: CachedNetworkImage(
  //                     imageUrl: anime.imageUrl ?? "",
  //                     fit: BoxFit.cover,
  //                     width: 150,
  //                   ),
  //                 ),
  //                 SizedBox(height: 5),
  //                 Expanded(
  //                   // ✅ Prevent text from overflowing
  //                   child: Text(
  //                     anime.title,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

//   Widget _buildCastList(List<CastModel> castList) {
//     if (castList.isEmpty) {
//       return Center(child: Text("No cast available"));
//     }

//     return Column(
//       children:
//           castList.map((cast) {
//             return ListTile(
//               leading: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: cast.imageUrl ?? "",
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => CircularProgressIndicator(),
//                     errorWidget: (context, url, error) => Icon(Icons.error),
//                   ),
//                 ),
//               ),
//               title: Text(cast.name, overflow: TextOverflow.ellipsis),
//             );
//           }).toList(),
//     );
//   }
// }
