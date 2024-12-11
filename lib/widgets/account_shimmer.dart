import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyShimmerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: mediaQueryHeight * 0.08),
              shimmerWidget(
                child: Container(
                  height: mediaQueryHeight * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 25,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            shimmerWidget(child: Container(height: 10, width: 100)),
                            shimmerWidget(child: Container(height: 10, width: 150)),
                            shimmerWidget(child: Container(height: 10, width: 200)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              SizedBox(
                height: mediaQueryHeight * 0.1,
                child: shimmerWidget(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 2.1,
                    ),
                    padding: const EdgeInsets.all(0),
                    itemCount: 2, // Example number of items
                    itemBuilder: (context, index) {
                      return shimmerWidget(
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                shimmerWidget(child: Container(height: 40, width: 40)),
                                SizedBox(width: 10),
                                shimmerWidget(child: Container(height: 10, width: 80)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              shimmerWidget(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: mediaQueryHeight * 0.078,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        shimmerWidget(child: Container(height: 10, width: 150)),
                        shimmerWidget(child: Container(height: 50, width: 50)),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: mediaQueryHeight * 0.02),
              shimmerWidget(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        shimmerWidget(child: Container(   height: mediaQueryHeight * 0.078, width: 100)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              shimmerWidget(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        shimmerWidget(child: Container(   height: mediaQueryHeight * 0.078, width: 100)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),

              shimmerWidget(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: mediaQueryHeight * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          shimmerWidget(child: Container(height: 10, width: 100)),
                          shimmerWidget(child: Container(height: 25, width: 25)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              shimmerWidget(
                child: Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'All rights reserved',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerWidget({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}
