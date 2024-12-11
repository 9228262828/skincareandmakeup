import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';

class HomeBannerSlider extends StatelessWidget {
  HomeBannerSlider({super.key});

  List<String> images = [
    "assets/banner1.png",
    "assets/The-Pathland-2400X1100-6545610.png",
    "assets/CLARY-2400X1100-6465.png",
    "assets/The-Pathland-2400X1100-6545610.png",
    "assets/CLARY-2400X1100-6465.png",
    "assets/The-Pathland-2400X1100-6545610.png",
    "assets/CLARY-2400X1100-6465.png",
    "assets/The-Pathland-2400X1100-6545610.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: mediaQueryHeight(context) * 0.5,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          // Background Image
          Image(
            image: AssetImage(
              ImageAssets.banner1,
            ),
            width: double.infinity,
            fit: BoxFit.fitHeight,
            height: mediaQueryHeight(context) * 0.32,
          ),

          // ListView for the horizontal scrollable content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: mediaQueryHeight(context) * 0.23,
              // Set a fixed height for the list
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: images.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: mediaQueryWidth(context) * 0.35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Section
                          Container(
                            height: mediaQueryHeight(context) * 0.06,
                            width: mediaQueryWidth(context) * 0.35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                " خصم حتي 25% \nمستلزمات الرياضة",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ),
                          ),

                          // Image Section
                          Container(
                            height: mediaQueryHeight(context) * 0.16,
                            width: mediaQueryWidth(context) * 0.35,
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Image(
                              image: AssetImage(images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerHome extends StatelessWidget {
  final String image;

  const BannerHome({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: mediaQueryHeight(context) * 0.2,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: AssetImage(
                  image,
                ),
                width: double.infinity,
                fit: BoxFit.cover,
                height: mediaQueryHeight(context) * 0.5,
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: mediaQueryHeight(context) * 0.03,
                  width: mediaQueryWidth(context) * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "AD",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
