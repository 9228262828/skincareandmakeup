class Review {
  final int id;
  final String dateCreated;
  final String dateCreatedGmt;
  final int productId;
  final String productName;
  final String productPermalink;
  final String status;
  final String reviewer;
  final String reviewerEmail;
  final String review;
  final int rating;
  final bool verified;
  final ReviewerAvatarUrls reviewerAvatarUrls;

  Review({
    required this.id,
    required this.dateCreated,
    required this.dateCreatedGmt,
    required this.productId,
    required this.productName,
    required this.productPermalink,
    required this.status,
    required this.reviewer,
    required this.reviewerEmail,
    required this.review,
    required this.rating,
    required this.verified,
    required this.reviewerAvatarUrls,

  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      dateCreated: json['date_created'],
      dateCreatedGmt: json['date_created_gmt'],
      productId: json['product_id'],
      productName: json['product_name'],
      productPermalink: json['product_permalink'],
      status: json['status'],
      reviewer: json['reviewer'] ?? 'Anonymous',
      reviewerEmail: json['reviewer_email'] ?? '',
      review: json['review']  ?? '',
      rating: json['rating']  ?? 0,
      verified: json['verified']  ?? false,
      reviewerAvatarUrls: ReviewerAvatarUrls.fromJson(json['reviewer_avatar_urls']),
    );
  }
}

class ReviewerAvatarUrls {
  final String avatar24;
  final String avatar48;
  final String avatar96;

  ReviewerAvatarUrls({
    required this.avatar24,
    required this.avatar48,
    required this.avatar96,
  });

  factory ReviewerAvatarUrls.fromJson(Map<String, dynamic> json) {
    return ReviewerAvatarUrls(
      avatar24: json['24'] ?? '',
      avatar48: json['48'] ?? '',
      avatar96: json['96']    ?? '',
    );
  }
}



