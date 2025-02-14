import 'package:Gomla/shared/utils/app_values.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/banner.dart';
import '../providers/banner_repo.dart';
import '../screens/brand_listing_screen.dart';
import '../screens/product_listing_screen.dart';
import '../screens/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeBannerSlider extends StatelessWidget {
  final List<Bannerr>? banners;

  HomeBannerSlider({super.key, this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners == null || banners!.isEmpty) {
      return Center(child: Text('No banners available.'));
    }

    // Filter only the banners with featured == 1
    List<Bannerr> featuredBanners = banners!.where((banner) => banner.featured == "1").toList();

    if (featuredBanners.isEmpty) {
      return Center(child: Text('No featured banners available.'));
    }

    return Container(
      width: double.infinity,
      height: mediaQueryHeight(context) * 0.23,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: CarouselSlider.builder(
        itemCount: featuredBanners.length,
        itemBuilder: (context, index, realIndex) {
          final banner = featuredBanners[index];
          return GestureDetector(
            onTap: () {
              if (banner.termType == "external") null;
              if (banner.termType == "product") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductScreen(
                              productId: int.parse(banner.termId)),
                    ));
              }
              if (banner.termType == "category") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductListingScreen(
                          categoryId: int.parse(banner.termId),
                          categoryName: banner.termName!,
                          type: "id",
                          isLink: false,
                        ),
                  ),
                );
              }
              if (banner.termType == "brand") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BrandProductsScreen(
                          isLink: false,
                          brandName: banner.termName!,
                          id: int.parse(banner.termId),
                        ),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                banner.image,
                width: double.infinity,
                fit: BoxFit.fill,
                height: mediaQueryHeight(context) * 0.3,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
          );
        },
        options: CarouselOptions(
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          pauseAutoPlayOnTouch: true,
          pauseAutoPlayOnManualNavigate: true,
          height: mediaQueryHeight(context) * 0.35,
          scrollPhysics: BouncingScrollPhysics(),

          viewportFraction: .85,
          onPageChanged: (index, reason) {
          },
        ),
      ),
    );
  }
}


class IndexedBannerWidget extends StatelessWidget {
  final int index;
  final List<Bannerr> banners;

  const IndexedBannerWidget({
    Key? key,
    required this.index,
    required this.banners,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (index < 0 || index >= banners.length) {
      return SizedBox.shrink(); // Return an empty widget if the index is out of range
    }

    final banner = banners[index];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (banner.termType == "external") null;
          if (banner.termType == "product") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductScreen(
                          productId: int.parse(banner.termId)),
                ));
          }
          if (banner.termType == "category") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductListingScreen(
                      categoryId: int.parse(banner.termId),
                      categoryName: banner.termName!,
                      type: "id",
                      isLink: false,
                    ),
              ),
            );
          }
          if (banner.termType == "brand") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BrandProductsScreen(
                      isLink: false,
                      brandName: banner.termName!,
                      id: int.parse(banner.termId),
                    ),
              ),
            );
          }
        },
        child: Container(
          height: mediaQueryHeight(context) * 0.22,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: banner.image,
                  width: double.infinity,
                  height: mediaQueryHeight(context) * 0.22,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Shimmer.fromColors( // Add shimmer or any other loading indicator
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.grey.shade200,
                          width: double.infinity,
                          height: mediaQueryHeight(context) * 0.22,
                        ),
                      ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
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
      ),
    );
  }
}
