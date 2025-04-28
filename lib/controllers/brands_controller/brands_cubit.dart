import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/woocommerce_service.dart';
import 'brands_states.dart';



class BrandsCubit extends Cubit<BrandsState> {
  final WooCommerceService wooCommerceService;
  int currentPage = 1; // Track the current page
  bool hasMore = true; // Flag to track if more data is available
  List<Brand> allBrands = []; // Store all brands fetched

  BrandsCubit(this.wooCommerceService) : super(BrandsInitial());

  Future<void> fetchBrands() async {
    if (isClosed || !hasMore) return; // Avoid emitting states if the Bloc is closed or no more brands

    emit(BrandsLoading()); // Show loading state
    try {
      List<Brand> brands = await wooCommerceService.fetchBrands(page: currentPage);

      if (brands.isNotEmpty) {
        allBrands.addAll(brands); // Append new brands
        currentPage++; // Increment the page for the next fetch
      }

      // If the number of fetched brands is less than perPage, there's no more data
      hasMore = brands.length == 21; // Update the flag based on the response length

      emit(BrandsLoaded(allBrands)); // Emit the loaded brands
    } catch (e) {
      emit(BrandsError(e.toString())); // Handle errors
    }
  }
}

// brands_state.dart

abstract class BrandsState {}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<Brand> brands;

  BrandsLoaded(this.brands);
}

class BrandsError extends BrandsState {
  final String error;

  BrandsError(this.error);
}


class ProductsCubit extends Cubit<ProductsState> {
  int page = 1;
  final int count = 10;
  bool hasReachedMax = false;
  List<Product> Productss = [];
  double? minPrice;
  double? maxPrice;
  int? selectedBrandId;
  int? selectedCategoryId;
  String selectedSortOption = 'default';  // Default sorting option

  List<Brand> allBrands = [];  // List to store fetched brands
  List<Category> mainCategories = [];  // List to store fetched categories
  bool hasMoreBrands = true;  // To check if more brands are available
  bool hasMoreCategories = true;  // To check if more categories are available
  int currentPageForBrands = 1;  // Pagination for brands
  int currentPageForCategories = 1;  // Pagination for categories

  ProductsCubit() : super(ProductsInitial()) {
    fetchProductss(isInitial: true); // Initial load with no filters
    fetchBrands();  // Fetch brands on initialization
    fetchMainCategories();  // Fetch categories on initialization
  }

  // Method to fetch products based on filters
  Future<void> fetchProductss({
    bool isInitial = false,
    int? brandId,
    BuildContext? context,
  }) async {
    if (isInitial) {
      page = 1;
      hasReachedMax = false;
      Productss = [];
      emit(ProductsLoading(page: page));
    }

    if (hasReachedMax) return;

    try {
      WooCommerceService wooCommerceService = WooCommerceService();

      String? orderByValue;
      // Mapping sorting option to a valid API parameter
      switch (selectedSortOption) {
        case 'date':
          orderByValue = 'date'; // Order by date
          break;
        case 'popularity':
          orderByValue = 'popularity'; // Order by popularity
          break;
        case 'rating':
          orderByValue = 'rating'; // Order by rating
          break;
        case 'price-asc':
          orderByValue = 'price&order=asc'; // Price ascending
          break;
        case 'price-desc':
          orderByValue = 'price&order=desc'; // Price descending
          break;
        default:
          orderByValue = null; // Default sorting
          break;
      }

      final newProductss = await wooCommerceService.filterProducts(
        minPrice: minPrice,
        maxPrice: maxPrice,
        brandId: brandId,
        categoryIdFilter: selectedCategoryId,
        page: page,
        orderBy: orderByValue,  // Correctly passed sorting option
      );

      if (newProductss.length < count) {
        hasReachedMax = true;
      }

      Productss.addAll(newProductss);
      emit(ProductsLoaded(Productss: Productss, page: page, hasReachedMax: hasReachedMax));
      page++;
    } catch (error) {
      print("Error fetching products: $error");
      emit(ProductsError(message: error.toString()));
    }
  }


