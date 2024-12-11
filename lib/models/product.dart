class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final double sale_price;
  final double regularPrice;
  final String description;
  final String short_description;
  final List<String> images;
  // final List<String> brands;
  // final List<int> brandsIds;
  final int categoryId;
  // final int brandId;

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
    // required this.brands,
    // required this.brandsIds,
    required this.categoryId,
    // required this.brandId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // double price = json['price'] != null ? parseDouble(json['price']) : 0.0;
    // double regularPrice = json['regular_price'] != null ? parseDouble(json['regular_price']) : 0.0;
    return Product(
      id: json['id'],
      name: json['name'],
      // check if json['images'][0] is not null
      imageUrl: (json['images'].length > 0) ? json['images'][0]['src'] : 'https://placeholder.com/150',
      price: double.tryParse(json['price']) ?? 0.0,
      sale_price: double.tryParse(json['sale_price']) ?? 0.0,
      regularPrice: double.tryParse(json['regular_price']) ?? 0.0,
      description: json['description'],
      short_description: json['short_description'],
      // brands: List<String>.from(json['brands'].map((brand) => brand['name'])),
      // brandsIds: List<int>.from(json['brands'].map((brand) => brand['id'])),
      images: List<String>.from(json['images'].map((image) => image['src'])),
      categoryId: json['categories'][0]['id'],
      // brandId: (json['brands'].length > 0) ? json['brands'][0]['id'] : 0,
    );
  }

  static double parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }
}
