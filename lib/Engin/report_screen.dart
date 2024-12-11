import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ads.dart';
import 'custom_progress_bar.dart';

class ReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> capturedFeatures;
  final Map<String, String> reports;

  ReportScreen(
      {Key? key, required this.capturedFeatures, required this.reports})
      : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isArabic = false;

  // Function to get the assessment level based on the score
  String getAssessmentLevel(int score) {
    if (score < 70)
      return "Weak";
    else if (score < 80)
      return "Average";
    else
      return "Good";
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
    final keys = widget.reports.keys.toList();
    final values = widget.reports.values
        .map((e) => double.tryParse(e) ?? 0.0)
        .toList();

    return RadarChartData(
      dataSets: [
        RadarDataSet(
          fillColor: Colors.blue.withOpacity(0.4),
          borderColor: Colors.blue,
          entryRadius: 3,
          dataEntries: values.map((value) => RadarEntry(value: value)).toList(),
        ),
      ],
      radarBackgroundColor: Colors.transparent,
      gridBorderData: BorderSide(color: Colors.grey),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 12),
      getTitle: (index) => keys[index],
      radarBorderData: BorderSide(color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skin Report",style: TextStyle(color: Colors.black),),
       /* actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() {
                isArabic = !isArabic;
              });
            },
          ),
        ],*/
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: widget.capturedFeatures.length + 1,
        itemBuilder: (context, index) {
          if (index < widget.capturedFeatures.length) {
            final feature = widget.capturedFeatures[index];
            final featureName = feature["name"];
            final featureImage = feature["image"];
            final scoreString = widget.reports[featureName] ?? "0";
            final int score = int.tryParse(scoreString) ?? 0;
            final assessment = getAssessmentLevel(score);
            final concerns = isArabic
                ? featureConcernsArabic[featureName] ?? {}
                : featureConcerns[featureName] ?? {};

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
                                image: featureImage.image, fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(featureName,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16)),
                              Text("Score: $score",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomProgressBar(
                                    progress: score / 100, score: score),
                              ),
                              Text(
                                "Assessment: $assessment",
                                style: TextStyle(
                                    color: getAssessmentColor(assessment),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ...concerns.entries.map((entry) {
                      final concernTitle = entry.key;
                      final message = entry.value[assessment] ??
                          "No information available";
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, width: 0.5),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: Colors.blueAccent.withAlpha(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(concernTitle,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              Text(message,
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300, // Height of the radar chart
                child: RadarChart(getRadarChartData()),
              ),
            );
          }
        },
      ),
     /* bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width * .9,
        color: Colors.blue,
        height: MediaQuery.of(context).size.height * .1,
        child: Center(
          child: Text(
            'Bottom Navigation',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),*/
    );
  }
}
