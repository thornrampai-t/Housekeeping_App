import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lighMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Color.fromARGB(255, 243, 247, 222), // สีพื้นหลัง
    primary: Color.fromARGB(255, 76, 175, 80),
    secondary: Color.fromARGB(255, 25, 98, 47),
    tertiary: Colors.black,
    surface: Colors.white,
  ),
  appBarTheme: AppBarTheme(backgroundColor: Color.fromARGB(255, 25, 98, 47)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(
      255,
      25,
      98,
      47,
    ), // สีของ Bottom Navigation Bar ในโหมดมืด
  ),
  textTheme: TextTheme(
    displayMedium: GoogleFonts.notoSansThai(
      fontSize: 30,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    
    ),
    headlineLarge: GoogleFonts.notoSansThai(
      fontSize: 23,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.notoSansThai(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.notoSansThai(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.white,
    secondary: Color.fromARGB(255, 35, 35, 35),
    tertiary: Colors.white,
    surface: const Color.fromARGB(255, 95, 90, 90),
  ),
  appBarTheme: AppBarTheme(backgroundColor: Color.fromARGB(255, 35, 35, 35)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(
      255,
      35,
      35,
      35,
    ), // สีของ Bottom Navigation Bar ในโหมดมืด
  ),
  textTheme: TextTheme(
     displayMedium: GoogleFonts.notoSansThai(
      fontSize: 30,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    
    ),
    headlineLarge: GoogleFonts.notoSansThai(
      fontSize: 23,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.notoSansThai(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.notoSansThai(
      fontSize: 16,
      color: Colors.white
    ),
  ),
);
