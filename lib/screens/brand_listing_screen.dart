import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/product_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/utils/app_values.dart';
import '../controllers/brands_controller/brands_cubit.dart';
import '../controllers/brands_controller/brands_states.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer_widget.dart';

class BrandProductsScreen extends StatefulWidget {
  final int id;
  final String brandName;
  final bool isLink;

  const BrandProductsScreen({required this.id, super.key, required this.brandName, required this.isLink});

  @override
  _BrandProductsScreenState createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {

    super.initState();
    _scrollController.addListener(_onScroll);

    context.read<ProductsCubit>().fetchProductss( brandId: widget.id,isInitial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ProductsCubit>().fetchProductss( brandId: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: widget.brandName,home: false,),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoading && state.page == 1) {
                // Initial loading shimmer
                return  ProductCardWithShimmerAllScreen(count: 10); // Show 6 shimmer items
              } else if
              (state is ProductsLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductsCubit>().fetchProductss( brandId: widget.id);
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBrandHeader(widget.brandName),
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.5,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: state.hasReachedMax
                                ? state.Productss.length
                                : state.Productss.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.Productss.length) {
                                final products = state.Productss[index];

                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductScreen(
                                             productId: products.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ProductCard(product: products, fakeProduct: '',));
                              } else {
                                // Loading more shimmer
                                return _buildLoadMoreShimmer();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: mediaQueryHeight(context) * 0.04,
                        )
                      ]
                  ),
                );
              } else if (state is ProductsError) {
                return Center(child: Text(state.message));
              } else {
                return SizedBox.shrink();
              }
            },
          )
          ,
        ),
     //   bottomNavigationBar: _buildSortAndFilterButtons(cubit),
        floatingActionButtonLocation: FloatingActionButtonLocation
            .miniCenterDocked,
        floatingActionButton: widget.isLink == false ? Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: mediaQueryWidth(context) * 0.53,
                height: mediaQueryHeight(context) * 0.05,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: (){
                          showSortDialog(context, cubit,);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sort, color: Colors.white),
                            Text(
                              AppLocalizations.of(context)!.sort,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_list_outlined,
                              color: Colors.white,
                            ),
                            Text(
                              AppLocalizations.of(context)!.filter,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: mainColor,
                child: Icon(Icons.share, color: Colors.white),
              )
            ],
          ),
        ) : SizedBox(height: 0,),
      ),
    );
  }

  Widget _buildSortAndFilterButtons(cubit) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              showSortDialog(context, cubit,);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sort, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  "Sort",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {

            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  "Filter",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
  Widget _buildLoadMoreShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 10,
            scrollDirection:  Axis.horizontal,

            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: mediaQueryHeight(context) * 0.02),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[50]!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: mediaQueryHeight(context) * 0.35,
                        // Match the height of the image in your ProductCard
                        width: double.infinity,
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(

                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[50]!,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Colors.grey[200],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }


}



void showSortDialog(BuildContext context, cubit,  ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.sortProducts,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of sort options
                  Column(
                    children: [
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByDate),
                        leading: Radio<String>(
                          value: 'date',
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            setState(() {
                              cubit.selectedSortOption = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByPopularity),
                        leading: Radio<String>(
                          value: 'popularity',
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            setState(() {
                              cubit.selectedSortOption = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByRating),
                        leading: Radio<String>(
                          value: 'rating',
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            setState(() {
                              cubit.selectedSortOption = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByPrice),
                        leading: Radio<String>(
                          value: 'price',
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            setState(() {
                              cubit.selectedSortOption = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(

                        style: TextButton.styleFrom(
                          side:    BorderSide(color: mainColor),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: mainColor,
                        ),
                        onPressed: () {
                          cubit.applySort(
                            context,
                            cubit.selectedSortOption ?? '',
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.apply,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

