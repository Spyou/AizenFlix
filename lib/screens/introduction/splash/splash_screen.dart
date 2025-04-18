import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: FadeInDown(
          // duration: Duration(seconds: 1),
          child: Text(
            "AIZENFLIX",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: theme.primary,
              fontFamily: GoogleFonts.contrailOne().fontFamily,
            ),
          ),
        ),
      ), // Show loading until navigation happens
    );
  }
}
