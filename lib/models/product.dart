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
  final String howToUse;
  final String stock_status;
  final bool shipping_taxable;
  final String hazardsCautions;

  Product( {
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
    required this.avrage_rating,
    required this.howToUse,
    required this.hazardsCautions,
    required this.shipping_taxable,
      required this.stock_status
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

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['src'] // Make sure 'src' exists
          : '',
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
    );
  }
}
