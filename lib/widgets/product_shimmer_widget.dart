import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardWithShimmer extends StatelessWidget {
final int? count;

  const ProductCardWithShimmer({
    Key? key, this.count,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: count,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        scrollDirection:  Axis.vertical,
        itemBuilder: (context, index) {
          return ShimmerCard();
        },
      ),
    );
  }
}
class ProductCardWithShimmerAllScreen extends StatelessWidget {
final int? count;

  const ProductCardWithShimmerAllScreen({
    Key? key, this.count,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12,
        ),
        itemCount: count,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        scrollDirection:  Axis.vertical,
        itemBuilder: (context, index) {
          return ShimmerCard();
        },
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 1,
            offset: Offset(0, 0), // shadow position
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(8.0),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Shimmer for Image
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),

             /* // Shimmer for Favorite button
              Positioned(
                  top: 10,
                  right: 10,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  )),

              // Shimmer for Add to Cart button
              Positioned(
                bottom: -10,
                left: 5,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),

              // Shimmer for Quantity buttons
              Positioned(
                  bottom: -10,
                  right: 5,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  )),*/
            ],
          ),

          // Shimmer for product name
          SizedBox(height: 12.0),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20.0,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.white,
            ),
          ),

          // Shimmer for price

          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20.0,
              width: MediaQuery.of(context).size.width * 0.5,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
