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
                  width: mediaQueryHeight(context) * 0.15,
                  height: mediaQueryWidth(context) * 0.15,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 10,
                  width: mediaQueryWidth(context) * 0.2,
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
      body: BlocBuilder<BrandsCubit, BrandsState>(
        bloc: BrandsCubit(WooCommerceService())..fetchBrands(),
        builder: (context, state) {
          if (state is BrandsInitial || state is BrandsLoading) {
            return _buildShimmerGrid(context); // Show shimmer while loading
          } else if (state is BrandsError) {

            return Center(
              child: Text(AppLocalizations.of(context)!.noProductsAvailable , ),
            );
          } else if (state is BrandsLoaded) {
            final brands = state.brands;

            print(brands);
if (brands.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noBrandsAvailable),
              );
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final brandId = brand.id is String
                    ? brand.id ?? 0 // If it's a string, try to parse it to int
                    : brand.id;
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
                                id:  brandId,
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
                              errorWidget: (context, url, error) => Image.asset(
                                  "assets/placeholder.png") // Use an icon or any fallback widget
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
            );
          }
          return SizedBox(); // Fallback for unexpected states
        },
      ),
    );
  }
}
