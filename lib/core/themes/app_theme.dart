import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.grey900,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withOpacity(0.78),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.35), width: 1.2),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withOpacity(0.86),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      showCloseIcon: true,
      closeIconColor: AppColors.grey900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1F26).withOpacity(0.75),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.16), width: 1),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF1E1F26).withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: const Color(0xFF1E1F26).withOpacity(0.86),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// import 'package:flutter/material.dart';
// import 'color_schemes.dart';

// class AppTheme {
//   static ThemeData get light => ThemeData(
//     useMaterial3: true,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: AppColors.primary,
//       brightness: Brightness.light,
//     ),
//     scaffoldBackgroundColor: AppColors.background,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.primary,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//     ),
//     cardTheme: CardTheme(
//       color: AppColors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//   );

//   static ThemeData get dark => ThemeData(
//     useMaterial3: true,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: AppColors.primary,
//       brightness: Brightness.dark,
//     ),
//     scaffoldBackgroundColor: AppColors.black,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.primaryDark,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//     ),
//     cardTheme: CardTheme(
//       color: AppColors.surfaceDark,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//   );
  
//   static ThemeData getTheme(Brightness brightness) {
//     return brightness == Brightness.light ? light : dark;
//   }
// }