import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(Locale('ar')) {
    _loadLocale(); // Load the saved locale when the Cubit is initialized
  }

  // Method to set a new locale
  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return; // If the locale is not supported, do nothing
    }

    emit(locale); // Emit the new locale to update the UI

    // Save the selected locale to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  // Method to load the saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString('locale');

    if (localeCode != null) {
      emit(Locale(localeCode)); // Emit the saved locale
    } else {
      emit(Locale('ar')); // Default to Arabic if no locale is saved
    }
  }

  // Method to clear the locale (reset to English)
  void clearLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('locale');
    emit(Locale('en')); // Emit English as the default locale
  }
}
