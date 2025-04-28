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
    final List<ProductCategory> allCategories = [];

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final details = ProductDetails.fromCategoryJson(value);

        final hasValidAr = details.ar != null &&
            details.ar!.id != null &&
            details.ar!.name != null &&
            details.ar!.description != null &&
            details.ar!.price != null;

        final hasValidEn = details.en != null &&
            details.en!.id != null &&
            details.en!.name != null &&
            details.en!.description != null &&
            details.en!.price != null;

        final isValid = hasValidAr || hasValidEn;

        if (isValid) {
          allCategories.add(ProductCategory(
            key: key,
            details: details,
          ));
        } else {
          print("Skipping invalid category: $key -> $value");
        }
      }
    });

    if (allCategories.isEmpty) {
      throw Exception("No valid categories found in data");
    }

    // ترتيب حسب priority
    allCategories.sort((a, b) {
      final aPriority = a.details.ar?.priority ?? a.details.en?.priority ?? 'Z';
      final bPriority = b.details.ar?.priority ?? b.details.en?.priority ?? 'Z';
      return aPriority.compareTo(bPriority);
    });

    return SkinData(categories: allCategories);
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
  final dynamic image;
  final String? priority;
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
    this.priority,
    this.ar,
    this.en,
  });

  factory ProductDetails.fromCategoryJson(Map<String, dynamic> json) {
    final ar = json['ar'] is Map<String, dynamic> ? json['ar'] : null;
    final en = json['en'] is Map<String, dynamic> ? json['en'] : null;

    if (ar == null && en == null) {
      print("Warning: Both 'ar' and 'en' fields are missing or invalid in: $json");
      return ProductDetails();
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
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      salePrice: double.tryParse(json['sale_price'].toString()) ?? 0.0,
      regularPrice: double.tryParse(json['regular_price'].toString()) ?? 0.0,
      sku: json['sku'],
      image: json['image'],
      priority: json['priority'],
    );
  }

  String getImageUrl() {
    if (image is List && (image as List).isNotEmpty) {
      final firstElement = (image as List)[0];
      if (firstElement is String) {
        return firstElement;
      }
    } else if (image is String) {
      return image as String;
    }
    return "";
  }

}
