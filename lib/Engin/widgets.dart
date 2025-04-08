import 'package:Gomla/Engin/pdf_screen.dart';
import 'package:Gomla/Engin/utility/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../shared/utils/app_values.dart';

ListView overallScoreView(BuildContext context) {
  List<Color> backgroundColors = [
    Colors.teal,
    Colors.indigo,
    // Add more colors if you have more overall score items
  ];

  List<Color> borderColors = [
    Colors.teal,
    Colors.indigo,
    // Add more colors if you have more overall score items
  ];

  // Localized labels for the overall score items
  List<String> overAllNames = [
    AppLocalizations.of(context)!.skinAge,
    // Localized for "skinAge"
    AppLocalizations.of(context)!.overallScore,
    // Localized for "overallScore"
  ];

  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: overAllNames.length,
    itemBuilder: (context, index) {
      return scoreView(
        const Size(80, 50),
        '--',
        overAllNames[index], // Use localized name
        false,
        backgroundColors[index % backgroundColors.length], // Custom color
        borderColors[index % borderColors.length],
        Colors.white,
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 3.0,
          color: Colors.black.withOpacity(.3),
        ),
      );
    },
  );
}

Widget featureListView(context) {
  // Define custom colors for each index
  List<Color> backgroundColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    // Add more colors if you have more features
  ];

  List<Color> borderColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    // Add more colors if you have more features
  ];

  List<String> featureNames = [
    AppLocalizations.of(context)!.moisture,
    // Localized for "moisture"
    AppLocalizations.of(context)!.oiliness,
    // Localized for "oiliness"
    AppLocalizations.of(context)!.redness,
    // Localized for "redness"
    AppLocalizations.of(context)!.texture,
    // Localized for "texture"
    AppLocalizations.of(context)!.wrinkle,
    // Localized for "wrinkle"
    AppLocalizations.of(context)!.age_spot,
    // Localized for "age_spot"
    AppLocalizations.of(context)!.acne,
    // Localized for "acne"
    AppLocalizations.of(context)!.dark_circle_v2,
    // Localized for "dark_circle_v2"
    AppLocalizations.of(context)!.pore,
    // Localized for "pore"
    AppLocalizations.of(context)!.radiance,
    // Localized for "radiance"
  ];

  return SizedBox(
    height: 100, // Define a fixed height to allow horizontal scrolling
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 10,
      itemBuilder: (context, index) {
        return scoreView(
          const Size(100, 50),
          '--',
          featureNames[index],
          false,
          backgroundColors[index % backgroundColors.length],
          // Use custom color
          borderColors[index % borderColors.length],
          Colors.white,
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 3.0,
            color: Colors.transparent,
          ),
        );
      },
    ),
  );
}

void showInstructionDialog (context){
  showDialog(
      context: context, builder: (context) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(20),
      shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3)
      ),

      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize:   MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 5,
                ),
                Text(AppLocalizations.of(context)!.be_ready_for_skin_test,style: TextStyle(

                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),),
                SizedBox(
                  height: 7,
                ),
                Divider(
                  color: Color(0xffEAEAEA),
                  thickness: 2,
                ),
                SizedBox(
                  height: 7,
                ),
                Text(AppLocalizations.of(context)!.instructionsTitle,style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,

                ),),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Image.asset("assets/remove.png",width: 35,height:35,color:  mainColor,fit:   BoxFit.contain,),
                    // Icon before the text
                    SizedBox(width: 8),
                    // Add some space between the icon and the text
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.removeMakeupInstruction,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Second row with icon and text
                Row(
                  children: [
                    Image.asset("assets/sunglasses.png",width: 35,height:35,color:  mainColor,fit:   BoxFit.contain,), // Another icon
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          AppLocalizations.of(context)!.removeGlassesInstruction),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Third row with icon and text
                Row(
                  children: [
                    Image.asset("assets/light.png",width: 35,height:35,color:  mainColor,fit:   BoxFit.contain,),// Another icon for adjustment
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!
                          .adjustPositionInstruction),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(
                      'assets/face-circle.png',
                      width: 35,
                      height: 35,
                      color: mainColor,
                    ), // Another icon for adjustment
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!
                          .adjustPosition),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

              ],
            ),
            SizedBox(
              width: mediaQueryWidth(context  )*.9,
              child: ElevatedButton(
                style:  ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side:   BorderSide(
                          color:  mainColor
                      )
                  ),),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog

                },
                child: Text(AppLocalizations.of(context)!.start_test,style:
                TextStyle(
                    color: mainColor
                ),),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(

                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PDFViewerPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                      transitionDuration: Duration(milliseconds: 300),
                    ),

                  );
                  //  dispose(); // Ensure dispose is called properly
                },
                child: Text(AppLocalizations.of(context)!.showpdf,style:
                TextStyle(
                  color: Colors.grey.shade500,
                  decoration:  TextDecoration.underline,
                ),),
              ),
            ),

          ],
        ),
      )
  ));
}
