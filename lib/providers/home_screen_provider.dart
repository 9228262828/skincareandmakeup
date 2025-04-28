import 'package:flutter/material.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/woocommerce_service.dart';


class HomeScreenProvider with ChangeNotifier {
  final WooCommerceService wooCommerceService = WooCommerceService();

  List<Category> homeCategories = [];
  List<Category> categories = [];

   bool categoriesLoading = true;
  bool brandsLoading = true;


  Future<void> fetchInitialData(BuildContext context) async {
    await Future.delayed(Duration.zero, () async {
      // Fetch categories and best deals first

      if (categories.isEmpty) {
        categoriesLoading = true;
        notifyListeners();
        categories = await wooCommerceService.fetchCategories();
        categoriesLoading = false;
        notifyListeners();
      }



    });
  }

  Future<void> refreshData(BuildContext context) async {


    // Re-fetch the data
    await fetchInitialData(context);
  }
}
