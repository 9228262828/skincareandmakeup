import 'package:Gomla/contstants.dart';
import 'package:Gomla/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../shared/global/app_colors.dart';
import '../shared/utils/app_assets.dart';
import '../shared/utils/app_values.dart';
import '../shared/utils/navigation.dart';
import 'open_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    // Make sure the default locale is set to 'ar' when the screen is built
    localeCubit.setLocale(localeCubit.state); // Default to Arabic

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Section
          Column(
            children: [
              SizedBox(height: mediaQueryHeight(context) * 0.05),
              Image(
                image: AssetImage(ImageAssets.logoWhite),
                height: mediaQueryHeight(context) * 0.15,
                width: mediaQueryWidth(context) * 0.6,
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.05),
            ],
          ),

          // Language Selection Title
          Text(
            AppLocalizations.of(context)!.select_language,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 20),

          // Language Selection Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                languageOption('en',   AppLocalizations.of(context)!.english, localeCubit, context),
                SizedBox(height: mediaQueryWidth(context) * .04),
                languageOption('ar',   AppLocalizations.of(context)!.arabic, localeCubit, context),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OpenScreen()));
              },
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: mediaQueryHeight(context) * 0.05),

          // Footer Note
          Text(
            AppLocalizations.of(context)!.lang_notes,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget languageOption(String languageCode, String language, LocaleCubit localeCubit, BuildContext context) {

    bool isSelected = localeCubit.state.languageCode == languageCode;

    return GestureDetector(
      onTap: () {
        localeCubit.setLocale(Locale(languageCode)); // Update the locale immediately on selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: .5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[500]!,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
                  : Container(),
            ),
            SizedBox(width: 10),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
                color: isSelected ? mainColor : AppColors.primary,
              ),
            ),
            Spacer(),
            // Show flag based on language
            Image.asset(
              languageCode == 'en'
                  ? ImageAssets.amirica_flag // American flag for English
                  : ImageAssets.arab_flag,  // Saudi flag for Arabic
              height: 30,
              width: 40,
            ),
          ],
        ),
      ),
    );
  }
}
