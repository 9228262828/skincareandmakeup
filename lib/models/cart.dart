import 'package:flutter/foundation.dart';
import 'package:skincare/models/variation.dart';
import 'cart_item.dart';
import 'product.dart';

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Product product, Variation? variation) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id && (item.variation?.id == variation?.id));

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, variation: variation));
    }
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      if (item.variation != null) {
        total += int.parse(item.variation!.price) * item.quantity;
      } else {
        total += item.product.price * item.quantity;
      }
    }
    return total;
  }

  // is added to cart
  bool isAddedToCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
