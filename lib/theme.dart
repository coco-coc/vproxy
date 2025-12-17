import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const XBlue = Color(0xFF208EFD);
const XBlueContainer = Color(0xFFE6F3FF);
const XPink = Color(0xFFEE348B);
const XPinkContainer = Color(0xFFFCE6F0);
const VioletBlue = Color.fromRGBO(50, 74, 178, 1);
const RedViolet = Color.fromRGBO(199, 21, 133, 1);
const PowderBlue = Color(0xFFB0E0E6);
const PowderBlueContainer = Color.fromRGBO(232, 246, 248, 1); // Add this line
const ShimmerPurple = Color(0xFFB433F7);
const ShimmerPurpleContainer = Color(0xFFF5E8FF); // Light lavender background
const ShimmerGreen = Color(0xFF30E12E);
const ShimmerGreenContainer = Color(0xFFE8F7E8); // Light mint green background

final pinkColorScheme = ColorScheme.fromSeed(
  seedColor: XPink,
  dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
);

ThemeData getTheme(Locale? locale) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: XBlue,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );

  return ThemeData(
    textTheme: getTextTheme(locale),
    colorScheme: colorScheme,
    tooltipTheme: const TooltipThemeData(
      preferBelow: false,
    ),
    // switchTheme: SwitchThemeData(
    //   thumbColor: MaterialStateProperty.all(XPink),
    //   trackColor: MaterialStateProperty.all(XPink),
    //   trackOutlineColor: MaterialStateProperty.all(XPink),
    // ),
    inputDecorationTheme:
        const InputDecorationTheme(border: OutlineInputBorder()),
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0, // Prevents color change when scrolling
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    menuButtonTheme: MenuButtonThemeData(
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(112, 48),
        maximumSize: const Size(280, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    ),
  );
}

ThemeData getDarkTheme(Locale? locale) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    textTheme: getTextTheme(locale, isDark: true),
    tooltipTheme: const TooltipThemeData(
      preferBelow: false,
    ),
    inputDecorationTheme:
        const InputDecorationTheme(border: OutlineInputBorder()),
    // switchTheme: SwitchThemeData(
    //   thumbColor: MaterialStateProperty.all(XPink),
    //   trackColor: MaterialStateProperty.all(XPink),
    //   trackOutlineColor: MaterialStateProperty.all(XPink),
    // ),
    // appBarTheme: AppBarTheme(
    //   systemOverlayStyle: SystemUiOverlayStyle(
    //     statusBarColor: colorScheme.surface,
    //     systemNavigationBarColor: colorScheme.surfaceContainer,
    //     statusBarIconBrightness: Brightness.light,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //   ),
    // ),
    menuButtonTheme: MenuButtonThemeData(
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(112, 48),
        maximumSize: const Size(280, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    ),
  );
}

TextTheme? getTextTheme(Locale? locale, {bool isDark = false}) {
  if (locale?.languageCode == 'zh' &&
      (Platform.isWindows || Platform.isLinux)) {
    // SystemFonts().loadAllFonts().then((s) {
    //   for (final font in s) {
    //     logger.d("System font: $font");
    //   }
    // });
    return GoogleFonts.notoSansScTextTheme(
      ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).textTheme,
    );
  }
  return null;
}
