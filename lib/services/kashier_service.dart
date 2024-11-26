import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // Add this dependency to generate the hash

class KashierService {
  final String apiKey = 'YOUR_API_KEY';
  final String baseUrl = 'https://test-fep.kashier.io/v3/orders/';
  final String merchantId = 'MID-23153-205'; // Your merchant ID

  Future<String?> initiatePayment({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String securityCode,
    required String merchantOrderId,
  }) async {
    final url = Uri.parse(baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Kashier-Hash': _generateHash(amount, merchantOrderId),
    };
    final body = jsonEncode({
      "apiOperation": "PAY",
      "paymentMethod": {
        "type": "CARD",
        "card": {
          "save": true,
          "expiry": {
            "month": expiryMonth,
            "year": expiryYear,
          },
          "number": cardNumber,
          "nameOnCard": "$firstName $lastName",
          "securityCode": securityCode,
        },
      },
      "order": {
        "reference": merchantOrderId,
        "amount": amount.toString(),
        "currency": "EGP",
        "description": "",
      },
      "interactionSource": "ECOMMERCE",
      "reconciliation": {
        "webhookUrl": "https://your-call-back-url.com",
        "merchantRedirect": "https://your-call-back-url.com",
        "redirect": true,
      },
      "customer": {
        "reference": "24",
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
      },
      "merchantId": merchantId,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['paymentMethod']['card']['cardToken']; // Assuming cardToken is returned in response
    } else {
      print('Payment initiation failed: ${response.body}');
      return null;
    }
  }

  Future<bool> confirmPayment({
    required String cardToken,
    required String securityCode,
    required double amount,
    required String merchantOrderId,
    required String shopperReference,
  }) async {
    final url = Uri.parse(baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Kashier-Hash': _generateHash(amount, merchantOrderId),
    };
    final body = jsonEncode({
      "apiOperation": "PAY",
      "paymentMethod": {
        "type": "CARD",
        "card": {
          "cardToken": cardToken,
          "securityCode": securityCode,
        },
      },
      "order": {
        "reference": merchantOrderId,
        "amount": amount.toString(),
        "currency": "EGP",
        "description": "",
      },
      "customer": {
        "reference": shopperReference,
      },
      "interactionSource": "ECOMMERCE",
      "reconciliation": {
        "webhookUrl": "https://your-call-back-url.com",
        "merchantRedirect": "https://your-call-back-url.com",
        "redirect": true,
      },
      "merchantId": merchantId,
      "timestamp": DateTime.now().toIso8601String(), // Ensure you use the correct timestamp format
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Payment confirmation failed: ${response.body}');
      return false;
    }
  }

  String _generateHash(double amount, String merchantOrderId) {
    final data = '$amount$merchantOrderId$merchantId';
    return sha256.convert(utf8.encode(data)).toString();
  }
}
