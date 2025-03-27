import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = Get.find<AuthController>().userInfo;

    return Scaffold(
      appBar: AppBar(title: Text("AniList Profile")),
      body: Obx(() {
        if (userInfo.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userInfo["avatar"]["large"]),
            ),
            SizedBox(height: 10),
            Text(
              userInfo["name"],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Anime Watched: ${userInfo["statistics"]["anime"]["count"]}"),
            Text(
              "Average Score: ${userInfo["statistics"]["anime"]["meanScore"]}",
            ),
            Text(
              "Minutes Watched: ${userInfo["statistics"]["anime"]["minutesWatched"]}",
            ),
          ],
        );
      }),
    );
  }
}
