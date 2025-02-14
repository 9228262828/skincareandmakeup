import 'package:Gomla/Engin/skin_cubit_and_states.dart';
import 'package:Gomla/Engin/utility/styles.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../contstants.dart';
import '../models/product.dart';
import '../screens/product_screen.dart';
import '../test.dart';
import '../widgets/language_selector.dart';
import '../widgets/product_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final translatedKeys = keys.map((key) => getTranslatedFeatureName(key)).toList();

    final values = widget.reports.values
        .map((e) => double.tryParse(e) ?? 0.0)
        .toList();

    return RadarChartData(
      dataSets: [
        RadarDataSet(
          fillColor: Colors.blue.withOpacity(0.4),
          borderColor: Colors.blue,
          entryRadius: 3,
          borderWidth: 1,

          dataEntries: values.map((value) => RadarEntry(value: value)).toList(),
        ),
      ],
      radarBackgroundColor: Colors.transparent,
      gridBorderData: BorderSide(color: Colors.grey),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 10),
      getTitle: (index) => translatedKeys[index], // Use translated keys here
      radarBorderData: BorderSide(color: Colors.grey),
      titlePositionPercentageOffset: .09,
    );
  }

  final String pdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
  bool isDownloading = false;
  String progress = '';

  Future<void> _openPdf() async {
    if (await canLaunch(pdfUrl)) {
      await launch(pdfUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open PDF.")),
      );
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      isDownloading = true;
      progress = '0%';
    });

    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/sample.pdf';

      await dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = '${((received / total) * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF downloaded to: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading PDF: $e")),
      );
    } finally {
      setState(() {
        isDownloading = false;
        progress = '';
      });
    }
  }






  Future<void> inspectImageDetails(dynamic image) async {
    try {
      // Check if the image is a MemoryImage
      if (image is MemoryImage) {
        // Extract the Uint8List from MemoryImage
        final ByteData? byteData = (await image.obtainKey(const ImageConfiguration())) as ByteData?;
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


  @override
  Widget build(BuildContext context) {

    print(widget.skinAnalysisData);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor:   Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.skinAnalysisReport,
          style: TextStyle(color: Colors.black),
        ),

      ),

      body: RefreshIndicator(
        onRefresh: () async {
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: mediaQueryHeight(context) * 0.3,
                  decoration: BoxDecoration(

                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.skinAge, style: TextStyle(color: Colors.black, fontSize: 22)),
                          Text( widget.score['skinAge'], style: TextStyle(color: Colors.indigo, fontSize: 26)),

                          Text(AppLocalizations.of(context)!.overallScore, style: TextStyle(color: Colors.black, fontSize: 22)),
                          Text( widget.score['overallScore'], style: TextStyle(color: Colors.indigo, fontSize: 26)),


                        ]

                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: RadarChart(
                            getRadarChartData(),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
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
                create: (context) =>
                SkinAnalysisCubit()..fetchSkinAnalysis(widget.skinAnalysisData),
                child: BlocBuilder<SkinAnalysisCubit, SkinAnalysisState>(
                  builder: (context, state) {
                    if (state is SkinAnalysisLoading) {
                      return const ProductCardWithShimmer(count: 2,);
                    } else if (state is SkinAnalysisError) {
                      print(state.message);
                      return Center(child: Text(state.message));
                    } else if (state is SkinAnalysisSuccess) {
                      final categories = _filterValidCategories(
                          state.response.data.categories);

                      if (categories.isEmpty) {
                        return const Center(child: Text('No valid products found'));
                      }

                      return  Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 2.2,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                physics:  const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductScreen(
                                                  productId:  categories[index].details.ar!.id!),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2.2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ProductCard(
                                          product: _createProductFromDetails(categories[index].details), fakeProduct: "",),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                padding: const EdgeInsets.all(10),
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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  height: MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: featureImage.image,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(translatedFeatureName, // Display translated name
                                          style: const TextStyle(color: Colors.black, fontSize: 16)),
                                      Text("${AppLocalizations.of(context)!.score}: $score",
                                          style: const TextStyle(color: Colors.black, fontSize: 14)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomProgressBar(progress: score / 100, score: score),
                                      ),
                                      Text(
                                        "${AppLocalizations.of(context)!.assessment} $assessment",
                                        style: TextStyle(color: getAssessmentColor(assessment), fontSize: 14, fontWeight: FontWeight.bold),
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
      floatingActionButton:   FloatingActionButton(
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
      ),
    );
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
