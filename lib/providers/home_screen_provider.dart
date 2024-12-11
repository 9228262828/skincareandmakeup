import 'package:flutter/material.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/woocommerce_service.dart';


class HomeScreenProvider with ChangeNotifier {
  final WooCommerceService wooCommerceService = WooCommerceService();

  List<Category> homeCategories = [];
  List<Category> categories = [];
  List<Brand> brands = [];
  List<Product> pets = [];
  List<Product> fitness = [];
  List<Product> health = [];

  bool homeCategoriesLoading = true;
  bool categoriesLoading = true;
  bool brandsLoading = true;
  bool petsLoading = true;
  bool fitnessLoading = true;
  bool healthLoading = true;

  Future<void> fetchInitialData(BuildContext context) async {
    await Future.delayed(Duration.zero, () async {
      // Fetch categories and best deals first
      if (categories.isEmpty) {
        homeCategoriesLoading = true;
        notifyListeners();
        homeCategories = await wooCommerceService.fetchCategories(context);
        homeCategoriesLoading = false;
        notifyListeners();
      }
      if (categories.isEmpty) {
        categoriesLoading = true;
        notifyListeners();
        categories = await wooCommerceService.fetchCategories(context);
        categoriesLoading = false;
        notifyListeners();
      }

      if (pets.isEmpty) {
        petsLoading = true;
        notifyListeners();
        pets = await wooCommerceService.fetchProducts(53, 1, context);
        petsLoading = false;
        notifyListeners();
      }

      // Fetch the rest of the data
      // if (skinCare.isEmpty) {
      //   skinCareLoading = true;
      //   notifyListeners();
      //   skinCare = await wooCommerceService.fetchProducts(153, 1, context);
      //   skinCareLoading = false;
      //   notifyListeners();
      // }

      // if (hairCare.isEmpty) {
      //   hairCareLoading = true;
      //   notifyListeners();
      //   hairCare = await wooCommerceService.fetchProducts(114, 1, context);
      //   hairCareLoading = false;
      //   notifyListeners();
      // }

      // if (makeupCat.isEmpty) {
      //   makeupCatLoading = true;
      //   notifyListeners();
      //   makeupCat = await wooCommerceService.fetchProducts(160, 2, context);
      //   makeupCatLoading = false;
      //   notifyListeners();
      // }

      if (brands.isEmpty) {
        brandsLoading = true;
        notifyListeners();
        brands = await wooCommerceService.fetchBrands(context);
        brandsLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> refreshData(BuildContext context) async {
    // Clear the current data
    categories = [];
    brands = [];
    pets = [];
    fitness = [];
    health = [];

    // Re-fetch the data
    await fetchInitialData(context);
  }
}
