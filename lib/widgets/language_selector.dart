import 'package:flutter/material.dart';
import 'package:skincare/providers/home_screen_provider.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return DropdownButton<Locale>(
      value: provider.locale,
      items: AppLocalizations.supportedLocales.map((locale) {
        final language = locale.languageCode == 'en' ? AppLocalizations.of(context)!.english : AppLocalizations.of(context)!.arabic;
        return DropdownMenuItem(
          child: Text(language),
          value: locale,
        );
      }).toList(),
      onChanged: (locale) {
        provider.setLocale(locale!);
      },
    );
  }
}
