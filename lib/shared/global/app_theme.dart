import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../contstants.dart';
import '../utils/app__fonts.dart';
import 'app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: FontConstants.dINNextLTArabicFontFamily,

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: FontSize.s32,
      color: AppColors.dark,
      fontWeight: FontWeightManager.bold,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),
    titleMedium: TextStyle(
      fontSize: FontSize.s24,
      color: AppColors.primary,
      fontWeight: FontWeightManager.bold,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: FontSize.s16,
      color: AppColors.dark,
      fontWeight: FontWeight.w400,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),
    labelMedium: TextStyle(
      fontSize: FontSize.s20,
      fontWeight: FontWeightManager.bold,
      color: AppColors.background,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w500,
      color: AppColors.boldGrey,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),
    displayMedium: TextStyle(
      fontSize: FontSize.s16,
      fontWeight: FontWeight.normal,
      color: AppColors.dark,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),

    displayLarge: TextStyle(
      fontSize: FontSize.s18,
      fontWeight: FontWeight.w700,
      color: AppColors.boldGrey,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: FontSize.s22,
      color: AppColors.background,
      fontWeight: FontWeight.bold,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: FontSize.s18,
      color: AppColors.secColor,
      fontWeight: FontWeight.bold,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),headlineSmall: TextStyle(
      fontSize: FontSize.s14,
      color: AppColors.background,
      fontWeight: FontWeight.bold,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),
    headlineMedium: TextStyle(
      fontSize: FontSize.s16,
      fontWeight: FontWeightManager.medium,
      color: AppColors.boldGrey,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,

    ),
    headlineLarge: TextStyle(
      fontSize: FontSize.s22,
      fontWeight: FontWeightManager.bold,
      color: AppColors.red,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
    ),

  ),

  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primary,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3.0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.0),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.0),
      borderSide: BorderSide(color: AppColors.boldGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.0),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    labelStyle: TextStyle(
      color: AppColors.boldGrey,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
      fontWeight: FontWeight.w300, // Light
    ),
    hintStyle: TextStyle(
      color: AppColors.offWhite1,
      fontFamily: FontConstants.dINNextLTArabicFontFamily,
      fontWeight: FontWeight.w300, // Light
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      textStyle: TextStyle(
        fontSize: FontSize.s16,
        fontWeight: FontWeightManager.bold,
        fontFamily: FontConstants.dINNextLTArabicFontFamily,
        // Bold
      ),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.primary,
  ).copyWith(background: AppColors.background),
);

//  Custom Input Decoration
InputDecoration customInputDecoration(
    BuildContext context,
    String labelText,
    String hintText, {
      Widget? suffixIcon,
      Widget? suffix,
      Widget? prefixIcon,
    }) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:  BorderSide(color: mainColor),
      gapPadding: 10,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
          color: Color(0xFFEAEAEA),
          width:
          1), // Yellow border when the field is enabled
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
          color: Color(0xFFEAEAEA).withOpacity(.8),
          width: 1), // Green border when focused
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
          color: Colors.red,
          width: 1), // Red border for error state
    ),
    errorStyle: TextStyle(fontSize: 12), // Adjust the error message size
    labelStyle:   TextStyle(color: Color(0xFFD9D9D9),fontSize: 14)  ,
    hintStyle:   TextStyle(color: Color(0xFFD9D9D9),fontSize: 14)  ,
    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    suffixIcon: suffixIcon,
    suffix: suffix,
    prefixIcon: prefixIcon
  );
}
