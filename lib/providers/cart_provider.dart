
import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  List<String> _items = [];
  int get itemCount => _items.length;

  void addItem(String product, int selectedVariation) {
    _items.add(product);
    notifyListeners(); // Notify listeners when the cart is updated
  }

  void updateQuantity(String product, int quantity) {
    // Update the quantity logic
    notifyListeners();
  }
}