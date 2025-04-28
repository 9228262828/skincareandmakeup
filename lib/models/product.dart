class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final double sale_price;
  final double regularPrice;
  final String description;
  final String avrage_rating;
  final String short_description;
  final List<String> images;
  final int categoryId;
  final int brandId;
  final int stock_quantity;
  final String howToUse;
  final String brandImage;
  final String brandName;
  final String stock_status;
  final bool shipping_taxable;
  final String hazardsCautions;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.sale_price,
    required this.regularPrice,
    required this.description,
    required this.short_description,
    required this.images,
    required this.categoryId,
    required this.brandId,
    required this.brandImage,
    required this.brandName,
    required this.avrage_rating,
    required this.howToUse,
    required this.hazardsCautions,
    required this.shipping_taxable,
    required this.stock_quantity,
    required this.stock_status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String getMetaDataValue(String key) {
      var metaData = json['meta_data'] ?? [];
      var metaItem = metaData.firstWhere(
            (item) => item['key'] == key,
        orElse: () => {'value': ''},
      );
      return metaItem['value'] ?? '';
    }

    List<String> imagesList = [];

    if (json['images'] != null) {
      if (json['images'].isNotEmpty && json['images'][0] is Map) {
        // ✅ Loading from API
        imagesList = List<String>.from(json['images'].map((image) => image['src'] ?? ''));
      } else if (json['images'].isNotEmpty && json['images'][0] is String) {
        // ✅ Loading from SharedPreferences
        imagesList = List<String>.from(json['images']);
      }
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: imagesList.isNotEmpty ? imagesList[0] : '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      sale_price: double.tryParse(json['sale_price'].toString()) ?? 0.0,
      regularPrice: double.tryParse(json['regular_price'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      short_description: json['short_description'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'].map((image) => image['src'] ?? '')) // Ensure safe handling of null 'src'
          : [],
      categoryId: json['categories'] != null && json['categories'].isNotEmpty
          ? json['categories'][0]['id']
          : 0,
      brandId: json['brands'] != null && json['brands'].isNotEmpty
          ? json['brands'][0]['id']
          : 0,
      avrage_rating: json['average_rating']?.toString() ?? '0.0',
      howToUse: getMetaDataValue('how_to_use'),
      hazardsCautions: getMetaDataValue('hazards_cautions'),
      shipping_taxable: json['shipping_taxable'] ?? json['shipping_taxable'] ?? true.hashCode,
      stock_status: json['stock_status'] ?? json['stock_status'] ?? "",
        brandImage: json['brand_image'] ?? '', brandName: json['brand_name'] ?? '',
        stock_quantity: json['stock_quantity'] ?? 0
    );

}

  // 🔥 toJson added
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'sale_price': sale_price,
      'regularPrice': regularPrice,
      'description': description,
      'short_description': short_description,
      'images': images,
      'categoryId': categoryId,
      'brandId': brandId,
      'brandImage': brandImage,
      'brandName': brandName,
      'avrage_rating': avrage_rating,
      'howToUse': howToUse,
      'hazardsCautions': hazardsCautions,
      'shipping_taxable': shipping_taxable,
      'stock_quantity': stock_quantity,
      'stock_status': stock_status,
    };
  }
}
