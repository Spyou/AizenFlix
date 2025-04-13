import 'package:anilist_test/controllers/auth_controller.dart';
import 'package:anilist_test/controllers/theme_controller.dart';
import 'package:anilist_test/controllers/user_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _ProfileSettings2ViewState();
}

class _ProfileSettings2ViewState extends State<SettingScreen> {
  bool pushNotifications = true;
  bool faceID = true;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();

    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "SETTINGS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (userController.errorMessage.isNotEmpty) {
          return Center(child: Text(userController.errorMessage.value));
        }
        return Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Icon(Icons.edit, size: 20, color: theme.primary),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 34, 34, 34),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // border: Border.all(color: theme.primary, width: 0.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                userController.userData['avatar']['large'],
                            // placeholder:
                            //     (context, url) =>
                            //         const Center(child: CircularProgressIndicator()),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userController.userData['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Total Anime: ${userController.userData['statistics']['anime']['count']}",
                        style: TextStyle(fontSize: 14, color: theme.onPrimary),
                      ),
                      // const SizedBox(height: 2),
                      Text(
                        "Episodes Watched: ${userController.userData['statistics']['anime']['episodesWatched']}",
                        style: TextStyle(fontSize: 14, color: theme.onPrimary),
                      ),
                      // SizedBox(height: 2),
                      Text(
                        "Mean Score: ${userController.userData['statistics']['anime']['meanScore']}",
                        style: TextStyle(fontSize: 14, color: theme.onPrimary),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // authController.logout();
                          },
                          icon: const Icon(Icons.logout_rounded),

                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.black,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.onPrimary,
                            ),
                            iconSize: 20,
                            iconColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Icon(Icons.settings_rounded, size: 20, color: theme.primary),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 34, 34, 34),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // create theme switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dark Mode", style: TextStyle(fontSize: 16)),
                      Switch(
                        value: themeController.isDarkMode.value,
                        onChanged: (value) {
                          themeController.toggleTheme();
                        },

                        activeColor: theme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
