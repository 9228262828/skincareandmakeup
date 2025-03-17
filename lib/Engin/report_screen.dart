import 'dart:io';

import 'package:Gomla/Engin/skin_cubit_and_states.dart';
import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as img;

import '../models/product.dart';
import '../screens/product_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer_widget.dart';
import 'TEST.dart';
import 'custom_progress_bar.dart';

class ReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> capturedFeatures;
  final Map<String, String> reports;
  final Map<String, dynamic> skinAnalysisData;
  final Map<String, dynamic> score;

  ReportScreen(
      {Key? key,
      required this.capturedFeatures,
      required this.score,
      required this.reports,
      required this.skinAnalysisData})
      : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isArabic = false;

  // Function to get the assessment level based on the score
  String getAssessmentLevel(int score) {
    if (score >= 80) {
      return "Good";
    } else if (score >= 60) {
      return "Average";
    } else {
      return "Weak";
    }
  }

  // Function to return the color based on the assessment level
  Color getAssessmentColor(String assessment) {
    switch (assessment) {
      case "Good":
        return Colors.green.withOpacity(0.7);
      case "Average":
        return Colors.orange.withOpacity(0.7);
      case "Weak":
      default:
        return Colors.red.withOpacity(0.7);
    }
  }



  @override
  Widget build(BuildContext context) {
    print("score: ${widget.score}");
    print("reports: ${widget.reports}");
    print("capturedFeatures: ${widget.capturedFeatures}");
    print("skinAnalysisData: ${widget.skinAnalysisData}");
    return Scaffold(

      body: RefreshIndicator(
        onRefresh: () async {
          await SkinAnalysisCubit().fetchSkinAnalysis("20", "56", "3" , "3", "2", "20", "95", "85", '75', "48", "38", "35");
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: mediaQueryHeight(context) * 0.03,
              ),
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  height: mediaQueryHeight(context) * 0.08,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      children: [

                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            AppLocalizations.of(context)!.skinAnalysisReport,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade900,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  )),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                height: mediaQueryHeight(context) * 0.27,
                child: RadarChart(
                  getRadarChartData(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: double.infinity,
                  height: mediaQueryHeight(context) * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: mediaQueryWidth(context) * 0.47,
                            decoration: BoxDecoration(
                              color: mainColor,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset:
                                      Offset(0, 1), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.skinAge,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.score['skinAge'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(AppLocalizations.of(context)!.year,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ]),
                          ),
                          Container(
                            width: mediaQueryWidth(context) * 0.47,
                            decoration: BoxDecoration(
                              color: mainColor,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset:
                                      Offset(0, 1), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.overallScore,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.score['overallScore'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.treatments,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
              ),
              BlocProvider(
                create: (context) {
                  // Ensure that all values are not null before passing them
                  final dryness = widget.reports["moisture"];
                  final redness = widget.reports["redness"];
                  final oillness = widget.reports["oiliness"];
                  final acne = widget.reports["acne"];
                  final pores = widget.reports["pore"];
                  final texture = widget.reports["texture"];
                  final wrinkles = widget.reports["wrinkle"];
                  final darkspots = widget.reports["age_spot"];
                  final darkcircles = widget.reports["dark_circle_v2"];
                  final radiance = widget.reports["radiance"];
                  final skinAge = widget.score["skinAge"];
                  final overallScore = widget.score["overallScore"];

                  if (dryness == null) {
                    print("dryness is null");
                  }
                  if (redness == null) {
                    print("redness is null");
                  }
                  if (oillness == null) {
                    print("oillness is null");
                  }
                  if (acne == null) {
                    print("acne is null");
                  }
                  if (pores == null) {
                    print("pores is null");
                  }
                  if (texture == null) {
                    print("texture is null");
                  }
                  if (wrinkles == null) {
                    print("wrinkles is null");
                  }
                  if (darkspots == null) {
                    print("darkspots is null");
                  }
                  if (darkcircles == null) {
                    print("darkcircles is null");
                  }
                  if (radiance == null) {
                    print("radiance is null");
                  }
                  if (skinAge == null) {
                    print("skinAge is null");
                  }
                  if (overallScore == null) {
                    print("overallScore is null");
                  }

                  // Check if any of the values are null before proceeding
                  if (dryness == null ||
                      redness == null ||
                      oillness == null ||
                      acne == null ||
                      pores == null ||
                      texture == null ||
                      wrinkles == null ||
                      darkspots == null ||
                      darkcircles == null ||
                      radiance == null ||
                      skinAge == null ||
                      overallScore == null) {
                    return SkinAnalysisCubit()
                      ..emit(SkinAnalysisError("Missing necessary data."));
                  }

                  // If everything is valid, proceed with the call
                  return SkinAnalysisCubit()
                    ..fetchSkinAnalysis(
                      dryness,
                      redness,
                      oillness,
                      acne,
                      pores,
                      texture,
                      wrinkles,
                      darkspots,
                      darkcircles,
                      radiance,
                      skinAge,
                      overallScore,
                    );
                },
                child: BlocBuilder<SkinAnalysisCubit, SkinAnalysisState>(
                  builder: (context, state) {
                    if (state is SkinAnalysisLoading) {
                      return const ProductCardWithShimmer(count: 2);
                    } else if (state is SkinAnalysisError) {
                      print(state.message);
                      return Center(child: Text(state.message));
                    } else if (state is SkinAnalysisSuccess) {
                      final categories = _filterValidCategories(
                          state.response.data.categories);

                      if (categories.isEmpty) {
                        return const Center(child: Text('no product now'));
                      }

                      return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 2.2,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductScreen(
                                            productId: categories[index]
                                                .details
                                                .ar!
                                                .id!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ProductCard(
                                          product: _createProductFromDetails(
                                              categories[index].details),
                                          fakeProduct: "",
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Color(0xFFEAEAEA),
                thickness: 1.5,
              ),

              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.report,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
              ),
              // Feature Details Section
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: widget.capturedFeatures.length ,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index < widget.capturedFeatures.length) {
                    final feature = widget.capturedFeatures[index];
                    print(feature);
                    final featureName = feature["name"];
                    print(featureName);

                    // Move this translation function outside of the itemBuilder
                    String getTranslatedFeatureName(String featureName) {
                      switch (featureName) {
                        case 'moisture':
                          return AppLocalizations.of(context)!.moisture;
                        case 'oiliness':
                          return AppLocalizations.of(context)!.oiliness;
                        case 'redness':
                          return AppLocalizations.of(context)!.redness;
                        case 'texture':
                          return AppLocalizations.of(context)!.texture;
                        case 'wrinkle':
                          return AppLocalizations.of(context)!.wrinkle;
                        case 'age_spot':
                          return AppLocalizations.of(context)!.age_spot;
                        case 'acne':
                          return AppLocalizations.of(context)!.acne;
                        case 'dark_circle_v2':
                          return AppLocalizations.of(context)!.dark_circle_v2;
                        case 'pore':
                          return AppLocalizations.of(context)!.pore;
                        case 'radiance':
                          return AppLocalizations.of(context)!.radiance;
                        default:
                          return featureName; // Return original if no translation found
                      }
                    }

                    // Translate featureName
                    final translatedFeatureName = getTranslatedFeatureName(featureName);

                    final featureImage = feature["image"];
                    final scoreString = widget.reports[featureName] ?? "0";
                    final int score = int.tryParse(scoreString) ?? 0;
                    final assessment = getAssessmentLevel(score);

                    final isArabic = AppLocalizations.of(context)!.localeName == 'ar'; // Assuming 'ar' is the Arabic locale
                    final concernsMap = isArabic ? featureConcernsArabic : featureConcernsEnglish;

                    // Get the concern based on the assessment level
                    final concern = concernsMap[featureName]?.values.first[assessment] ?? "";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: featureImage.image,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      Text(translatedFeatureName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                      ),
                                      Text("${AppLocalizations.of(context)!.score}: $score",
                                          style: const TextStyle(color: Colors.black, fontSize: 14)),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 0.0, vertical: 0),
                                              child: CustomProgressBar(progress: score / 100, score: score),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                concern, // Display the concern based on the assessment level
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 10, // Height of the radar chart

                      ),
                    );
                  }
                },
              )


            ],
          ),
        ),
      ),
      /* floatingActionButton:   FloatingActionButton(
        backgroundColor: Colors.white,

        shape:  CircleBorder(
          side: BorderSide(
            color: mainColor,
          )
        ),
        elevation: 2,
        child: Icon(Icons.picture_as_pdf, color: mainColor,),
       onPressed: () {
         for (var feature in widget.capturedFeatures) {
           inspectImageDetails(feature['image']);
         }

       },
      ),*/
    );
  }

