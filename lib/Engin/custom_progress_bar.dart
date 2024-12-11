import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0
  final int score; // Actual score to determine color

  const CustomProgressBar({Key? key, required this.progress, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the gradient color based on the score
    final gradientColors = score > 80
        ? [Colors.green.shade300, Colors.green.shade600]
        : [Colors.orange.shade300, Colors.orange.shade600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row to position the icon above the progress bar
        Row(
          children: [
            // Empty spacer based on progress to align the icon correctly
            Spacer(flex: (progress * 100).toInt()),
            Icon(
              Icons.location_on,
              color: gradientColors.last,
              size: 24,
            ),
            Spacer(flex: (100 - progress * 100).toInt()), // Remaining space
          ],
        ),
        // Progress bar with gradient
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "   0   ",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "   100   ",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Min and Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [


            ],
          ),
        ),
      ],
    );
  }
}
