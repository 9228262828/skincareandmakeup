import 'package:Gomla/models/shipping_method_model.dart';

class ShippingZoneModel {
  final int id;
  final String name;
  final List<ShippingMethodModel> methods;

  ShippingZoneModel({
    required this.id,
    required this.name,
    required this.methods,
  });

  factory ShippingZoneModel.fromJson(Map<String, dynamic> json) {
    return ShippingZoneModel(
      id: json['id'],
      name: json['name'],
      methods: [], // Methods will be loaded separately
    );
  }

  ShippingZoneModel copyWith({List<ShippingMethodModel>? methods}) {
    return ShippingZoneModel(
      id: id,
      name: name,
      methods: methods ?? this.methods,
    );
  }
}