// Radar chart data based on the reports
  RadarChartData getRadarChartData() {
    // Function to get the translated feature name
    String getTranslatedFeatureName(String featureName) {
      switch (featureName) {
        case 'moisture':
          return AppLocalizations.of(context)!.moisture;
        case 'oiliness':
          return AppLocalizations.of(context)!.oiliness;
        case 'redness':
          return AppLocalizations.of(context)!.redness;
        case 'texture':
          return AppLocalizations.of(context)!.texture;
        case 'wrinkle':
          return AppLocalizations.of(context)!.wrinkle;
        case 'age_spot':
          return AppLocalizations.of(context)!.age_spot;
        case 'acne':
          return AppLocalizations.of(context)!.acne;
        case 'dark_circle_v2':
          return AppLocalizations.of(context)!.dark_circle_v2;
        case 'pore':
          return AppLocalizations.of(context)!.pore;
        case 'radiance':
          return AppLocalizations.of(context)!.radiance;
        default:
          return featureName; // Return original if no translation found
      }
    }

    // Translate all feature names
    final keys = widget.reports.keys.toList();
    final translatedKeys =
        keys.map((key) => getTranslatedFeatureName(key)).toList();

    final values =
        widget.reports.values.map((e) => double.tryParse(e) ?? 0.0).toList();

    return RadarChartData(
      borderData: FlBorderData(
        border: Border.all(color: Colors.white, width: 1),
      ),
      dataSets: [
        RadarDataSet(
          fillColor: Colors.blue.withOpacity(0.4),
          borderColor: Colors.blue,
          entryRadius: 3,
          borderWidth: 1,
          dataEntries: values
              .map((value) => RadarEntry(
                    value: value,
                  ))
              .toList(),
        ),
      ],
      ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 10),
      radarBackgroundColor: Colors.transparent,
      gridBorderData: BorderSide(color: Colors.grey),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 10),
      getTitle: (index) => translatedKeys[index],
      radarBorderData: BorderSide(color: Colors.grey),
      titlePositionPercentageOffset: .15,
      tickBorderData: BorderSide(color: Colors.grey),
    );
  }


  bool isDownloading = false;
  String progress = '';

  Future<void> inspectImageDetails(dynamic image) async {
    try {
      // Check if the image is a MemoryImage
      if (image is MemoryImage) {
        // Extract the Uint8List from MemoryImage
        final ByteData? byteData =
            (await image.obtainKey(const ImageConfiguration())) as ByteData?;
        if (byteData != null) {
          final Uint8List imageBytes = byteData.buffer.asUint8List();

          // Get image size (in bytes)
          final imageSize = imageBytes.lengthInBytes;
          print("Image is of type MemoryImage");
          print("Image Size: $imageSize bytes");

          // Decode the image to check the format (PNG/JPG)
          img.Image? decodedImage = img.decodeImage(imageBytes);
          if (decodedImage != null) {
            final imageFormat = decodedImage.hasAlpha ? 'PNG' : 'JPG';
            print("Image Format: $imageFormat");
          } else {
            print("Unable to decode image format");
          }
        }
      } else if (image is FileImage) {
        // Handle FileImage (image from device storage)
        final String filePath = image.file.path;

        // Get image size (in bytes)
        final file = File(filePath);
        final fileSize = await file.length();
        print("Image is of type FileImage");
        print("Image Size: $fileSize bytes");

        // Optionally, check the format of the image based on file extension
        final fileExtension = filePath.split('.').last;
        print("Image Format based on extension: $fileExtension");

        // Decode the image to check the format
        final bytes = await file.readAsBytes();
        img.Image? decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          final imageFormat = decodedImage.hasAlpha ? 'PNG' : 'JPG';
          print("Image Format: $imageFormat");
        } else {
          print("Unable to decode image format");
        }
      } else {
        print("Unsupported image type");
      }
    } catch (e) {
      print("Error inspecting image: $e");
    }
  }

  List<ProductCategory> _filterValidCategories(
      List<ProductCategory> categories) {
    return categories.where((category) {
      final details = category.details;

      final hasValidAr = details.ar != null &&
          details.ar!.id != null &&
          details.ar!.name != null &&
          details.ar!.description != null;

      final hasValidEn = details.en != null &&
          details.en!.id != null &&
          details.en!.name != null &&
          details.en!.description != null;

      final isValid = hasValidAr || hasValidEn;
      if (!isValid) {
        print("Invalid category: ${category.key}");
      }

      return isValid;
    }).toList();
  }

  Product _createProductFromDetails(ProductDetails details) {
    final preferredDetails = details.ar ?? details.en;
    if (preferredDetails == null) {
      throw Exception("Both 'ar' and 'en' details are null");
    }

    return Product(
      short_description: preferredDetails.description ?? "",
      sale_price: preferredDetails.salePrice ?? 0.0,
      regularPrice: preferredDetails.regularPrice ?? 0.0,
      categoryId: preferredDetails.id ?? 0,
      images: [preferredDetails.image ?? ""],
      imageUrl: preferredDetails.image ?? "",
      id: preferredDetails.id ?? 0,
      name: preferredDetails.name ?? "",
      price: preferredDetails.price ?? 0.0,
      description: preferredDetails.description ?? "",
      avrage_rating:  "0.0",
    );
  }
}
