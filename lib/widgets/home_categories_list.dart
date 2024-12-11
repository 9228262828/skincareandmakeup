import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import skeletonizer package

import '../controllers/categories_controller/categories_cubit.dart';
import '../controllers/categories_controller/categories_states.dart';
import '../screens/product_listing_screen.dart';
import '../services/woocommerce_service.dart';
import '../shared/utils/app_values.dart';

Widget buildCategoriesList(BuildContext context) {
  return BlocProvider(
    create: (context) =>
        CategoriesCubit(WooCommerceService())..fetchCategories(context),
    child: BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          // Show skeleton loading state
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      // Display 5 skeletons while loading
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 100,
                          child: Skeletonizer(
                            enabled: true, // Enable skeleton loading
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  color: Colors.grey[300],
                                  height: 12,
                                  width: 80,
                                ), // Simulate loading text
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        } else if (state is CategoriesError) {
          return Center(
              child: Text(state.error.toString())); // Show error message
        } else if (state is CategoriesLoaded) {
          final categories = state.categories;

          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            print('Category ID: ${category.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductListingScreen(
                                  categoryId: category.id,
                                  categoryName: category.name,
                                  type:  "id",
                                  isLink:  false,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: mediaQueryWidth(context) * 0.23,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: CachedNetworkImageProvider(
                                    category.imageUrl,
                                  ),
                                  radius: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );
}
