import 'package:Gomla/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/home_screen_provider.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return DropdownButton<Locale>(
          dropdownColor:  Colors.grey.shade50,
          borderRadius:   BorderRadius.circular(3),
          underline:  const Divider(color: Colors.transparent),
          value: locale, // Display the current selected locale
          items: AppLocalizations.supportedLocales.map((locale) {
            // Determine the display language (English or Arabic)
            final language = locale.languageCode == 'en'
                ? AppLocalizations.of(context)!.english
                : AppLocalizations.of(context)!.arabic;

            return DropdownMenuItem(
              value: locale,
              child: Text(language), // Show the language name
            );
          }).toList(),
          onChanged: (selectedLocale) {
            if (selectedLocale != null) {
              context.read<LocaleCubit>().setLocale(selectedLocale); // Update the locale in LocaleCubit
              Provider.of<HomeScreenProvider>(context, listen: false).refreshData(context);

              Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (context) => MainScreen(index: 3)), (route) => false);// Refresh home data if necessary
            }
          },
        );
      },
    );
  }
}
