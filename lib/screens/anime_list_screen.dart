import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/anime_model.dart';
import 'detail screen/detail_screen.dart';

class AnimeListScreen extends StatelessWidget {
  final String title;
  final List<AnimeModel> animeList;

  const AnimeListScreen({
    super.key,
    required this.title,
    required this.animeList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          animeList.isEmpty
              ? Center(child: Text("No Anime Available"))
              : ListView.builder(
                itemCount: animeList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      animeList[index].imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(animeList[index].title),
                    subtitle: Text(
                      "Episodes: ${animeList[index].episodes ?? 'N/A'} | Status: ${animeList[index].status ?? 'Unknown'}",
                    ),
                    onTap: () {
                      Get.to(() => DetailScreen(animeId: animeList[index].id));
                    },
                  );
                },
              ),
    );
  }
}
