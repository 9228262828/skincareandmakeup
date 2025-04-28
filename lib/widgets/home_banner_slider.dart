import 'package:Gomla/contstants.dart';
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

class HomeBannerSlider extends StatefulWidget {
  final List<Bannerr>? banners;
  HomeBannerSlider({super.key, this.banners});

  @override
  _HomeBannerSliderState createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  List<Bannerr> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      List<Bannerr> banners = await BannerService().fetchBanners();
      if (banners.isEmpty) {
        print('No banners found, retrying...');
        await Future.delayed(Duration(seconds: 2));
        await _fetchBanners();
      } else {
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
      }
      print('Fetched banners: ${banners.length}');
    } catch (error) {
      print('Error fetching banners: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: mainColor));
    }

    if (_banners.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No banners available, retrying..."),
          SizedBox(height: 10),
          CircularProgressIndicator(color: mainColor,),
        ],
      );
    }

    List<Bannerr> featuredBanners = _banners.where((banner) => banner.featured == "1").toList();

    if (featuredBanners.isEmpty) {
      return Center(child: Text('No featured banners available.'));
    }

    return Container(
      width: double.infinity,
      height: mediaQueryHeight(context) * 0.23,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3),
      ),
      child: CarouselSlider.builder(
        itemCount: featuredBanners.length,
        itemBuilder: (context, index, realIndex) {
          final banner = featuredBanners[index];
          return GestureDetector(
            onTap: () {
              if (banner.termType == "external") return;
              if (banner.termType == "product") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(
                        productId: int.parse(banner.termId),
                      ),
                    ));
              }
              if (banner.termType == "category") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(
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
                    builder: (context) => BrandProductsScreen(
                      isLink: false,
                      brandName: banner.termName!,
                      id: int.parse(banner.termId),
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  imageUrl: banner.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: mediaQueryHeight(context) * 0.3,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey.shade200),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          autoPlayInterval: Duration(seconds: 3),
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlay: true,
          pauseAutoPlayOnTouch: true,
          pauseAutoPlayOnManualNavigate: true,
          height: mediaQueryHeight(context) * 0.5,
          clipBehavior:   Clip.antiAlias,
          scrollPhysics: BouncingScrollPhysics(),
          viewportFraction: 0.9 , // The other images will be smaller
          onPageChanged: (index, reason) {},
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

    // ✅ Check current language
    String currentLanguage = Localizations.localeOf(context).languageCode;

    // ✅ Change term name based on language
    String termName = currentLanguage == 'en'
        ? _getEnglishTermName(banner.termId) // Get English termName based on ID
        : banner.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            termName,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: GestureDetector(
            onTap: () {
              if (banner.termType == "external") return;
              if (banner.termType == "product") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(
                      productId: int.parse(banner.termId),
                    ),
                  ),
                );
              }
              if (banner.termType == "category") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(
                      categoryId: int.parse(banner.termId),
                      categoryName: termName, // ✅ Pass modified name based on lang
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
                    builder: (context) => BrandProductsScreen(
                      isLink: false,
                      brandName: termName,
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
                borderRadius: BorderRadius.circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  imageUrl: banner.image,
                  width: double.infinity,
                  height: mediaQueryHeight(context) * 0.22,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
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
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Function to get English names for the termId
  String _getEnglishTermName(String termId) {
    switch (termId) {
      case '5056':
        return 'Skin Care';
      case '5023':
        return 'Personal Care';
      case '4773':
        return 'Beauty & Makeup';
      case '4869':
        return 'Fitness & Health';
      case '4848':
        return 'Made in Saudi Arabia';
      case '4801':
        return 'Makeup & Cosmetics';
      case '4728':
        return 'Body Care';
      default:
        return 'Unknown';
    }
  }
}
