class ShippingMethodModel {
  final int id;
  final String title;
  final String methodId;
  final String cost;

  ShippingMethodModel({
    required this.id,
    required this.title,
    required this.methodId,
    required this.cost,
  });

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['id'],
      title: json['title'] ?? '',
      methodId: json['method_id'] ?? '',
      cost: json['settings']?['cost']?['value'] ?? '0.0',
    );
  }
}
