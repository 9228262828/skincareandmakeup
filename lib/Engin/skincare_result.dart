import 'dart:async';

import 'package:Gomla/Engin/ads.dart';
import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'channel/skincare_channel.dart';
import 'utility/styles.dart';

class SkincareResult extends StatefulWidget {
  const SkincareResult({
    super.key,
    required this.faceImage,
    required this.skinFeatures,
    required this.skincareViewChannel,
  });

  final List<String> skinFeatures;
  final Image faceImage;
  final SkincareViewChannel skincareViewChannel;

  @override
  State<SkincareResult> createState() => _SkincareResultState();
}

class _SkincareResultState extends State<SkincareResult> {
  String? selectedFeature;
  Map<String, String>? reports;
  Map<String, String>? scores;
  Map<String, String>? skinTypes;
  late Image faceImage = widget.faceImage;
  List<Map<String, dynamic>> capturedFeatures = [];

  @override
  @override
  void initState() {
    super.initState();

     print("List of skin features:");
    for (var feature in widget.skinFeatures) {
      print(feature);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    //  testMoistureFeature();
      widget.skincareViewChannel.getReports().then((reports) {
        widget.skincareViewChannel.getOverallScore().then((scores) {
          widget.skincareViewChannel.getSkinTypes().then((skinTypes) {
            setState(() {
              this.reports = reports;
              this.scores = scores;
              this.skinTypes = skinTypes;
            });
          });
        });
      });

      applyAllEffects(); // Apply all effects initially
    });
  }

  Future<void> applyAllEffects() async {
    selectedFeature = null;
    final List<String> featuresToApply =
        widget.skinFeatures.where((feature) => feature != "radiance").toList();

    final image =
        await widget.skincareViewChannel.getAnalyzedImage(featuresToApply);
    if (image != null) {
      setState(() {
        faceImage = image;
      });
    }

    await saveAllFeatureImages(); // Ensure all features are saved before proceeding
  }

  bool showReport = false;

  Future<void> saveAllFeatureImages() async {
    capturedFeatures.clear(); // Clear the list before saving

    for (int i = 0; i < widget.skinFeatures.length; i++) {
      String featureName = widget.skinFeatures[i];
      try {
        final overlayedImage =
            await widget.skincareViewChannel.getAnalyzedImage([featureName]);
        if (overlayedImage != null) {
          capturedFeatures.add({"name": featureName, "image": overlayedImage});
          print("Saved image for feature: $featureName"); // Debug log
        } else {
          print(
              "Failed to save image for feature: $featureName (overlayedImage is null)"); // Debug log
        }
      } catch (e) {
        print(
            "Error processing feature '$featureName'. Error: $e"); // Log error for this feature
      }
    }

    // Log the total number of captured features to verify all 10 are added
    print("Total features saved: ${capturedFeatures.length}");
    setState(() {
      showReport = true;
    });
  }

  Future<void> testMoistureFeature() async {
    try {
      final moistureImage =
          await widget.skincareViewChannel.getAnalyzedImage(["moisture"]);
      if (moistureImage != null) {
        print("Successfully retrieved 'Moisture' feature image.");
      } else {
        print("Failed to retrieve 'Moisture' feature image (null image).");
      }
    } catch (e) {
      print("Error retrieving 'Moisture' feature image. Error: $e");
    }
  }

  void updateSelectedFeature(String feature) async {
    // Clear all effects and apply only the selected feature
    selectedFeature = feature; // Track the selected feature for UI
    final image = await widget.skincareViewChannel.getAnalyzedImage([feature]);
    if (image != null) {
      setState(() {
        faceImage = image;
      });
    }
  }

  ListView featureListView(Map<String, String>? reports) {
    // Arabic translations for feature names
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

    List<Color> backgroundColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple
    ];
    List<Color> borderColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.skinFeatures.length,
      itemBuilder: (context, index) {
        String feature = widget.skinFeatures[index];
        String featureLabel =
            featureNames as String; // Use Arabic translation
        String scoreValue = reports?[feature] ?? "--";

        // Set background color based on selection status
        Color backgroundColor =
            backgroundColors[index % backgroundColors.length];
        Color borderColor = borderColors[index % borderColors.length];

        return GestureDetector(
          onTap: () {
            updateSelectedFeature(feature); // Apply only selected feature
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show a pointer arrow only if the item is selected
              if (selectedFeature == feature)
                Icon(Icons.arrow_drop_up, color: borderColor),

              // Display the effect icon
              scoreView(
                const Size(80, 60),
                scoreValue,
                featureLabel,
                selectedFeature == feature, // Highlight the selected item
                selectedFeature == feature ? Colors.white : Colors.black,
                // Text color    backgroundColor,
                borderColor,
                Colors.black,
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ListView combinedListView(
      Map<String, String>? reports, Map<String, String>? scores)
  {
    List<String> combinedFeatures = [
      'overallScore',
      ...widget.skinFeatures, // Original skin features
    ];

    List<Color> backgroundColors = [
      Colors.indigo,
      Colors.yellow,
      Colors.orangeAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.blueAccent,
      Colors.blue.shade200,
      Colors.grey.shade500,
      Colors.greenAccent,
      Colors.grey.shade50,
    ];

    List<Color> borderColors = [
      Colors.indigo,
      Colors.yellow,
      Colors.orangeAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.blueAccent,
      Colors.blue.shade200,
      Colors.grey.shade500,
      Colors.greenAccent,
      Colors.grey.shade50,
    ];

    List<String> featureNames = [

      AppLocalizations.of(context)!.overallScore, // Localized for "moisture"
      AppLocalizations.of(context)!.moisture, // Localized for "moisture"
      AppLocalizations.of(context)!.oiliness, // Localized for "oiliness"
      AppLocalizations.of(context)!.redness, // Localized for "redness"
      AppLocalizations.of(context)!.texture, // Localized for "texture"
      AppLocalizations.of(context)!.wrinkle, // Localized for "wrinkle"
      AppLocalizations.of(context)!.age_spot, // Localized for "age_spot"
      AppLocalizations.of(context)!.acne, // Localized for "acne"
      AppLocalizations.of(context)!.dark_circle_v2, // Localized for "dark_circle_v2"
      AppLocalizations.of(context)!.pore, // Localized for "pore"
      AppLocalizations.of(context)!.radiance, // Localized for "radiance"
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: combinedFeatures.length,
      itemBuilder: (context, index) {
        // Use index to fetch the correct feature name
        String feature = combinedFeatures[index];
        String featureLabel =
        index < featureNames.length ? featureNames[index] : feature;

        // Fetch the score from reports or scores
        String scoreValue = reports?[feature] ?? scores?[feature] ?? "--";

        // Set background and border colors
        Color backgroundColor = backgroundColors[index % backgroundColors.length];
        Color borderColor = borderColors[index % borderColors.length];

        return GestureDetector(
          onTap: () {
            updateSelectedFeature(feature); // Apply only selected feature
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show a pointer arrow only if the item is selected
              if (selectedFeature == feature)
                Icon(Icons.arrow_drop_up, color: borderColor),

              // Display the feature score and label
              scoreView(
                const Size(80, 60),
                scoreValue,
                featureLabel,
                selectedFeature == feature, // Highlight the selected item
                selectedFeature == feature ? Colors.white : Colors.black, // Text color
                backgroundColor,
              selectedFeature == feature?   Colors.black :Colors.white,

                  Shadow(
                      offset: Offset(.5, .5),
                    blurRadius: 2,
                    color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }


  ListView overallScoreView(Map<String, String>? scores) {
    // Define background and border colors
    List<Color> backgroundColors = [Colors.teal, Colors.indigo];
    List<Color> borderColors = [Colors.teal, Colors.indigo];

    // Feature identifiers (keys in the scores map)
    List<String> overAllNames = ['skinAge', ];

    return ListView.builder(
      scrollDirection: Axis.horizontal, // Horizontal scroll
      itemCount: overAllNames.length, // Number of items to display
      itemBuilder: (context, index) {
        String featureKey = overAllNames[index]; // Identifier for score lookup
        String label = featureKey == 'skinAge'
            ? AppLocalizations.of(context)!.skinAge // Localized for "skinAge"
            : AppLocalizations.of(context)!.overallScore; // Localized for "overallScore"

        String scoreValue = scores?[featureKey] ?? "--"; // Fetch score by key

        return scoreViewAll(
          const Size(90, 70), // Fixed size for the score view
          scoreValue, // Displayed score value
          label, // Localized label
          false, // Highlighting (not applicable here)
          backgroundColors[index % backgroundColors.length], // Background color
          borderColors[index % borderColors.length], // Border color
        );
      },
    );
  }

  Map<String, LinearGradient> effectColorGradients = {
    "moisture": LinearGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "oiliness": LinearGradient(
      colors: [
        Colors.orange.shade700, // Bright orange at the top
        Colors.orange.shade400, // Yellow
        Colors.yellow.shade200, // Light yellow at the bottom
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "redness": LinearGradient(
      colors: [
        Colors.red.shade300, // Lighter red at the bottom
        Colors.red.shade600, // Medium red
        Colors.red.shade800, // Darker red at the top
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    "texture": LinearGradient(
      colors: [
        Colors.yellow.shade300, // Light yellow
        Colors.yellow.shade700,
        Colors.blue.shade600, // Deep blue
        Colors.blue.shade900, // Darker blue or almost black
        // Darker yellow or yellow-green
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "wrinkle": LinearGradient(
      colors: [
        Colors.green.shade300, // Light green
        Colors.green.shade800, // Darker green
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "age_spot": LinearGradient(
      colors: [
        Colors.blue.shade900, // Dark blue
        Colors.blue.shade300, // Light blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "acne": LinearGradient(
      colors: [
        Colors.blue.shade800, // Dark blue
        Colors.blue.shade400, // Medium blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "dark_circle_v2": LinearGradient(
      colors: [
        Colors.grey.shade800, // Dark gray
        Colors.grey.shade400, // Medium gray
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "pore": LinearGradient(
      colors: [
        Colors.green.shade300, // Light green
        Colors.green.shade700, // Dark green
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    "radiance": LinearGradient(
      colors: [Colors.grey.shade800, Colors.grey.shade400],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  };






  Widget buildSelectedEffectPalette() {
    if (selectedFeature == null) {
      return Container();
    }
     if (selectedFeature == "acne") {
      return Column(
        children: [
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
          AppLocalizations.of(context)!.heavy_dark_circle ,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              const SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust height as needed
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade400,
                  ]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 5),
              Text(
    AppLocalizations.of(context)!.light_dark_circle // Localized for "dark_circle_v2"
    , // Normal
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              const SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust height as needed
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white,
                    Colors.grey.shade100,
                  ]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 5),
              Text(
    AppLocalizations.of(context)!.dark_circle_v2 // Localized for "dark_circle_v2"
    , // Medium
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              const SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.height *
                    0.1, // Adjust height as needed
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.blue,
                    Colors.blueAccent,
                  ]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      );
    }
    Map<String, List<String>> effectLabels = {
      "age_spot": [
        AppLocalizations.of(context)!.dark_spots, // Localized for "Dark Spots"
        AppLocalizations.of(context)!.light_spots // Localized for "Light Spots"
      ],
      "wrinkle": [
        AppLocalizations.of(context)!.deep_wrinkles, // Localized for "Deep Wrinkles"
        AppLocalizations.of(context)!.light_wrinkles // Localized for "Light Wrinkles"
      ],
      "texture": [
        AppLocalizations.of(context)!.projecting, // Localized for "Projecting"
        AppLocalizations.of(context)!.digging // Localized for "Digging"
      ],
      "dark_circle_v2": [
        AppLocalizations.of(context)!.heavy_dark_circle, // Localized for "Heavy Dark Circles"
        AppLocalizations.of(context)!.light_dark_circle // Localized for "Light Dark Circles"
      ],
      "redness": [
        AppLocalizations.of(context)!.heavy_redness, // Localized for "Heavy Redness"
        AppLocalizations.of(context)!.light_redness // Localized for "Light Redness"
      ],
      "oiliness": [
        AppLocalizations.of(context)!.heavy_oily, // Localized for "Heavy Oily"
        AppLocalizations.of(context)!.light_oily // Localized for "Light Oily"
      ],
      "moisture": [
        AppLocalizations.of(context)!.dry, // Localized for "Dry"
        AppLocalizations.of(context)!.moisture // Localized for "Moisture"
      ],
      "radiance": [
        AppLocalizations.of(context)!.pale, // Localized for "Pale"
        AppLocalizations.of(context)!.glow // Localized for "Glow"
      ],
      "acne": [
        AppLocalizations.of(context)!.black_heads, // Localized for "Black Heads"
        AppLocalizations.of(context)!.white_heads // Localized for "White Heads"
      ],
      "pore": [
        AppLocalizations.of(context)!.heavy_pore, // Localized for "Heavy Pore"
        AppLocalizations.of(context)!.light_pore // Localized for "Light Pore"
      ]
    };
    // Get the gradient for the selected feature
    LinearGradient? gradient = effectColorGradients[selectedFeature!];
    List<String>? labels = effectLabels[selectedFeature!];

    // If the gradient or labels are not defined for the selected feature, return an empty container
    if (gradient == null || labels == null) return Container();

    return Column(
      children: [
        Text(
          labels[0], // Top text
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black.withOpacity(0.5), // Shadow color and opacity
                offset: Offset(2.0, 2.0), // Shadow offset
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.08,
          height: MediaQuery.of(context).size.height * 0.3, // Adjust height as needed
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Text(
          labels[1], // Bottom text with line breaks if needed
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black.withOpacity(0.5), // Shadow color and opacity
                offset: Offset(2.0, 2.0), // Shadow offset
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection:  TextDirection.ltr,
        child: Stack(
          children: [
            // Display the selected feature's color palette on the left

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Hero(
                  tag: 'AnalyzedImage',
                  child: Image(
                    gaplessPlayback: true,
                    image: faceImage.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              right: 0,
              left: 0,
              child: SizedBox(
                height: 100,
                child: overallScoreView(scores),
              ),
            ),
          //  combinedListView(reports, scores),

            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.14,
                child: combinedListView(reports, scores)
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color:mainColor  ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            showReport
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.19,
                    right: 20,
                    child: ElevatedButton(
                      style:  ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      onPressed: () async {
                        print(scores);
                        print(reports);
                        print(capturedFeatures);
                        if (scores == null || reports == null || capturedFeatures.isEmpty) {
                          print("Scores, reports, or capturedFeatures are missing.");
                          return;
                        }

                        Map<String, String> skinAnalysisData = {
                          "dryness": reports!["moisture"] ?? "--",
                          "redness": reports!["redness"] ?? "--",
                          "oillness": reports!["oiliness"] ?? "--",
                          "acne": reports!["acne"] ?? "--",
                          "pores": reports!["pore"] ?? "--",
                          "texture": reports!["texture"] ?? "--",
                          "wrinkles": reports!["wrinkle"] ?? "--",
                          "dark spots": reports!["age_spot"] ?? "--",
                          "dark circles": reports!["dark_circle_v2"] ?? "--",
                          "radiance": reports!["radiance"] ?? "--",
                        };
                        Map <String, String> scores1 = {
                          "skinAge": scores!["skinAge"] ?? "--",
                          "overallScore": scores!["overallScore"] ?? "--",
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdPage(
                              isbeforetest: false,
                              capturedFeatures: capturedFeatures,
                              reports: reports!,
                              skinAnalysisData: skinAnalysisData,
                              scores: scores1,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.viewReport,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          )
                        ],
                      ),
                    ),
                  )
                : Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.192,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: .1),
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: mainColor,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context)!.viewReport,
                              style: TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.15, // Adjust to your desired position
              right: 1,
              child: buildSelectedEffectPalette(),
            ),
          ],
        ),
      ),
    );
  }
}
