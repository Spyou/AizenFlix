import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:anilist_test/controllers/details_controller.dart';
import 'package:anilist_test/controllers/theme_controller.dart';
import 'package:anilist_test/controllers/user_controller.dart';
import 'package:anilist_test/screens/introduction/auth/login_screens.dart';
import 'package:anilist_test/screens/introduction/auth/webview_screen.dart';
import 'package:anilist_test/screens/introduction/splash/splash_screen.dart';
import 'package:anilist_test/screens/main_screen.dart';
import 'package:anilist_test/services/anime_api_service.dart';
import 'package:anilist_test/services/graphql_service.dart';
import 'package:anilist_test/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DetailsController());
  await GetStorage.init();
  await GraphQLService.loadAuthToken();
  Get.put(AuthController());
  Get.put(UserController(), permanent: true);
  await Get.putAsync(() => AnimePaheService().init());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());
    final RouteObserver<ModalRoute<void>> routeObserver =
        RouteObserver<ModalRoute<void>>();
    return GetMaterialApp(
      navigatorObservers: [routeObserver],

      debugShowCheckedModeBanner: false,
      title: 'AizenFlix',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => SplashScreen()),
        GetPage(name: "/LoginScreen", page: () => LoginScreen()),
        GetPage(name: "/HomeScreen", page: () => MainScreen()),
        GetPage(
          name: "/WebViewScreen",
          page:
              () => WebViewScreen(
                loginUrl: "https://anilist.co/api/v2/oauth/authorize",
              ),
        ),
      ],
    );
  }
}
