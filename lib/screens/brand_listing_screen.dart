import 'package:flutter/material.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import 'package:provider/provider.dart';
import '../services/woocommerce_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandListingScreen extends StatefulWidget {
  final int brandId;
  final String brandName;

  const BrandListingScreen(
      {Key? key, required this.brandId, required this.brandName})
      : super(key: key);

  @override
  _BrandListingScreenState createState() => _BrandListingScreenState();
}

class _BrandListingScreenState extends State<BrandListingScreen> {
  late WooCommerceService wooCommerceService;
  List<Product> products = [];
  List<Category> categories = [];
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

  Future<void> fetchInitialData() async {
    await fetchCategories();
    await fetchBrands();
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    if (isLoading || isLastPage) return;
    setState(() {
      isLoading = true;
    });

    try {
      List<Product> newProducts = await wooCommerceService.filterProducts(
        context: context,
        minPrice: selectedMinPrice,
        maxPrice: selectedMaxPrice,
        brandId: selectedBrandId ?? widget.brandId,
        categoryIdFilter: selectedCategoryId,
        page: page,
        orderBy: selectedSortOption,
      );

      setState(() {
        products.addAll(newProducts);

        if (newProducts.isNotEmpty) {
          // Initialize the selected min and max prices
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
      List<Category> fetchedCategories =
          await wooCommerceService.fetchCategories(context);
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchBrands() async {
    try {
      List<Brand> fetchedBrands = await wooCommerceService.fetchBrands(context);
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
                            backgroundColor: Colors.red,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            textStyle: TextStyle(color: Colors.white),
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
                            backgroundColor: Colors.red,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            textStyle: TextStyle(color: Colors.white),
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
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.products),
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
                  child: Text(widget.brandName),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  if (isLoading && products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FadeInOutImage(
                          height: MediaQuery.of(context).size.height * 0.3),
                    );
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
                    child: ProductCard(product: products[index]),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _showSortDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sort, color: Colors.black),
                        Text(AppLocalizations.of(context)!.sort,
                            style: TextStyle(color: Colors.black)),
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
                        Icon(Icons.filter_list, color: Colors.black),
                        Text(AppLocalizations.of(context)!.filter,
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
