import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application Theme Configuration
/// Provides Material Design 3 theme with custom colors and typography
class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryLightColor = Color(0xFF3B82F6); // Light Blue
  static const Color primaryDarkColor = Color(0xFF1E40AF); // Dark Blue

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF10B981); // Emerald Green
  static const Color secondaryLightColor = Color(0xFF34D399); // Light Green
  static const Color secondaryDarkColor = Color(0xFF059669); // Dark Green

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8FAFC); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color textPrimaryColor = Color(0xFF1F2937); // Dark Gray
  static const Color textSecondaryColor = Color(0xFF6B7280); // Medium Gray
  static const Color borderColor = Color(0xFFE5E7EB); // Light Border
  static const Color dividerColor = Color(0xFFD1D5DB); // Divider Gray

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // Scaffold
    scaffoldBackgroundColor: backgroundColor,

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Text Styles
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Button Styles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primaryColor, width: 1.5),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: surfaceColor,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snack Bar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryColor,
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearMinHeight: 4,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 16,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      elevation: 8,
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),

    // Scaffold - Dark Background
    scaffoldBackgroundColor: Color(0xFF121212),

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Text Styles - Dark Mode
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFBDBDBD),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9E9E9E),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Button Styles - Dark Mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLightColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primaryLightColor, width: 1.5),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLightColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Fields - Dark Mode
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF404040), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF404040), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF757575),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFBDBDBD),
      ),
      prefixIconColor: primaryLightColor,
      suffixIconColor: Color(0xFFBDBDBD),
    ),

    // Chips
    chipTheme: ChipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      backgroundColor: Color(0xFF2C2C2C),
      selectedColor: primaryColor,
      disabledColor: Color(0xFF424242),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Color(0xFF404040)),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFBDBDBD),
      ),
    ),

    // Bottom Sheet - Dark Mode
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snack Bar - Dark Mode
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF323232),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicators - Dark Mode
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearMinHeight: 4,
    ),

    // Divider - Dark Mode
    dividerTheme: DividerThemeData(
      color: Color(0xFF404040),
      thickness: 1,
      space: 16,
    ),

    // Bottom Navigation - Dark Mode
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryLightColor,
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      elevation: 8,
    ),

    // Floating Action Button - Dark Mode
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Drawer - Dark Mode
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
      ),
    ),
  );

  // Padding Constants
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Shadows
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x19000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
