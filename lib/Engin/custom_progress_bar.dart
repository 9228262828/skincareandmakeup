import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0
  final int score; // Actual score to determine color

  const CustomProgressBar({
    Key? key,
    required this.progress,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the gradient color based on the score
    final gradientColors = score > 80
        ? [Colors.green.shade300, Colors.green.shade600]
        : score >= 60
        ? [Colors.orange.shade300, Colors.orange.shade600]
        : [Colors.red.shade300, Colors.red.shade600];

    // Get the text direction (LTR or RTL)
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with the icon and score
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
                color: Colors.grey.shade300,
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
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
            ),
            // Min (0) and Max (100) labels
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Position "100" based on text direction
                      Positioned(
                        left: isRTL ? 1 : null, // Left for RTL
                        right: isRTL ? null : 1, // Right for LTR
                        child: Text(
                          score != 99 &&
                              score != 98 &&
                              score != 97 &&
                              score != 96 &&
                              score != 95 &&
                              score != 94 &&
                              score != 93 &&
                              score != 92 &&
                              score != 91 &&
                              score != 90
                              ? "100"
                              : "",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Position the score dynamically under the icon
                      Positioned(
                        left: isRTL
                            ? constraints.maxWidth * (1-progress) - 7 // Right for RTL
                            : constraints.maxWidth * progress - 10, // Left for LTR
                       // Right for RTL
                        bottom: 1, // Position the score under the icon
                        child: Text(
                          "$score",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Position "0" based on text direction
                      Positioned(
                        left: isRTL ? null : 1, // Left for LTR
                        right: isRTL ? 1 : null, // Right for RTL
                        child: Text(
                          "0",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}