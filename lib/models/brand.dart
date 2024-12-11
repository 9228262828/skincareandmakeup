class Brand {
  final int id;
  final String name;
  final String imageUrl;

  Brand({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'] != null ? json['image']['src'] : '',
    );
  }
}
