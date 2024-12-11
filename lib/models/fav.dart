import 'package:flutter/material.dart';
import 'product.dart';

class Fav with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  void addItem(Product product) {
    if (!_items.contains(product)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    if (_items.contains(product)) {
      _items.remove(product);
      notifyListeners();
    }
  }

  bool isFavorite(Product product) {
    return _items.contains(product);
  }
}
