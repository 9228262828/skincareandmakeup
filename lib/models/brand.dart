class Brand {
  int id;
  String name;
  String imageUrl;

  Brand({required this.id, required this.name, required this.imageUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['brand_image'] ?? '',
    );
  }
}
