import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/banner.dart';

class BannerService {
  static const String apiUrl = 'https://gomla.sa/wp-json/banner-slider/v1/banners';

  Future<List<Bannerr>> fetchBanners() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Response Body: ${response.body}');  // Log the raw response body

      return data.map((json) => Bannerr.fromJson(json)).toList();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load banners');
    }
  }
}
