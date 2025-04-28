import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/product_screen.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/utils/app_values.dart';
import '../controllers/brands_controller/brands_cubit.dart';
import '../controllers/brands_controller/brands_states.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer_widget.dart';

class BrandProductsScreen extends StatefulWidget {
  final int id;
  final String brandName;
  final bool isLink;

  const BrandProductsScreen(
      {required this.id,
      super.key,
      required this.brandName,
      required this.isLink});

  @override
  _BrandProductsScreenState createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProductss(brandId: widget.id, isInitial: true);

    _scrollController.addListener(_onScroll);
      context.read<ProductsCubit>().resetAndFetchData(context: context);



  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ProductsCubit>().fetchProductss(brandId: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return Scaffold(
     backgroundColor:  Colors.grey.shade200,
     appBar: CustomPagesAppBar(title: widget.brandName, home: false),
     body: Padding(
       padding: const EdgeInsets.all(8.0),
       child: BlocBuilder<ProductsCubit, ProductsState>(
         builder: (context, state) {
           if (state is ProductsLoading && state.page == 1 && state is! ProductsInitial) {
             return ProductCardWithShimmerAllScreen(count: 10); // Show shimmer during loading
           } else if (state is ProductsLoaded) {
             return RefreshIndicator(
               onRefresh: () async {
                 context.read<ProductsCubit>().fetchProductss(brandId: widget.id);
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
                         childAspectRatio: 0.53,
                         crossAxisSpacing: 8.0,
                         mainAxisSpacing: 8.0,
                       ),
                       itemCount: state.hasReachedMax
                           ? state.Productss.length
                           : state.Productss.length + 1,
                       itemBuilder: (context, index) {
                         if (index < state.Productss.length) {
                           final product = state.Productss[index];
                           return GestureDetector(
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => ProductScreen(
                                     productId: product.id,
                                   ),
                                 ),
                               );
                             },
                             child: ProductCard(product: product, fakeProduct: ''),
                           );
                         } else {
                           return _buildLoadMoreShimmer();
                         }
                       },
                     ),
                   ),
                   SizedBox(
                     height: mediaQueryHeight(context) * 0.04,
                   )
                 ],
               ),
             );
           } else if (state is ProductsError) {
             return Center(child: Text(state.message));
           } else {
             return ProductCardWithShimmerAllScreen(count: 10);
           }
         },
       ),
     ),
     floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
     floatingActionButton: widget.isLink == false
         ? Padding(
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
                     onPressed: () {
                       showSortDialog(context, cubit);
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
                       _showFilterDialog(context, context.read<ProductsCubit>());
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
           ),
         ],
       ),
     )
         : SizedBox(height: 0),
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
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: mediaQueryHeight(context) * 0.02),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[50]!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: mediaQueryHeight(context) * 0.35,
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
void _showFilterDialog(BuildContext context, ProductsCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.filterProducts,
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Price Range Slider
                  RangeSlider(
                    values: RangeValues(cubit.minPrice ?? 0, cubit.maxPrice ?? 1000),
                    min: 0,
                    max: 1000,
                    activeColor:  Color(0xFF212224),
                    inactiveColor:  Color(0xFF5B5E61).withOpacity(0.5),
                    onChanged: (RangeValues values) {
                      setState(() {
                        cubit.minPrice = values.start;
                        cubit.maxPrice = values.end;
                      });
                    },
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.price}: ${cubit.minPrice?.toStringAsFixed(2)} - ${cubit.maxPrice?.toStringAsFixed(2)}',
                  ),
                  // Brand Dropdown
               /*   DropdownButton<int>(
                    hint: Text(AppLocalizations.of(context)!.selectBrand),
                    value: cubit.selectedBrandId,
                    onChanged: (int? newValue) {
                      setState(() {
                        cubit.selectedBrandId = newValue;
                      });
                    },
                    items: cubit.allBrands.map<DropdownMenuItem<int>>((Brand brand) {
                      return DropdownMenuItem<int>(
                        value: brand.id,
                        child: Text(brand.name),
                      );
                    }).toList(),
                  ),
                  // Category Dropdown
                  DropdownButton<int>(
                    value: cubit.selectedCategoryId,
                    onChanged: (int? newValue) {
                      setState(() {
                        cubit.selectedCategoryId = newValue;
                      });
                    },
                    items: cubit.mainCategories.map<DropdownMenuItem<int>>((Category category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ),*/
                  // Apply and Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          side:    BorderSide(color:Color(0xFF212224),),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF212224),
                        ),
                        onPressed: () {
                          // Apply filter
                          cubit.applyFilter(
                            cubit.minPrice,
                            cubit.maxPrice,
                            cubit.selectedBrandId,
                            cubit.selectedCategoryId,
                            context,
                          );
                          Navigator.of(context).pop(); // Close the filter dialog
                        },
                        child: Text(AppLocalizations.of(context)!.apply,
                            style: TextStyle(color: Colors.white)),
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


showSortDialog(BuildContext context, ProductsCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        color: Colors.grey.shade300,
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
                      // Default Sorting
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.defaultSorting),
                        leading: Radio<String>(
                          value: 'default',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
                          },
                        ),
                      ),
                      // Date Sorting
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByDate),
                        leading: Radio<String>(
                          value: 'date',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
                          },
                        ),
                      ),
                      // Popularity Sorting
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByPopularity),
                        leading: Radio<String>(
                          value: 'popularity',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
                          },
                        ),
                      ),
                      // Rating Sorting
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByRating),
                        leading: Radio<String>(
                          value: 'rating',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
                          },
                        ),
                      ),
                      // Price Low to High
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByPriceLowToHigh),
                        leading: Radio<String>(
                          value: 'price-asc',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
                          },
                        ),
                      ),
                      // Price High to Low
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.sortByPriceHighToLow),
                        leading: Radio<String>(
                          value: 'price-desc',
                          activeColor: Color(0xFF212224),
                          groupValue: cubit.selectedSortOption,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                cubit.applySort(value, context);
                              });
                            }
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
                          side: BorderSide(color: Color(0xFF212224)),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF212224),
                        ),
                        onPressed: () {
                          if (cubit.selectedSortOption != null) {
                            cubit.applySort(cubit.selectedSortOption!, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!.pleaseEnterYourUsername),
                            ));
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.apply),
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

