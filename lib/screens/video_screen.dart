import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String animeSession;
  final String episodeSession;

  const VideoPlayerScreen({
    super.key,
    required this.animeSession,
    required this.episodeSession,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final VideoController controller = Get.put(
      VideoController(
        animeSession: widget.animeSession,
        episodeSession: widget.episodeSession,
      ),
    );

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        } else if (controller.videoUrl.value.isEmpty) {
          return const Center(child: Text('No video available'));
        } else {
          return BetterPlayer(
            controller: BetterPlayerController(
              BetterPlayerConfiguration(
                autoPlay: true,
                fullScreenByDefault: true,
                allowedScreenSleep: false,
                handleLifecycle: true,
                autoDetectFullscreenDeviceOrientation: true,
                aspectRatio: 16 / 9,
                fit: BoxFit.contain,

                controlsConfiguration: BetterPlayerControlsConfiguration(
                  enableProgressText: true,
                  enablePlaybackSpeed: true,
                  enableQualities: true,
                ),
                eventListener: (event) {
                  if (event.betterPlayerEventType ==
                      BetterPlayerEventType.exception) {
                    print("BetterPlayer crash: ${event.parameters}");
                  }
                },
              ),
            )..setupDataSource(
              BetterPlayerDataSource.network(
                videoFormat: BetterPlayerVideoFormat.hls,
                qualities: {
                  "1080p": controller.videoUrl.value,
                  "720p": controller.videoUrl.value,
                },
                controller.videoUrl.value,
                headers: {
                  "Cookie":
                      '__ddg1_=XeUxbfS047EW6cQE2JgH; __ddgid_=1V4D1oKj9BEsa9Vn; __ddg2_=3GqHC62yLVyRCgbE; res=1080; aud=jpn; av1=0; __ddg9_=188.113.229.42; latest=6087; ann-fakesite=0; __ddg8_=IYo15fVJlfANjOv3; __ddg10_=1743708714; XSRF-TOKEN=eyJpdiI6InluK1dINmFaR25Uc3N3T2lXTThpdmc9PSIsInZhbHVlIjoiMitUQkx2TCtXbVJwVXdxYXh2WXlFVG44d0VJRGhWVUl5Zmh1eEZuSk9iWUIyTkZyM3JGMWNiSDNsR0ZJMFlTOThPUm9nNXNTU2c5aHNuZFJ2N3dhZ1J6Z3FPUmg4dVBUY3VSOW1wTGtIK096MVhvdGJtWXlwVFBTRExnZ1BLSFgiLCJtYWMiOiJlNDAxZjk1M2U0ODQ1N2M4MTYyNWNhMWYxOTdlMTg1MzQ3ZDc4NGY0NGY3NGFhY2QyZDQ2ZjM0MmI2YzJjNzM2IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5BaGZhaitSa210Tkk2N01nTlBzTUE9PSIsInZhbHVlIjoiWmpkTXFJSUE3eEZSMk1WVmNEME9iVEw5bXQyR1BOdnM1VnJrS0laYmRLcDYxaThZRDNmaDA3NzFpamQvaTVpZlJyLy9JRUhOWnBZZ0I0ZUloVFlNOEFlbmZ2VUErclhBOEVEVWJXUzZRQmppQksvSTVQQjhjR0F3bllrMGM3TnAiLCJtYWMiOiI0ODcxNjdhZDYxZTA4OWQ3YWU4YzA1MThiMjZiMjNlZjUyNTQwOGRkM2QyMGUxZGZmZDAzMDlhZTM0OWU4MjUxIiwidGFnIjoiIn0%3D',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
                  'Referer': 'https://kwik.si',
                },
              ),
            ),
          );
        } //or i think its about emulator codec , try to run on real device okay bro ill buldi
        // and also you can share to me )
      }),
    );
  }
}
