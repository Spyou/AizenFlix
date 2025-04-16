import 'package:anilist_test/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Mode
var lightTheme = ThemeData(
  // fontFamily: 'Poppins',
  fontFamily: GoogleFonts.poppins().fontFamily,
  useMaterial3: true,
  scaffoldBackgroundColor: lightBGColor,
  colorScheme: const ColorScheme.light(
    surface: lightBGColor,
    primary: lightPrimaryColor,
    onPrimary: lighttextColor,
    primaryContainer: lightBoxColor,
    secondary: lightExternalTextColor,
  ),
);

// Dark Mode
var darkTheme = ThemeData(
  // fontFamily: 'Poppins',
  fontFamily: GoogleFonts.poppins().fontFamily,
  scaffoldBackgroundColor: darkBGColor,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: darkBGColor,
    primary: darkPrimaryColor,
    onPrimary: darkTextColor,
    primaryContainer: darkBoxColor,
    secondary: darkExternalTextColor,
  ),
);
