import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../models/brand.dart';
import '../../models/product.dart';
import '../../services/woocommerce_service.dart';
import 'brands_states.dart';



class BrandsCubit extends Cubit<BrandsState> {
  final WooCommerceService wooCommerceService;

  BrandsCubit(this.wooCommerceService) : super(BrandsInitial());

  Future<void> fetchBrands() async {
    emit(BrandsLoading());
    try {
      List<Brand> brands = await wooCommerceService.fetchBrands();
      print(brands);
      emit(BrandsLoaded(brands));
    } catch (e) {
      emit(BrandsError(e.toString()));
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
  String? selectedSortOption;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 1000;


  ProductsCubit() : super(ProductsInitial()) {
    fetchProductss( isInitial: true);
  }

  Future<void> fetchProductss( {bool isInitial = false, int? brandId}) async {
    if (isInitial) {
      page = 1;
      hasReachedMax = false;
      Productss = [];
      emit(ProductsLoading(page: page));
    }

    if (hasReachedMax) return;

    try {
      final String baseUrl = '$siteUrl/wp-json/wc/v3';
  final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
  final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';
      final prefs = await SharedPreferences.getInstance();
      String? language = prefs.getString('locale') ;
      final response = await http.get(
        Uri.parse('$baseUrl/products?brand=$brandId&page=$page&per_page=10&lang=$language'),
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      final List<dynamic> data = json.decode(response.body);
      List<Product> newProductss = data.map((json) => Product.fromJson(json)).toList();

      if (newProductss.length < count) {
        hasReachedMax = true;
      }

      Productss.addAll(newProductss);
      emit(ProductsLoaded(Productss: Productss, page: page, hasReachedMax: hasReachedMax));
      page++;
    } catch (error) {
      print(error);
      emit(ProductsError(message: error.toString()));
    }
  }


}

