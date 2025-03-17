import 'dart:ffi';

import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart'; // Add this import
import '../controllers/brands_controller/brands_cubit.dart';
import '../controllers/brands_controller/brands_states.dart';
import '../models/brand.dart';
import '../services/woocommerce_service.dart';
import '../widgets/app_bar.dart';
import 'brand_listing_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandsScreen extends StatefulWidget {
  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isLastPage = false;
  int currentPage = 1;
  late WooCommerceService wooCommerceService;
  List<Brand> mainBrands = [];

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();
    fetchMainBrands(); // Initial fetch
    _scrollController.addListener(_scrollListener);
  }

  // Fetch the next page of categories (brands)
  Future<void> fetchMainBrands({int page = 1}) async {
    if (isLoadingMore || isLastPage) return; // Prevent multiple requests

    setState(() {
      isLoadingMore = true;
    });

    try {
      List<Brand> newBrands = await wooCommerceService.fetchBrands(page: page);

      if (newBrands.isEmpty) {
        setState(() {
          isLastPage = true;
        });
      } else {
        setState(() {
          mainBrands.addAll(newBrands); // Add the new brands to the list
          currentPage++;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  // Listener for when the user scrolls to the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      fetchMainBrands(page: currentPage); // Fetch more brands when reaching the bottom
    }
  }

  // Build shimmer effect grid while loading
  Widget _buildShimmerGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 21, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity, // Make shimmer take up the full width
                  height: mediaQueryWidth(context) * 0.15, // Adjust the height as needed
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 10,
                  width: double.infinity, // Full width for shimmer effect
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '', home: true),
      body: isLoading
          ? _buildShimmerGrid(context) // Show shimmer effect while loading
          : NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
            fetchMainBrands(page: currentPage); // Trigger pagination when reaching the end
          }
          return false;
        },
        child: GridView.builder(
          controller: _scrollController, // Attach scroll controller
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: mainBrands.length + (isLoadingMore && !isLastPage ? 1 : 0),
          itemBuilder: (context, index) {
            // Show shimmer only when more brands are being loaded and we are not at the last page
            if (index == mainBrands.length && isLoadingMore && !isLastPage) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity, // Full width shimmer
                    height: 50, // Adjust height for loading shimmer
                    color: Colors.grey[300],
                  ),
                ),
              );
            }

            // If we reached the end and are done loading, don't show the shimmer
            if (index == mainBrands.length && isLastPage) {
              return SizedBox();
            }

            final brand = mainBrands[index];
            final brandId = brand.id is String ? brand.id ?? 0 : brand.id;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BrandProductsScreen(
                            brandName: brand.name,
                            id: brandId,
                            isLink: false,
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
                          width: mediaQueryHeight(context) * 0.15,
                          height: mediaQueryWidth(context) * 0.15,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => Image.asset("assets/placeholder.png"), // Fallback image
                        ),
                        SizedBox(width: 10),
                        Text(brand.name),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