  // Method to fetch brands
  Future<void> fetchBrands() async {
    if (!hasMoreBrands) return;

    emit(BrandsFilterLoading());
    try {
      WooCommerceService wooCommerceService = WooCommerceService();
      List<Brand> brands = await wooCommerceService.fetchBrands(page: currentPageForBrands);

      if (brands.isNotEmpty) {
        allBrands.addAll(brands);  // Add new brands to the list
        currentPageForBrands++;  // Increment the page for the next fetch
      }

      hasMoreBrands = brands.length == 21;  // Check if more brands are available (pagination check)
      emit(BrandsFuilterLoaded(allBrands));  // Emit the loaded brands
    } catch (e) {
      emit(BrandsFilterError(e.toString()));  // Handle error while fetching brands
    }
  }

  // Method to fetch categories
  Future<void> fetchMainCategories() async {
    if (!hasMoreCategories) return;

    emit(CategoriesLoading());
    try {
      WooCommerceService wooCommerceService = WooCommerceService();
      List<Category> categories = await wooCommerceService.fetchCategories(page: currentPageForCategories);

      if (categories.isNotEmpty) {
        mainCategories.addAll(categories);  // Add new categories to the list
        currentPageForCategories++;  // Increment the page for the next fetch
      }

      hasMoreCategories = categories.length == 21;  // Check if more categories are available
      emit(CategoriesLoaded(mainCategories));  // Emit the loaded categories
    } catch (e) {
      emit(CategoriesError(e.toString()));  // Handle error while fetching categories
    }
  }

  // Method to apply sorting
  void applySort(String sortOption, BuildContext context) {
    selectedSortOption = sortOption;  // Update the selected sort option
    page = 1;
    hasReachedMax = false;
    Productss = [];
    fetchProductss(isInitial: true, context: context);  // Re-fetch products with the new sort option
  }

  // Method to apply filters (including minPrice, maxPrice, brand, and category)
  void applyFilter(double? minPrice, double? maxPrice, int? brandId, int? categoryId, BuildContext context) {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.selectedBrandId = brandId;
    this.selectedCategoryId = categoryId;

    page = 1;
    hasReachedMax = false;
    Productss = [];
    fetchProductss(isInitial: true, context: context); // Fetch filtered products
  }

  Future<void> resetAndFetchData({
    bool isInitial = true,
    BuildContext? context,
  }) async {
    // Reset all states
    page = 1;
    hasReachedMax = false;
    Productss.clear();  // Clear the current products
    allBrands.clear();  // Clear the current brands list
    mainCategories.clear();  // Clear the current categories list

    // Emit loading states to indicate that the data is being refetched
    emit(ProductsLoading(page: page));  // Loading for products
    emit(BrandsFilterLoading());  // Loading for brands
    emit(CategoriesLoading());  // Loading for categories

    // Fetch the data again
    fetchProductss(isInitial: isInitial, context: context);
    fetchBrands();
    fetchMainCategories();
  }
}



abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {
  final int page;
  ProductsLoading({required this.page});
}

class ProductsLoaded extends ProductsState {
  final List<Product> Productss;
  final int page;
  final bool hasReachedMax;

  ProductsLoaded({
    required this.Productss,
    required this.page,
    required this.hasReachedMax,
  });
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError({required this.message});
}

// States for Brands
class BrandsFilterLoading extends ProductsState {}

class BrandsFuilterLoaded extends ProductsState {
  final List<Brand> brands;

  BrandsFuilterLoaded(this.brands);
}

class BrandsFilterError extends ProductsState {
  final String message;

  BrandsFilterError(this.message);
}

// States for Categories
class CategoriesLoading extends ProductsState {}

class CategoriesLoaded extends ProductsState {
  final List<Category> categories;

  CategoriesLoaded(this.categories);
}

class CategoriesError extends ProductsState {
  final String message;

  CategoriesError(this.message);
}

