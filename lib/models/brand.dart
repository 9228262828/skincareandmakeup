class Brand {
  int id;
  String name;
  String imageUrl;

  Brand({required this.id, required this.name, required this.imageUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
    // Ensure the `id` is an integer, even if it comes as a String
    final id = json['id'];
    final int parsedId = id is String ? int.tryParse(id) ?? 0 : id ?? 0;

    return Brand(
      id: parsedId,
      name: json['name'] ?? '',
      imageUrl: json['brand_image']?['sizes']?['full']?['url'] ?? '',
    );
  }
}
