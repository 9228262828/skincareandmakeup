class Bannerr {
  final String name;
  final String image;
  final String link;
  final String width;
  final String height;
  final String language;
  final String termType;
  final String termId;
  final String? termName;
  final String featured;

  Bannerr({
    required this.name,
    required this.image,
    required this.link,
    required this.width,
    required this.height,
    required this.language,
    required this.termType,
    required this.termId,
    this.termName,
    required this.featured,
  });

  // Factory method to create a Bannerr object from JSON
  factory Bannerr.fromJson(Map<String, dynamic> json) {
    return Bannerr(
      name: json['name'],
      image: json['image'],
      link: json['link'],
      width: json['width'],
      height: json['height'],
      language: json['language'],
      termType: json['term_type'],
      termId: json['term_id'],
      termName: json['term_name'],
      featured: json['featured'],
    );
  }

  // Method to convert Bannerr object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'link': link,
      'width': width,
      'height': height,
      'language': language,
      'term_type': termType,
      'term_id': termId,
      'term_name': termName,
      'featured': featured,
    };
  }
}
