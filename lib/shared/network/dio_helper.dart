import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class DioHelper {
  static Dio? dio;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<
      NavigatorState>();

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: '',
        receiveDataWhenStatusError: true,
      ),
    );
    dio!.interceptors.add(DioLogger());

  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      return await dio!.get(
        url,
        queryParameters: query,
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }static Future<Response> postData({
    required String url,
    dynamic data,  // Allow dynamic types like FormData or Map
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      dio!.options.headers['Content-Type'] = 'application/x-www-form-urlencoded'; // Set the correct content type
      return await dio!.post(
        url,
        queryParameters: query,
        data: data,  // This can be either FormData or Map
      );
    } on DioError catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data.toString());
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Response> putData({
    required String url,
    required  Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      dio!.options.headers['Content-Type'] = 'application/json';
      return await dio!.put(
        url,
        queryParameters: query,
        data: data,
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      dio!.options.headers['Content-Type'] = 'application/json';
      return await dio!.patch(
        url,
        queryParameters: query,
        data: data,
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      return await dio!.delete(
        url,
        queryParameters: query,
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<Response> uploadFile({
    required String url,
    required File file,
    String? token,
  }) async {
    try {
      if (token != null) {
        dio!.options.headers['Authorization'] = 'Bearer $token';
      }
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      return await dio!.post(
        url,
        data: formData,
      );
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

}

class DioLogger extends Interceptor {
  // ANSI Color Codes
  final String resetColor = '\x1B[0m';
  final String redColor = '\x1B[31m';
  final String greenColor = '\x1B[32m';
  final String yellowColor = '\x1B[33m';
  final String blueColor = '\x1B[34m';
  final String magentaColor = '\x1B[35m';
  final String cyanColor = '\x1B[36m';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(cyanColor + '--- Request ---' + resetColor);
    print(blueColor + 'Method: ${options.method}' + resetColor);
    print(blueColor + 'URL: ${options.uri}' + resetColor);
    print(yellowColor + 'Headers: ' + resetColor + jsonEncode(options.headers));
    print(yellowColor + 'Query Parameters: ' + resetColor + jsonEncode(options.queryParameters));

    if (options.data != null) {
      print(yellowColor + 'Data: ' + resetColor + prettyPrintJson(options.data));
    }

    print(cyanColor + '======================================' + resetColor);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(greenColor + '--- Response ---' + resetColor);
    print(magentaColor + 'Status Code: ${response.statusCode}' + resetColor);

    // Use printLongString to handle large responses
    printLongString(greenColor + 'Response Data: ' + resetColor + prettyPrintJson(response.data));

    print(greenColor + '======================================' + resetColor);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(redColor + '--- Error ---' + resetColor);
    print(redColor + 'Error: ${err.message}' + resetColor);
    if (err.response != null) {
      print(redColor + 'Status Code: ${err.response?.statusCode}' + resetColor);
      printLongString(redColor + 'Response Data: ' + resetColor + prettyPrintJson(err.response?.data));
    }
    print(redColor + '======================================' + resetColor);
    super.onError(err, handler);
  }

  /// Helper method to pretty print JSON data with indentation
  String prettyPrintJson(dynamic json) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  /// Helper method to print large strings in chunks to avoid truncation
  void printLongString(String text) {
    const int chunkSize = 20480;
    for (var i = 0; i < text.length; i += chunkSize) {
      print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }
}
