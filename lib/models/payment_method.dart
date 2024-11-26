class PaymentMethod {
  final String id;
  final String title;
  final bool enabled;

  PaymentMethod({
    required this.id,
    required this.title,
    required this.enabled,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      title: json['title'],
      enabled: json['enabled'],
    );
  }
}
