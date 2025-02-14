import 'package:Gomla/shared/network/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SkinAnalysisState {}

class SkinAnalysisLoading extends SkinAnalysisState {}

class SkinAnalysisSuccess extends SkinAnalysisState {
  final SkinAnalysisResponse response;

  SkinAnalysisSuccess(this.response);
}

class SkinAnalysisError extends SkinAnalysisState {
  final String message;

  SkinAnalysisError(this.message);
}

class SkinAnalysisCubit extends Cubit<SkinAnalysisState> {
  SkinAnalysisCubit() : super(SkinAnalysisLoading());

  Future<void> fetchSkinAnalysis(Map<String, dynamic> skinAnalysisData) async {
    emit(SkinAnalysisLoading());

    // Get the token from SharedPreferences
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    String? token = await prefs.then((value) => value.getString('auth_token'));
    String? userId = await prefs.then((value) => value.getString('user_id'));

print("token");
print(token);
print(userId);
print("token");
    try {
      final response = await Dio().post(
        'https://gomla.sa/wp-json/skin-analysis/v1/skinscoretest',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "user_id": userId,
          "dryness": 90,
          "redness": 90,
          "oillness": 80,
          "acne": 75,
          "pores": 78,
          "texture": 80,
          "wrinkles": 85,
          "dark spots": 84,
          "dark circles": 84,
          "radiance": 84,
          "skinage": 60,
          "overall score": 30,
        },
      );

      // Log the raw response
      print('Response: ${response.data}');

      // Check if the response is in the expected format
      if (response.data is Map<String, dynamic>) {
        final skinAnalysis = SkinAnalysisResponse.fromJson(response.data);
        emit(SkinAnalysisSuccess(skinAnalysis));
      } else {
        // Handle unexpected response format
        emit(SkinAnalysisError("Unexpected response format"));
      }
    } catch (e, stackTrace) {
      // Print more details for debugging
      print('Error: $e');
      print('Stack trace: $stackTrace');
      emit(SkinAnalysisError("Unexpected error occurred"));
    }
  }
}


class SkinAnalysisResponse {
  final bool success;
  final SkinData data;
  final int totalCount;

  SkinAnalysisResponse({
    required this.success,
    required this.data,
    required this.totalCount,
  });

  factory SkinAnalysisResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null || json['data'] is! Map<String, dynamic>) {
      throw Exception("Invalid or missing 'data' field");
    }

    return SkinAnalysisResponse(
      success: json['success'] ?? false,
      data: SkinData.fromJson(json['data']),
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class SkinData {
  final List<ProductCategory> categories;

  SkinData({required this.categories});

  factory SkinData.fromJson(Map<String, dynamic> json) {
    final categories = json.entries
        .map((entry) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        final details = ProductDetails.fromCategoryJson(value);
        if (details.ar != null || details.en != null) {
          return ProductCategory(
            key: key,
            details: details,
          );
        }
      }
      print("Skipping invalid category: $key -> $value");
      return null; // Skip invalid categories
    })
        .where((category) => category != null)
        .cast<ProductCategory>()
        .toList();

    if (categories.isEmpty) {
      throw Exception("No valid categories found in data");
    }

    return SkinData(categories: categories);
  }
}

class ProductCategory {
  final String key;
  final ProductDetails details;

  ProductCategory({
    required this.key,
    required this.details,
  });
}

class ProductDetails {
  final int? id;
  final String? name;
  final String? description;
  final double? price;
  final double? regularPrice;
  final double? salePrice;
  final String? sku;
  final String? image;
  final ProductDetails? ar;
  final ProductDetails? en;

  ProductDetails({
    this.id,
    this.name,
    this.description,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.sku,
    this.image,
    this.ar,
    this.en,
  });

  factory ProductDetails.fromCategoryJson(Map<String, dynamic> json) {
    final ar = json['ar'] is Map<String, dynamic> ? json['ar'] : null;
    final en = json['en'] is Map<String, dynamic> ? json['en'] : null;

    if (ar == null && en == null) {
      print("Warning: Both 'ar' and 'en' fields are missing or invalid in: $json");
      return ProductDetails(); // Return a default instance
    }

    return ProductDetails(
      ar: ar != null ? _fromJson(ar) : null,
      en: en != null ? _fromJson(en) : null,
    );
  }

  static ProductDetails _fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'] ?? '0') ?? 0.0,
      regularPrice: double.tryParse(json['regular_price'] ?? '0') ?? 0.0,
      salePrice: double.tryParse(json['sale_price'] ?? '0') ?? 0.0,
      sku: json['sku'],
      image: json['image'],
    );
  }
}
