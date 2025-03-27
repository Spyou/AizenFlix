import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'genre_detail_screen.dart';

class GenreScreen extends StatelessWidget {
  final List<Map<String, String>> genres = [
    {
      "name": "Action",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx21087-2OkAdgfnQown.jpg",
    },
    {
      "name": "Adventure",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx21-YCDoj1EkAxFn.jpg",
    },
    {
      "name": "Comedy",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx918-hRbQHIkRUebX.jpg",
    },
    {
      "name": "Drama",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx21519-fPhvy69vnQqS.png",
    },
    {
      "name": "Ecchi",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx132405-qP7FQYGmNI3d.jpg",
    },
    {
      "name": "Fantasy",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx5114-Dilr312jctdJ.jpg",
    },
    {
      "name": "Horror",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx11111-Y4QgkX8gJQCa.png",
    },
    {
      "name": "Mahou Shoujo",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx104051-tFMIbiffwBLs.jpg",
    },
    {"name": "Hentai", "image": "https://imhentai.to/img/imbanner.jpg"},

    {
      "name": "Mecha",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx1575-dG7vMMZMF3wk.jpg",
    },
    {
      "name": "Music",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx20665-zuhC5OO6XgZ7.png",
    },
    {
      "name": "Mystery",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx1535-4r88a1tsBEIz.jpg",
    },
    {
      "name": "Psychological",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx19-8Iz8KB1pJNil.jpg",
    },
    {
      "name": "Romance",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx124080-h8EPH92nyRfS.jpg",
    },
    {
      "name": "Sci-Fi",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx9253-7pdcVzQSkKxT.jpg",
    },
    {
      "name": "Slice of Life",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx142838-26JrqcFU1ljB.jpg",
    },
    {
      "name": "Sports",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx137822-1JgEIoQ081G8.png",
    },
    {
      "name": "Thriller",
      "image":
          "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx21234-bCvWk2f58LCv.jpg",
    },
  ];

  GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            childAspectRatio: 1.7,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => GenreDetailScreen(genre: genres[index]['name']!));
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      genres[index]['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      genres[index]['name']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ListView.builder(
//         itemCount: genres.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(genres[index]),
//             onTap: () {
//               Get.to(() => GenreDetailScreen(genre: genres[index]));
//             },
//           );
//         },
//       ),
