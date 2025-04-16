import 'package:anilist_test/controllers/bottom_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  final BottomNavigationController controller = Get.put(
    BottomNavigationController(),
  );

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body:
            controller.pages[controller
                .currentIndex
                .value], // ✅ Dynamic page switching
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: theme.surface,
            indicatorColor: theme.primary,
          ),
          child: NavigationBar(
            labelTextStyle: WidgetStateProperty.all(
              TextStyle(
                color: theme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: theme.surface,
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: (index) {
              controller.changePage(index);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: "Explore",
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark),
                label: "My List",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
