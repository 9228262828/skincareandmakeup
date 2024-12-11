import 'package:Gomla/widgets/product_card.dart';
import 'package:Gomla/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/best_deals_controller/best_deals_cubit.dart';
import '../controllers/best_deals_controller/best_deals_states.dart';
import '../contstants.dart';
import '../models/product.dart';
import '../screens/product_listing_screen.dart';
import '../screens/product_screen.dart';
import '../services/woocommerce_service.dart';

class ProductHomeWidget extends StatelessWidget {
  final String title;
  final int categoryId;
  final String type;
  final bool bestSellers;
  final bool allNeedsGrooming;
  final bool specialProducts;
  final bool bestRatings;
  final bool nearlyArrived;
  final bool exclusiveDeals;
  final bool isLink;


  const ProductHomeWidget({
    super.key,
    required this.title,
    required this.categoryId, required this.bestSellers, required this.allNeedsGrooming, required this.specialProducts, required this.bestRatings, required this.nearlyArrived, required this.exclusiveDeals, required this.type, required this.isLink,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        if (bestSellers) {
          print("bestSellers");

          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=popularity");
        } else if (bestRatings) {
          print("bestRatings");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=rating&order=desc");
        } else if (specialProducts) {
          print("specialProducts");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=rating&order=desc");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
        } else if (allNeedsGrooming) {
          print("allNeedsGrooming");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=rating&order=desc");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
        } else if (nearlyArrived) {
          print("nearlyArrived");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=date&order=desc");
        } else if (exclusiveDeals) {
          print("exclusiveDeals");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=rating&order=desc");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
        }

        print("else");
        return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
      },
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16.0),
            BlocBuilder<BestDealsCubit, BestDealsState>(
              builder: (context, state) {
                if (state is BestDealsLoading) {
                  return const ProductCardWithShimmer(count: 2,);
                } else if (state is BestDealsLoaded) {
                  // Check if the list is empty
                  if (state.products.isEmpty) {
                    return buildEmptyState(
                        context, AppLocalizations.of(context)!.noDealsAvailable);
                  }
                  return _buildProductList(context, state.products);
                } else if (state is BestDealsError) {
                  return _buildError(state.error);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductListingScreen(
                          categoryId: categoryId,
                          categoryName: title,
                          type: type,
                          isLink:  isLink,
                        ),
                  ),
                );
              },
              child: Container(
                decoration:   BoxDecoration(
                  border: Border.all(color: Colors.black,width: .5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.all,
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProductList(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height / 2.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              physics:  const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductScreen(
                                productId: products[index].id),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 2.2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ProductCard(
                        product: products[index], fakeProduct: "",),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Error: $message',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

Widget buildEmptyState(BuildContext context, String title) {
  return Container(
    color: Colors.yellow, // Show yellow container if products are empty
    child: Center(
      child: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    ),
  );
}
