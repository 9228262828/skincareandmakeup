import 'dart:convert';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../env.dart';
import '../models/brand.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/shipping_method_model.dart';
import '../models/shppong_zone_model.dart';
import 'auth_service.dart';

class WooCommerceService {
  final String baseUrl = '$siteUrl/wp-json/wc/v3';
  final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
  final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';

  Future<List<Product>> fetchProducts(
      int categoryId, int page, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    if (language == null) {
      language = 'ar';
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/products?category=$categoryId&page=$page&lang=$language'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    print(
        '$baseUrl/products?category=$categoryId&page=$page&lang=$language&consumer_key=$consumerKey&consumer_secret=$consumerSecret');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print("jsonResponse");
      print(jsonResponse);
      print("jsonResponse");
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> fetchProductsBest(
      BuildContext context, String url) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar'; // Default to 'ar' if no language is set
    final response = await http.get(
      Uri.parse(url + "&lang=$language"),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );
    print(url + "&lang=$language");

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (jsonResponse.isEmpty) {
        print("No products found for lang=$language");
        return []; // Return an empty list if no products found
      }
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> filterProducts({
    double? minPrice,
    double? maxPrice,
    int? brandId,
    int? categoryIdFilter,
    int page = 1,
    String? orderBy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';

    // Build the URL dynamically by including parameters if they are not null
    final url = Uri.parse(
        '$baseUrl/products?page=$page&per_page=10'
            '${minPrice != null ? '&min_price=$minPrice' : ''}'
            '${maxPrice != null ? '&max_price=$maxPrice' : ''}'
            '${brandId != null ? '&brand=$brandId' : ''}'
            '${categoryIdFilter != null ? '&category=$categoryIdFilter' : ''}'
            '${orderBy != null ? '&orderby=$orderBy' : ''}'  // Append orderBy only if it's not null
            '&lang=$language'
    );

    print("Request URL: $url"); // Debugging: print the full URL

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        final errorResponse = json.decode(response.body);
        print("Error Response: ${errorResponse['message']}");
        throw Exception('Failed to load filtered products');
      }
    } catch (error) {
      print("Error fetching filtered products: $error");
      throw Exception('Failed to load filtered products');
    }
  }


