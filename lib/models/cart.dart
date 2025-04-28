import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Gomla/models/variation.dart';
import '../Engin/models.dart';
import 'cart_item.dart';
import 'product.dart';

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    saveCartToSharedPreferences();
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      saveCartToSharedPreferences(); // <-- save after updating
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    saveCartToSharedPreferences(); // <-- save after removing
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      double price = item.product.price;

      // Apply tax if shipping is taxable
      if (item.product.shipping_taxable == true) {
        price += price * 0.15; // Apply 15% tax
      }

      // Add the item total (price * quantity)
      total += price * item.quantity;
    }
    return total;
  }

  bool isAddedToCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  void clear() {
    _items.clear();
    saveCartToSharedPreferences(); // <-- save after clearing
    notifyListeners();
  }

  void addItemFromDetails(ProductDetails details) {
    final preferredDetails = details.ar ?? details.en;

    if (preferredDetails == null) {
      return;
    }

    Product product = Product(
      stock_quantity: 10,
      id: preferredDetails.id ?? 0,
      name: preferredDetails.name ?? '',
      imageUrl: preferredDetails.getImageUrl(),
      price: preferredDetails.price?.toDouble() ?? 0.0,
      sale_price: preferredDetails.salePrice?.toDouble() ?? 0.0,
      regularPrice: preferredDetails.regularPrice?.toDouble() ?? 0.0,
      description: preferredDetails.description ?? '',
      short_description: preferredDetails.description ?? '',
      images: [preferredDetails.getImageUrl()],
      categoryId: preferredDetails.id ?? 0,
      brandId: 0,
      brandImage: '',
      brandName: '',
      avrage_rating: '0.0',
      howToUse: '',
      hazardsCautions: '',
      shipping_taxable: false,
      stock_status: '',
    );

    addItem(product,  );
  }

  // 🔥 NEW: Save the cart to SharedPreferences
  Future<void> saveCartToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartJson));
  }

  // 🔥 NEW: Load the cart from SharedPreferences
  Future<void> loadCartFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      final decoded = jsonDecode(cartString) as List<dynamic>;
      _items = decoded.map((item) => CartItem.fromJson(item)).toList();
      print("decoded");
      print(decoded);
      notifyListeners();
    }
  }
}
