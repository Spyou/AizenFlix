import 'package:anilist_test/screens/explore/explore_screen.dart';
import 'package:anilist_test/screens/home/home_screen.dart';
import 'package:anilist_test/screens/my_list/myList_screen.dart';
import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ✅ Getter to return fresh screens
  List get pages => [
    HomeScreen(),
    ExploreScreen(),
    MyListScreen(), // always returns fresh instance
  ];
}
