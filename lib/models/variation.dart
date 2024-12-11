class Variation {
  final int id;
  final String price;
  final String regularPrice;
  final String salePrice;
  final String imageUrl;
  final List<Attribute> attributes;

  Variation({
    required this.id,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.imageUrl,
    required this.attributes,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    var attributesList = json['attributes'] as List;
    List<Attribute> attributes = attributesList.map((i) => Attribute.fromJson(i)).toList();

    return Variation(
      id: json['variation_id'],
      price: json['price'],
      regularPrice: json['regular_price'],
      salePrice: json['sale_price'],
      imageUrl: json['image'],
      attributes: attributes,
    );
  }
}

class Attribute {
  final String name;
  final String slug;
  final String taxonomy;
  final String? color;

  Attribute({
    required this.name,
    required this.slug,
    required this.taxonomy,
    this.color,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      name: json['name'],
      slug: json['slug'],
      taxonomy: json['taxonomy'],
      color: json['color'],
    );
  }
}
