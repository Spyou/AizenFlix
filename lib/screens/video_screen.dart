// video_player_screen.dart
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_controller.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String animeSession;
  final String episodeSession;

  VideoPlayerScreen({
    super.key,
    required this.animeSession,
    required this.episodeSession,
  });

  final VideoController controller = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    controller.extractVideoUrl(animeSession, episodeSession);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Video Player"),
        backgroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final videoController = controller.playerController.value;
        if (videoController != null && videoController.value.isInitialized) {
          return Chewie(
            controller: ChewieController(
              videoPlayerController: videoController,
              autoPlay: true,
              looping: false,
            ),
          );
        } else {
          return Center(
            child: Text(
              "Initializing player...",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      }),
    );
  }
}
