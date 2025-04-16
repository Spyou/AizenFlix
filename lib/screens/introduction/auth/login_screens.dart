import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_intro.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  height: 330,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Yokoso, watashi no ",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: "AizenFlix",
                              style: TextStyle(
                                color: theme.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "(Welcome to my AizenFlix)",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 169, 169, 169),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Your gateway to unlimited anime & movies.  Explore, stream, and track what you love.  No ads. No limits. Just pure content.  Beautiful UI. Real-time data. Super smooth.  Start your anime journey with AizenFlix now.",
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color.fromARGB(255, 214, 214, 214),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            splashFactory: InkRipple.splashFactory,
                            foregroundColor: Colors.black,
                            backgroundColor: theme.primary.withOpacity(0.9),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: authController.login,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                "assets/images/anilist_icon.png",
                                width: 25,
                                height: 25,
                              ),
                              Text(
                                "Login with AniList",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 25,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
