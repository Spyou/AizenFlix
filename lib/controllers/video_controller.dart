// video_controller.dart
import 'package:anilist_test/controllers/js_unpacker.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  final dio = Dio();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString videoUrl = ''.obs;
  Rx<VideoPlayerController?> playerController = Rx<VideoPlayerController?>(
    null,
  );

  Future<void> extractVideoUrl(
    String animeSession,
    String episodeSession,
  ) async {
    var link = "$animeSession/$episodeSession";
    var mainLink = "https://animepahe.ru/play/$link";
    final response = await dio.get(
      mainLink,
      options: Options(
        headers: {
          'dnt': '1',
          "Cookie":
              '__ddg1_=XeUxbfS047EW6cQE2JgH; __ddgid_=1V4D1oKj9BEsa9Vn; __ddg2_=3GqHC62yLVyRCgbE; res=1080; aud=jpn; av1=0; __ddg9_=188.113.229.42; latest=6087; ann-fakesite=0; __ddg8_=IYo15fVJlfANjOv3; __ddg10_=1743708714; XSRF-TOKEN=eyJpdiI6InluK1dINmFaR25Uc3N3T2lXTThpdmc9PSIsInZhbHVlIjoiMitUQkx2TCtXbVJwVXdxYXh2WXlFVG44d0VJRGhWVUl5Zmh1eEZuSk9iWUIyTkZyM3JGMWNiSDNsR0ZJMFlTOThPUm9nNXNTU2c5aHNuZFJ2N3dhZ1J6Z3FPUmg4dVBUY3VSOW1wTGtIK096MVhvdGJtWXlwVFBTRExnZ1BLSFgiLCJtYWMiOiJlNDAxZjk1M2U0ODQ1N2M4MTYyNWNhMWYxOTdlMTg1MzQ3ZDc4NGY0NGY3NGFhY2QyZDQ2ZjM0MmI2YzJjNzM2IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5BaGZhaitSa210Tkk2N01nTlBzTUE9PSIsInZhbHVlIjoiWmpkTXFJSUE3eEZSMk1WVmNEME9iVEw5bXQyR1BOdnM1VnJrS0laYmRLcDYxaThZRDNmaDA3NzFpamQvaTVpZlJyLy9JRUhOWnBZZ0I0ZUloVFlNOEFlbmZ2VUErclhBOEVEVWJXUzZRQmppQksvSTVQQjhjR0F3bllrMGM3TnAiLCJtYWMiOiI0ODcxNjdhZDYxZTA4OWQ3YWU4YzA1MThiMjZiMjNlZjUyNTQwOGRkM2QyMGUxZGZmZDAzMDlhZTM0OWU4MjUxIiwidGFnIjoiIn0%3D',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        },
      ),
    );
    Document doc = parse(response.data);
    var provider = '';
    var url = '';
    var scripts = doc.getElementsByTagName("script");
    for (var script in scripts) {
      if (script.innerHtml.contains('let session =') &&
          script.innerHtml.contains('let provider =') &&
          script.innerHtml.contains('let url =')) {
        RegExp providerRegExp = RegExp(r'let provider = "(.*?)";');
        RegExp urlRegExp = RegExp(r'let url = "(.*?)";');
        var providerMatch = providerRegExp.firstMatch(script.innerHtml);
        var urlMatch = urlRegExp.firstMatch(script.innerHtml);

        if (providerMatch != null && urlMatch != null) {
          provider = providerMatch.group(1)!;
          url = urlMatch.group(1)!;
          break;
        }
      }
    }
    getMediaLink(provider, url);
  }

  Future<void> getMediaLink(String provider, String url) async {
    print(url);
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'dnt': '1',
          "Referer": "https://animepahe.ru/",
          "Alt-Referer": "https://animepahe.ru/",
          "Alt-Used": "kwik.si",
          "Host": "kwik.si",
          "Sec-Fetch-User": "?1",
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        },
      ),
    );
    print(response.data);
    Document document = parse(response.data);
    var scriptTags = document.getElementsByTagName('script');

    String? evalContent;
    for (var script in scriptTags) {
      var scriptContent = script.innerHtml;

      if (getPacked(scriptContent) != null) {
        print("Found eval function: \n$scriptContent");
        evalContent = scriptContent;
        break;
      }
    }

    // Optionally, you can handle the result if needed
    if (evalContent != null) {
      JsUnpacker jsPacker = JsUnpacker(evalContent);
      print("Unpacked content: ${extractFileUrl(jsPacker.unpack()!)}");
      print("Unpacked content: ${jsPacker.detect()}");
      print("Eval function content extracted.");
    } else {
      print("No eval function found.");
    }
  }

  String? extractFileUrl(String input) {
    final regex = RegExp(r"https?://\S+\.m3u8");
    final match = regex.firstMatch(input);
    return match?.group(0);
  }

  String? getPacked(String input) {
    // Create a RegExp with the equivalent pattern
    RegExp packedRegex = RegExp(r"eval\(function\(p,a,c,k,e,.*\)\)");

    // Search for the first match of the regex in the input string
    return packedRegex.firstMatch(input)?.group(0);
  }
}
