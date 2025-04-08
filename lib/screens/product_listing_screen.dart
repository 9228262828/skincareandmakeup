import 'package:Gomla/screens/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../contstants.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/fakeProduct.dart';
import '../models/product.dart';
import '../services/woocommerce_service.dart';
import '../shared/utils/app_values.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_home_widget.dart';
import '../widgets/product_shimmer_widget.dart';
import 'cart_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String? type;
  final bool isLink;

  const ProductListingScreen(
      {Key? key, required this.categoryId, required this.categoryName, required this.type, required this.isLink})
      : super(key: key);

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late WooCommerceService wooCommerceService;
  List<Product> products = [];
  List<Category> categories = [];
  List<Category> childCategories = [];
  List<Brand> brands = [];
  int page = 1;
  bool isLoading = false;
  bool isLastPage = false;

  double? minPrice;
  double? maxPrice;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 1000;
  int? selectedBrandId;
  int? selectedCategoryId;
  String? selectedSortOption;

  final List<String> sortOptions = [
    'date',
    'popularity',
    'rating',
    'price',
  ];

  @override
  void initState() {
    super.initState();
    wooCommerceService = WooCommerceService();

    fetchInitialData();
  }

  Future<void> fetchProductsType(BuildContext context, String url) async {
    print('CategoriesLoading');
    if (isLoading || isLastPage) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Product> newProducts = await wooCommerceService.fetchProductsBest(
          context, url);

      print(url);
      print(newProducts);

      setState(() {
        products = newProducts;

        if (newProducts.length < 10) {
          isLastPage = true;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchInitialData() async {
    !widget.isLink ? await fetchProducts() : await fetchProductsType(context,
        widget.type == "bestSellers"
            ? "https://gomla.sa/wp-json/wc/v3/products?orderby=popularity":
        widget.type == "nearlyArrived"
            ? "https://gomla.sa/wp-json/wc/v3/products?orderby=date&order=desc" :
        "https://gomla.sa/wp-json/wc/v3/products?orderby=popularity&order=asc"
    );
    print(widget.type);
    print("fetchInitialData");
    setState(() {
      isLoading = false;
    });

    await fetchCategories();

    await fetchBrands();
    await fetchChildCategories();
  }

  Future<void> fetchProducts() async {
    if (isLoading || isLastPage) return;
    setState(() {
      isLoading = true;
    });

    print(widget.categoryId);
    try {
      List<Product> newProducts = await wooCommerceService.filterProducts(

        minPrice: selectedMinPrice,
        maxPrice: selectedMaxPrice,
        brandId: selectedBrandId,
        categoryIdFilter: selectedCategoryId ?? widget.categoryId,
        page: (widget.categoryId == 160 || widget.categoryId == 30) ? 2 : page,
        orderBy: selectedSortOption,
      );

      setState(() {
        products.addAll(newProducts);

        if (newProducts.isNotEmpty) {
          minPrice ??= newProducts
              .map((p) => p.price ?? 0)
              .reduce((a, b) => a < b ? a : b);
          maxPrice ??= newProducts
              .map((p) => p.price ?? 0)
              .reduce((a, b) => a > b ? a : b);
          selectedMinPrice = minPrice!;
          selectedMaxPrice = maxPrice!;
        }

        if (newProducts.length < 10) {
          isLastPage = true;
        }
        page++;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      // setState(() {
      //   isLoading = true;
      // });

      List<Category> fetchedCategories =
      await wooCommerceService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print(e);
    } finally {
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  Future<void> fetchChildCategories() async {
    try {
      List<Category> fetchchildCategories = await wooCommerceService
          .fetchChildCategories(widget.categoryId, context);
      setState(() {
        childCategories = fetchchildCategories;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchBrands() async {
    try {
      List<Brand> fetchedBrands = await wooCommerceService.fetchBrands();
      setState(() {
        brands = fetchedBrands;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.filterProducts,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RangeSlider(
                            values:
                            RangeValues(selectedMinPrice, selectedMaxPrice),
                            min: minPrice ?? 0,
                            max: maxPrice ?? 1000,
                            activeColor:  Color(0xFF212224),
                            inactiveColor:  Color(0xFF5B5E61).withOpacity(0.5),
                            onChanged: (RangeValues values) {
                              setState(() {
                                selectedMinPrice = values.start;
                                selectedMaxPrice = values.end;
                              });
                            },
                          ),
                          Text(
                              '${AppLocalizations.of(context)!.price}: ${selectedMinPrice.toStringAsFixed(2)} - ${selectedMaxPrice.toStringAsFixed(2)}'),
                          DropdownButton<int>(
                            hint:
                            Text(AppLocalizations.of(context)!.selectBrand),
                            value: selectedBrandId,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedBrandId = newValue;
                              });
                            },
                            items: brands.map((Brand brand) {
                              return DropdownMenuItem<int>(
                                value: brand.id,
                                child: Text(brand.name),
                              );
                            }).toList(),
                          ),
                          DropdownButton<int>(
                            hint: Text(
                                AppLocalizations.of(context)!.selectCategory),
                            value: selectedCategoryId,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedCategoryId = newValue;
                              });
                            },
                            items: categories.map((Category category) {
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
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
                            setState(() {
                              products.clear();
                              page = 1;
                              isLastPage = false;
                              fetchProducts();
                            });
                            Navigator.of(context).pop();
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

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sortOptions.map((String option) {
                          return RadioListTile<String>(
                            activeColor:  Color(0xFF212224),
                            title: Text(_getSortOptionDisplayName(option)),
                            value: option,
                            groupValue: selectedSortOption,
                            onChanged: (String? value) {
                              setState(() {
                                selectedSortOption = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            side:    BorderSide(color:Color(0xFF212224),),
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.transparent,
                            textStyle: TextStyle(color: Colors.black),
                          ),

                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF212224),
                          ),
                          onPressed: () {
                            setState(() {
                              products.clear();
                              page = 1;
                              isLastPage = false;
                              fetchProducts();
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.apply,
                            style: TextStyle(color: Colors.white),
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

  String _getSortOptionDisplayName(String option) {
    switch (option) {
      case 'popularity':
        return AppLocalizations.of(context)!.sortByPopularity;
      case 'rating':
        return AppLocalizations.of(context)!.sortByRating;
      case 'date':
        return AppLocalizations.of(context)!.sortByDate;
      case 'price':
        return AppLocalizations.of(context)!.sortByPrice;
      default:
        return AppLocalizations.of(context)!.defaultSorting;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomPagesAppBar(
        title: AppLocalizations.of(context)!.products, home: false,),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchProducts();
          }
          return true;
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.categoryName, style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                ),
              ),
            ),
            isLoading && products.isEmpty ?
            Expanded(child: ProductCardWithShimmer(count: 10,)) : // Initial Shimmer
            Expanded(
              child: ListView(
                children: [
                  buildCategoriesList(),
                  if (products.isEmpty)
                    Center(
                        child: buildEmptyState(context,
                            AppLocalizations.of(context)!
                                .noProductsAvailable)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.45,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: isLoading && products.isNotEmpty && page > 1
                        ? products.length + 1 : products.length, // Show shimmer for load more
                    itemBuilder: (context, index) {
                      if (isLoading && index == products.length) {
                        return ShimmerCard(); // Shimmer for Load More
                      }
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
                ],
              ),
            ),
            SizedBox(height: 60,)
          ],
        ),
      ),
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
                      onPressed: _showSortDialog,
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
                      onPressed: _showFilterDialog,
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

    );
  }

  Widget buildCategoriesList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childCategories.map((category) {
            return Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: selectedCategoryId == category.id
                    ? borderColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category.id;
                      products.clear();
                      page = 1;
                      isLastPage = false;
                      fetchProducts();
                    });
                  },
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor:  Colors.grey[300],
                          backgroundImage:
                          CachedNetworkImageProvider(category.imageUrl),
                          radius: 40,
                        ),
                        Text(
                          _stripHtmlTags(category.name),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }
}
