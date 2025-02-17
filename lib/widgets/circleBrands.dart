
import 'dart:ffi';

import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart'; // Add this import
import '../controllers/brands_controller/brands_cubit.dart';
import '../controllers/brands_controller/brands_states.dart';
import '../models/brand.dart';
import '../screens/brand_listing_screen.dart';
import '../services/woocommerce_service.dart';
import '../widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class CircleBrands extends StatelessWidget {
  const CircleBrands({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandsCubit, BrandsState>(
      bloc: BrandsCubit(WooCommerceService())..fetchBrands(),
      builder: (context, state) {
        if (state is BrandsInitial || state is BrandsLoading) {
          return _buildShimmerGrid(context); // Show shimmer while loading
        } else if (state is BrandsError) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noProductsAvailable),
          );
        } else if (state is BrandsLoaded) {
          final brands = state.brands;

          print(brands);
          if (brands.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noBrandsAvailable),
            );
          }
          return SizedBox(
            height: mediaQueryHeight(context) * 0.15,
            child: ListView.builder(
              itemCount: brands.length,
              physics:  BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
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
                            Container(
                              width: mediaQueryWidth(context) * 0.18,
                              height: mediaQueryWidth(context) * 0.18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                               color: mainColor,
                              ),
                              /*child: brand.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: brand.imageUrl,
                                      width: mediaQueryHeight(context) * 0.1,
                                      height: mediaQueryWidth(context) * 0.1,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) => Image.asset(
                                          "assets/placeholder.png") // Use an icon or any fallback widget
                                    )
                                  : Image.asset("assets/placeholder.png"
                            ),*/

                            ),

                            SizedBox(height: mediaQueryWidth(context) * 0.02),
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
          );
        }
        return SizedBox(); // Fallback for unexpected states
      },
    );
  }
  Widget _buildShimmerGrid(BuildContext context) {
    return SizedBox(
      height: mediaQueryHeight(context)*.15,
      child: ListView.builder(
        itemCount: 10, // Show 10 shimmer placeholders for testing
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: mediaQueryWidth(context) * 0.18,
                    height: mediaQueryWidth(context) * 0.18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                SizedBox(height: mediaQueryWidth(context) * 0.02),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: mediaQueryWidth(context) * 0.2,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
