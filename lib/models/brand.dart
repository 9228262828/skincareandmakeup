class Brand {
  int id;
  String name;
  String imageUrl;

  Brand({required this.id, required this.name, required this.imageUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
     final id = json['id'];
    final int parsedId = id is String ? int.tryParse(id) ?? 0 : id ?? 0;

    return Brand(
      id: parsedId,
      name: json['name'] ?? '',
      imageUrl: json['image']?['src']?? '',
    );
  }
}
