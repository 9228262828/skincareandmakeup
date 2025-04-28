class Brand {
  final int id;
  final String name;
  final String slug;
  final String imageUrl;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image'] != null && json['image']['src'] != null
          ? json['image']['src']
          : '',
    );
  }
}
