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
  String selectedSortOption = 'default';

  List<Brand> allBrands = [];
  List<Category> mainCategories = [];
  bool hasMoreBrands = true;
  bool hasMoreCategories = true;
  int currentPageForBrands = 1;
  int currentPageForCategories = 1;

  ProductsCubit() : super(ProductsInitial()) {
    }

  Future<void> fetchProductss({
    bool isInitial = false,
    int? brandId,
    BuildContext? context,
  }) async {
    if (isInitial) {
      page = 1;
      hasReachedMax = false;
      Productss.clear();
      emit(ProductsLoading(page: page));
    }

    if (hasReachedMax) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String language = prefs.getString('locale') ?? 'ar';

      String? orderBy;
      String? order;

      switch (selectedSortOption) {
        case 'date':
          orderBy = 'date';
          break;
        case 'popularity':
          orderBy = 'popularity';
          break;
        case 'rating':
          orderBy = 'rating';
          break;
        case 'price-asc':
          orderBy = 'price';
          order = 'asc';
          break;
        case 'price-desc':
          orderBy = 'price';
          order = 'desc';
          break;
      }

      final query = _buildFilterQuery(
        minPrice: minPrice,
        maxPrice: maxPrice,
        brandId: brandId ?? selectedBrandId,
         orderBy: orderBy,
        order: order,
        language: language,
        page: page,
      );
      final String baseUrl = '$siteUrl/wp-json/wc/v3';
      final String consumerKey = 'ck_d0150d53b03646e0d5695e37739777049dda22aa';
      final String consumerSecret = 'cs_bdb53e06ca06f8fcdb6510efbbbfaca708bbb3c7';
      final url = Uri.parse('$baseUrl/products?$query');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<Product> newProductss = jsonResponse.map((p) => Product.fromJson(p)).toList();

        if (newProductss.length < count) {
          hasReachedMax = true;
        }

        Productss.addAll(newProductss);
        emit(ProductsLoaded(Productss: Productss, page: page, hasReachedMax: hasReachedMax));
        page++;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print("Error fetching products: $error");
      emit(ProductsError(message: error.toString()));
    }
  }

  String _buildFilterQuery({
    double? minPrice,
    double? maxPrice,
    int? brandId,
    String? orderBy,
    String? order,
    required String language,
    required int page,
  }) {
    final List<String> queryParams = [];

    if (minPrice != null) queryParams.add('min_price=$minPrice');
    if (maxPrice != null) queryParams.add('max_price=$maxPrice');
    if (brandId != null) queryParams.add('brand=$brandId');
    if (orderBy != null) queryParams.add('orderby=$orderBy');
    if (order != null) queryParams.add('order=$order');
    queryParams.add('lang=$language');
    queryParams.add('page=$page');

    return queryParams.join('&');
  }

  void applySort(String sortOption, BuildContext context) {
    selectedSortOption = sortOption;
    page = 1;
    hasReachedMax = false;
    Productss.clear();
    fetchProductss(isInitial: true, context: context);
  }

  void applyFilter(
      double? minPrice,
      double? maxPrice,
      int? brandId,
      BuildContext context,
      ) {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.selectedBrandId = brandId;

    page = 1;
    hasReachedMax = false;
    Productss.clear();

    fetchProductss(isInitial: true, context: context);
  }


  void filterProductsByBrand(int brandId, BuildContext context) {
    selectedBrandId = brandId;
    page = 1;
    hasReachedMax = false;
    Productss.clear();
    emit(ProductsLoading(page: page));
    fetchProductss(isInitial: true, brandId: brandId, context: context);
  }

  Future resetAndFetchData({
    bool isInitial = true,
    BuildContext? context,
  }) async {
    page = 1;
    hasReachedMax = false;
    Productss.clear();
    allBrands.clear();
    mainCategories.clear();

    emit(ProductsLoading(page: page));
    emit(BrandsFilterLoading());
    emit(CategoriesLoading());

    fetchProductss(isInitial: isInitial, context: context);
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
  ProductsLoaded({required this.Productss, required this.page, required this.hasReachedMax});
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError({required this.message});
}

class BrandsFilterLoading extends ProductsState {}

class BrandsFuilterLoaded extends ProductsState {
  final List<Brand> brands;
  BrandsFuilterLoaded(this.brands);
}

class BrandsFilterError extends ProductsState {
  final String message;
  BrandsFilterError(this.message);
}

class CategoriesLoading extends ProductsState {}

class CategoriesLoaded extends ProductsState {
  final List<Category> categories;
  CategoriesLoaded(this.categories);
}

class CategoriesError extends ProductsState {
  final String message;
  CategoriesError(this.message);
}