  Future<Product> fetchProduct(int productId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId?lang=$language'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );
    print(productId);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  Future<List<Product>> fetchProductsByBrand(
      int brandId, int page, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse('$baseUrl/products?brand=$brandId&page=$page&lang=$language'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Category>> fetchCategories({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/products/categories?lang=$language&per_page=18&page=$page&parent=0'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    print(
        '$baseUrl/products/categories?lang=$language&per_page=20&page=$page&consumer_key=$consumerKey&consumer_secret=$consumerSecret');

    if (response.statusCode == 200) {
      print(response.body);
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Category>> fetchSubCategories(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse(
          '$baseUrl/products/categories?lang=$language&per_page=100&parent=$categoryId'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    print(
        '$baseUrl/products/categories?lang=$language&hide_empty=true&parent=$categoryId&consumer_key=$consumerKey&consumer_secret=$consumerSecret');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print("Parsed Categories: $jsonResponse");
      return jsonResponse
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Future<List<Product>> fetchFrequentlyBoughtTogether(int productId) async {
  //   final response = await http.get(
  //     Uri.parse('$siteUrl/wp-json/wc/v3/frequently-bought-together/$productId'),
  //   );

  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);

  //     // If the list is empty, return an empty list
  //     if (jsonResponse.isEmpty) {
  //       return [];
  //     }

  //     // Otherwise, map the JSON response to a list of Product objects
  //     return jsonResponse.map((product) => Product.fromJson(product)).toList();
  //   } else {
  //     throw Exception('Failed to load frequently bought together items');
  //   }
  // }

  Future<List<Product>> fetchFrequentlyBoughtTogether(int productId) async {
    final response = await http.get(
      Uri.parse('$siteUrl/wp-json/wc/v3/frequently-bought-together/$productId'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      // If the response is a Map (not a List), return an empty list
      if (jsonResponse is Map<String, dynamic>) {
        print("Expected a list but received a map: $jsonResponse");
        return [];
      }

      // Otherwise, map the JSON response to a list of Product objects
      if (jsonResponse is List) {
        return jsonResponse
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception('Failed to load frequently bought together items');
    }
  }

  Future<List<Category>> fetchHomeCategories(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse('$siteUrl/wp-json/custom/v1/mobile-home-product-categories'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // fetch child categories
  Future<List<Category>> fetchChildCategories(
      int parentId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse(
          '$baseUrl/products/categories?lang=$language&hide_empty=true&parent=$parentId'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Brand>> fetchBrands({int page = 1, int perPage = 21}) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale') ?? 'ar';

    try {
      final response = await http.get(
        Uri.parse(
            'https://gomla.sa/wp-json/wc/v3/products/brands?lang=$language&page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Ensure that decodedData is a list
        if (decodedData is List) {
          return decodedData.map((brand) {
            return Brand.fromJson(brand); // Parse each brand correctly
          }).toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception(
            'Failed to load brands, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching brands: $e");
      return [];
    }
  }

  Future<List<PaymentMethod>> fetchPaymentMethods(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse('$baseUrl/payment_gateways?lang=${language}'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((method) => PaymentMethod.fromJson(method))
          .toList();
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<http.Response> submitReview({
    required int productId,
    required String review,
    required String userName,
    required String userEmail,
    required int rating, // Change to integer
  }) async {
    String _tokenKey = 'auth_token';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    final url = Uri.parse('$baseUrl/products/reviews');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      "gomlaauth": 'Bearer $token',
    };
    final body = jsonEncode({
      'product_id': productId,
      'review': review,
      'reviewer': userName,
      'reviewer_email': userEmail,
      'rating': rating, // Ensure this is an integer
    });

    print(body);
    return await http.post(url, headers: headers, body: body);
  }

  // fetchRelatedProducts
  Future<List<Product>> fetchRelatedProducts(
      int productId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/related?lang=$language'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
      },
    );
    print(
        '$baseUrl/products/$productId/related?lang=$language&consumer_key=$consumerKey&consumer_secret=$consumerSecret');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load related products');
    }
  }


  Future<Map<String, String>> createOrder({
    required String firstName,
    required String lastName,
    required String country,
    required String address,
    required String city,
    required String total,
    required double totalPrice,
    required String state,
    required String phone,
    required String email,
    required String status,
    required String orderNotes,
    required String shippingCost,
    required String paymentMethod,
    required List<CartItem> cartItems,
    required BuildContext context,
    required bool setPaid,
    required int userId,
    String couponCode = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    String? token = prefs.getString('auth_token');
    language ??= 'ar';

    final url = Uri.parse('$baseUrl/orders?lang=$language');

    // Encoding the consumer key and secret for Basic Authentication
    String auth = 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': auth,
      'gomlaauth': "Bearer $token",
    };

    final body = jsonEncode({
      'payment_method': paymentMethod,
      'payment_method_title': paymentMethod == 'cod' ? 'Cash on Delivery' : 'Credit Card',
      'set_paid': setPaid,
      'status': status,
      'customer_id': userId,
      'total': totalPrice,
      'billing': {
        'first_name': firstName,
        'last_name': lastName,
        'address_1': address,
        'address_2': address,
        'city': city,
        'state': state,
        'postcode': '',
        'country': country,
        'email': email,
        'phone': phone,
      },
      'shipping': {
        'first_name': firstName,
        'last_name': lastName,
        'address_1': address,
        'address_2': address,
        'city': city,
        'state': state,
        'postcode': '',
        'country': country,
      },
      'line_items': cartItems.map((item) {
        return {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'total': total,
        };
      }).toList(),
      'shipping_lines': [
        {
          'method_id': 'shipping_fee',
          'method_title': 'Shipping Fee',
          'total': shippingCost,
        },
      ],
      'customer_note': orderNotes,
      'meta_data': [
        {
          'key': '_order_number',
          'value': '$firstName-${DateTime.now().millisecondsSinceEpoch}'
        }
      ]
    });

    // Send the request to create the order
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      // Order created successfully
      final responseBody = jsonDecode(response.body);
      String message = responseBody['message'] ?? 'Order created successfully';

      // Extract orderId and orderKey from the response
      String orderId = responseBody['id'].toString();
      String orderKey = responseBody['order_key'].toString();

      // Return orderId and orderKey as a Map
      return {
        'orderId': orderId,
        'orderKey': orderKey,
      };
    } else {
      // Order creation failed
      String responseBody = utf8.decode(response.bodyBytes);
      final errorResponse = jsonDecode(responseBody);
      String message = errorResponse['message'] ?? 'Failed to create order';

      // Show error toast message
      showToast(text: message, state: ToastStates.ERROR);

      print('Failed to create order: ${response.statusCode} - $message');

      // Return empty map in case of failure
      return {};
    }
  }


  Future<void> updateOrderStatusToPaid() async {
   }

  Future<List<Product>> searchProducts(
      String query, int page, BuildContext context) async
  {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final url = Uri.parse(
        'https://gomla.sa/wp-json/wc/v3/products?search=$query&lang=$language&page=1&per_page=20',


    );
    final response = await http.get(url,
    headers:    {
      'Authorization': 'Basic ' +
          base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
    }
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      final errorResponse = json.decode(response.body);
      print(errorResponse['message']);
      throw Exception('Failed to search products');
    }
  }

  Future<List<ShippingZoneModel>> fetchShippingZones(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale') ?? 'ar';
    String? token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/shipping/zones?lang=$language');
    String auth = 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    final headers = {'Content-Type': 'application/json', 'Authorization': auth,
      'gomlaauth': "Bearer $token",
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<ShippingZoneModel> zones = [];

      for (var item in data) {
        ShippingZoneModel zone = ShippingZoneModel.fromJson(item);
        List<ShippingMethodModel> methods = await fetchShippingMethods(zone.id, context);

        // Only add the zone if methods are not empty
        if (methods.isNotEmpty) {
          zones.add(zone.copyWith(methods: methods));
        }
      }

      return zones;
    } else {
      final errorResponse = json.decode(response.body);
      print(errorResponse['message']);
      throw Exception('Failed to load shipping zones');
    }
  }

  Future<List<ShippingMethodModel>> fetchShippingMethods(int zoneId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale') ?? 'ar';
    String? token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/shipping/zones/$zoneId/methods?lang=$language');
    String auth = 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    final headers = {'Content-Type': 'application/json', 'Authorization': auth,
      'gomlaauth': "Bearer $token",
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => ShippingMethodModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shipping methods');
    }
  }

  Future<List?> validateCoupon(String couponCode, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale');
    language ??= 'ar';
    final url = Uri.parse('$baseUrl/coupons?code=$couponCode&lang=$language');

    // Encoding the consumer key and secret for Basic Authentication
    String auth =
        'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': auth,
      "gomlaauth": 'Bearer ${prefs.getString('auth_token')}',
    };

    final response = await http.get(url, headers: headers);

    print('$url&consumer_key=$consumerKey&consumer_secret=$consumerSecret');

    if (response.statusCode == 200) {
      final List<dynamic> coupons = jsonDecode(response.body);
       print(coupons);
      if (coupons.isNotEmpty) {
        final coupon = coupons[0];
        print(coupon['amount']);
        if (coupon['code'] == couponCode) {
          print(couponCode);
          return [
            double.tryParse(coupon['amount']) ?? 0.0,
            coupon['discount_type']
          ];
        }
      }
      return null;
    } else {
      print(
          'Failed to fetch coupons: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
