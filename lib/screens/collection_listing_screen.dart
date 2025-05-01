import 'package:Gomla/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/collection/collection_cubit.dart';
import '../controllers/collection/collection_states.dart';
import '../shared/utils/app_values.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/product_shimmer_widget.dart';


class CollectionListingScreen extends StatelessWidget {
  final String id;
  final String categoryName;
  const CollectionListingScreen({Key? key, required this.id, required this.categoryName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget _buildBrandHeader(String brandName) {
      return Container(
        width: mediaQueryWidth(context),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            brandName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => CollectionCubit()..fetchCollectionProducts( id),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: CustomPagesAppBar(
          title: AppLocalizations.of(context)!.collections, home: false,),
        body: BlocBuilder<CollectionCubit, CollectionState>(
          builder: (context, state) {
            if (state is CollectionLoading) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProductCardWithShimmer(count: 10),
              );
            } else if (state is CollectionError) {
               print(state.error);
              return Center(child: Text(state.error));

            }
if (CollectionCubit.get(context).products.isEmpty) {
  return Center(child: Text(AppLocalizations.of(context)!.noProductsFound));
}
            final products = CollectionCubit.get(context).products;

            return  Column(
              children: [
 _buildBrandHeader(categoryName.replaceAll('&amp;', '&')),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount:  products.length, // Show shimmer for load more
                    itemBuilder: (context, index) {

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                productId: products[index].id,
                              ),
                            ),
                          );
                        },
                        child: ProductCard(
                          product: products[index], fakeProduct: "",),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}
