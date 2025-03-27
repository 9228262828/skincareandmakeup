import 'package:Gomla/shared/utils/app_values.dart';
import 'package:Gomla/widgets/product_card.dart';
import 'package:Gomla/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/best_deals_controller/best_deals_cubit.dart';
import '../controllers/best_deals_controller/best_deals_states.dart';
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
        else if (type == "healthAndBeauty") {
          print("healthAndBeauty");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals1(context, "https://gomla.sa/wp-json/wc/v3/products?orderby=rating&order=desc");
          return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
        }

        print("else");
        return BestDealsCubit(WooCommerceService())..fetchBestDeals(context, categoryId);
      },
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            _buildHeader(context),
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
                  return _buildProductList(context, state.products , type);
                } else if (state is BestDealsError) {

                  print("Error:     ${state.error}");
                  return _buildError(state.error);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                title,
                style:
                     TextStyle(

                        fontSize:
                            type == "healthAndBeauty" || type == "relatedProducts" ? 15 : 17, fontWeight: FontWeight.w700),
              ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(AppLocalizations.of(context)!.all,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4278a6),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProductList(BuildContext context, List<Product> products,type) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey.shade200,
            height: type != "recentlyViewedProducts" && type != "healthAndBeauty"
                ? mediaQueryHeight(context) * .425
                : mediaQueryHeight(context) * 0.17,
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
                    width: type != "recentlyViewedProducts" && type != "healthAndBeauty"? MediaQuery
                        .of(context)
                        .size
                        .width / 2.2 : mediaQueryWidth(context) * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: type != "recentlyViewedProducts"&& type != "healthAndBeauty" ?ProductCard(
                        product: products[index], fakeProduct: "",) : ProductCardEmpty(product: products[index], fakeProduct: "",),
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
        '  $message',
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
