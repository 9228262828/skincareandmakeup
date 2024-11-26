import 'package:skincare/models/variation.dart';
import 'package:skincare/models/variation.dart';

import 'product.dart';

class CartItem {
  final Product product;
  final Variation? variation;
  int quantity;

  CartItem({required this.product, this.quantity = 1, this.variation});
}
