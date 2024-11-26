import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skincare/providers/home_screen_provider.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import '../services/woocommerce_service.dart';
import '../models/brand.dart';
import 'package:provider/provider.dart';
import '../localization/localization_provider.dart';
import 'brand_listing_screen.dart';

class BrandsScreen extends StatefulWidget {
  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  late WooCommerceService wooCommerceService;
  List<Brand> brands = [];
  int page = 1;
  bool isLoading = false;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    if (isLoading || isLastPage) return;
    setState(() {
      isLoading = true;
    });
    try {
      List<Brand> newBrands = await wooCommerceService.fetchBrands(context);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: homeScreenProvider.brands.length,
        itemBuilder: (context, index) {
          if (homeScreenProvider.brands.isEmpty) {
            return Center(child: FadeInOutImage(height: MediaQuery.of(context).size.height));
          }
          final brand = homeScreenProvider.brands[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrandListingScreen(
                        brandId: brand.id,
                        brandName: brand.name,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: brand.imageUrl,
                      width: 150,
                      height: 50,
                      // fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: Image.asset('assets/grey_image.jpeg')),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    SizedBox(width: 10),
                    Text(brand.name),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
