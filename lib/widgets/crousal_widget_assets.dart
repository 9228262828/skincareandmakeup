import 'package:Gomla/shared/utils/app_values.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';

class ScrollingCarouselWidget extends StatefulWidget {
 final  bool isMain;

  const ScrollingCarouselWidget({super.key, required this.isMain});
  @override
  _ScrollingCarouselWidgetState createState() =>
      _ScrollingCarouselWidgetState();
}

class _ScrollingCarouselWidgetState extends State<ScrollingCarouselWidget> {
  int _currentIndex = 0; // Track the current index of the carousel

  List<String> imageUrls = [
    "assets/banner1.png",
    "assets/banner2.png",
    "assets/banner3.png",
  ]; // Example image URLs for carousel items

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CarouselSlider.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index, realIndex) {
          // Apply scaling to central item

          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,

            child: Container(

              child: ClipRRect(
                borderRadius: BorderRadius.circular(!widget.isMain ? 0 : 10),
                child: Image.asset(
                  imageUrls[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          aspectRatio: 1.0,
          height: MediaQuery.of(context).size.height * 0.2, // Set the height of the carousel
          enlargeCenterPage: true, // This enlarges the central item
          enableInfiniteScroll: true, // Infinite scroll
          reverse: false, // Normal scrolling direction (can be reversed if needed)
          initialPage: 0,
          viewportFraction: 0.95, // 80% of the screen width, showing the edges of other images
          autoPlay: true, // Enable auto-play to move the carousel automatically
          autoPlayInterval: Duration(seconds: 3), // Time interval between slides
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
