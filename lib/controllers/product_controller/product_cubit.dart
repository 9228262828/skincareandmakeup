import 'dart:convert';

import 'package:Gomla/controllers/product_controller/product_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bloc/bloc.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../models/brand.dart';
import '../../models/cart.dart';
import '../../models/category.dart';
import '../../models/fav.dart';
import '../../models/product.dart';
import '../../models/variation.dart';
import '../../providers/locale_provider.dart';
import '../../screens/cart_screen.dart';
import '../../screens/fav_screen.dart';
import '../../services/auth_service.dart';
import '../../services/woocommerce_service.dart';

class ProductCubit extends Cubit<ProductState> {
  final Product product;
  Variation? selectedVariation;
  int quantity = 1;
  bool isLoggedIn = false;
  bool isRelatedLoading = true;
  List<Product> relatedProducts = [];

  ProductCubit({
    required this.product,
  }) : super(ProductInitial(product: product, quantity: 1));

  void toggleFavorite(BuildContext context) {
    final fav = Provider.of<Fav>(context, listen: false);
    if (fav.isFavorite(product)) {
      fav.removeItem(product);
      emit(ProductFavoriteRemoved(product: product, quantity: quantity));

      // Show SnackBar for removing from favorites
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.removedFromFavorites,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavScreen()),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.goToWishlist,
                  style: TextStyle(fontSize: 12, color: Colors.pink),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      fav.addItem(product);
      emit(ProductFavoriteAdded(product: product, quantity: quantity));

      // Show SnackBar for adding to favorites
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.addedToFavorites,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavScreen()),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.goToWishlist,
                  style: TextStyle(fontSize: 12, color: Colors.pink),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void incrementQuantity() {
    quantity++;
    emit(ProductQuantityChanged(product: product, quantity: quantity));
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      emit(ProductQuantityChanged(product: product, quantity: quantity));
    }
  }

  void addToCart(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    cart.addItem(product, selectedVariation);
    cart.updateQuantity(product, quantity);
    emit(ProductAddedToCart(product: product, quantity: quantity));

    // Show SnackBar for adding to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.addedtoCart,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.goToCart,
                style: TextStyle(fontSize: 12, color: Colors.pink),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 4),
      ),
    );
  }
   final String baseUrl = '$siteUrl/wp-json/wc/v3';
  final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
  final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';
  Future<void> checkLoginStatus() async {
    isLoggedIn = await AuthService.isLoggedIn();
    emit(ProductIsLoggedIn(
      product: product,
      quantity: quantity,
      value: isLoggedIn,
    ));
  }
  Future<http.Response> submitReviewFetch({
    required int productId,
    required String review,
    required String userName,
    required String userEmail,
  }) async
  {
    final url = Uri.parse('$baseUrl/products/reviews');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
    };
    final body = jsonEncode({
      'product_id': productId,
      'review': review,
      'reviewer': userName,
      'reviewer_email': userEmail,
      'rating': 5,
    });

    return await http.post(url, headers: headers, body: body);
  }

  Future<void> submitReview(
      int id, BuildContext context, TextEditingController reviewController) async
  {
    try
    {
      final userInfo = await AuthService.fetchUserInfo();
      final response = await submitReviewFetch(
        productId: id,
        review: reviewController.text,
        userName: userInfo['username'],
        userEmail: userInfo['email'],
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')));
        reviewController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    }
  }



}


class ProductListingCubit extends Cubit<ProductListingState> {
  final WooCommerceService wooCommerceService;
  int page = 1;
  bool isLastPage = false;

  bool hasReachedMax = false;
  double? minPrice;
  double? maxPrice;
  int? selectedBrandId;
  int? selectedCategoryId;
  String? selectedSortOption;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 1000;

  List<Product> products = [];
  List<Category> categories = [];
  List<Category> childCategories = [];
  List<Brand> brands = [];

  ProductListingCubit(this.wooCommerceService) : super(ProductListingInitial());

  Future<void> fetchInitialData(BuildContext context, int categoryId) async {
    print('Fetching initial data');
    emit(ProductListingLoading());

    try {

      categories = await wooCommerceService.fetchCategories();
      await fetchProducts(context, categoryId);
      emit(ProductListingLoaded(
        products: products,
        categories: categories,
        childCategories: childCategories,
        brands: brands,
        minPrice: minPrice,
        maxPrice: maxPrice,
        hasReachedMax: hasReachedMax,
      ));

      // Now fetch the other data asynchronously without blocking the UI
      brands = await wooCommerceService.fetchBrands();
      childCategories =
      await wooCommerceService.fetchChildCategories(categoryId, context);

      // After fetching all the data, emit a new loaded state with all information
      emit(ProductListingLoaded(
        products: products,
        categories: categories,
        childCategories: childCategories,
        brands: brands,
        minPrice: minPrice,
        maxPrice: maxPrice,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      print('Error in fetchInitialData: $e');
      emit(ProductListingError(e.toString()));
    }
  }

  // Fetch products remains unchanged
  Future<void> fetchProducts(BuildContext context, int categoryId) async {
    if ( isLastPage) return;

    final currentState = state;
    if (currentState is ProductListingLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    try {

      List<Product> newProducts = await wooCommerceService.filterProducts(
        categoryIdFilter: selectedCategoryId ?? categoryId,
        minPrice: selectedMinPrice,
        maxPrice: selectedMaxPrice,
        brandId: selectedBrandId,
        orderBy: selectedSortOption,
        page: page,
       );

      if (newProducts.isEmpty) {
        isLastPage = true;
      } else {
        products.addAll(newProducts);
        page++;
      }

      emit(ProductListingLoaded(
        products: products,
        categories: (currentState as ProductListingLoaded).categories,
        childCategories: currentState.childCategories,
        brands: currentState.brands,
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
        hasReachedMax: currentState.hasReachedMax,
      ));
    } catch (e) {
      emit(ProductListingError(e.toString()));
    } finally {
    }
  }

  void applyFilters(BuildContext context, int categoryId) {
    print('Applying filters');
    products.clear();
    page = 1;
    isLastPage = false;
    fetchProducts(context, selectedCategoryId ?? categoryId);
  }

  void applySort(BuildContext context, String sortOption, int categoryId) {
    print('Applying sort: $sortOption');
    selectedSortOption = sortOption;
    products.clear();
    page = 1;
    isLastPage = false;
    fetchProducts(context, selectedCategoryId ?? categoryId);
  }

  void updateSelectedBrand(int? brandId) {
    print('Selected brand: $brandId');
    selectedBrandId = brandId;
  }

  void updateSelectedCategory(int? categoryId) {
    print('Selected category: $categoryId');
    selectedCategoryId = categoryId;
  }

  void updatePriceRange(double min, double max) {
    print('Updated price range: $min - $max');
    selectedMinPrice = min;
    selectedMaxPrice = max;
  }
}
