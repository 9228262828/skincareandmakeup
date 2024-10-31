import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/utility.dart';

class SkincareViewChannel {
  late MethodChannel _methodChannel;
  Function(Map)? onCheckResult;
  Function(Image)? onCaptureImage;
  Function(String)? onError;

  SkincareViewChannel(int id) {
    _methodChannel =  MethodChannel('PerfectSDKSkinCareView/$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'error':
        String error = call.arguments as String;
        if (onError != null) {
          onError!(error);
        }
        break;
      case 'onCheckResult':
        Map result = call.arguments as Map;
        if (onCheckResult != null) {
          onCheckResult!(result);
        }
        break;
      case 'image':
        String base64Data = call.arguments as String;
        if (onCaptureImage != null) {
          Utility.base64ToImage(base64Data).then((image) => {
            onCaptureImage!(image!)
          });
        }
    }
  }

  Future<T?> _safeInvokeMethod<T>(String methodName, [Map<String, dynamic>? params]) async {
    try {
      return await _methodChannel.invokeMethod(methodName, {...?params});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<void> takePicture() async {
      await _safeInvokeMethod<void>('takePicture');
  }

  Future<void> start() async {
    await _safeInvokeMethod<void>('start');
  }

  Future<void> stop() async {
    await _safeInvokeMethod<void>('stop');
  }

  Future<void> pause() async {
    await _safeInvokeMethod<void>('pause');
  }

  Future<void> resume() async {
    await _safeInvokeMethod<void>('resume');
  }

  Future<bool> analyzeImage(Image image) async {
    final success = await _safeInvokeMethod<bool>('analyzeImage', {"image": await Utility.imageToBase64(image)});
    if (success == null) {
      return false;
    }
    return success;
  }

  Future<List<String>> getAvailableFeatures() async {
    List? features = await _safeInvokeMethod<List>('getAvailableFeatures');
    if (features == null) {
      return List.empty();
    }
    return [...features];
  }

  Future<Map<String, String>> getOverallScore() async {
    Map<dynamic,dynamic>? scores = await _safeInvokeMethod<Map<dynamic,dynamic>>('getOverallScore');
    if (scores == null) {
      return {};
    }
    return Utility.convertMap(scores);
  }

  Future<Map<String, String>> getReports() async {
    Map<dynamic,dynamic>? reports = await _safeInvokeMethod<Map<dynamic,dynamic>>('getReports');
    if (reports == null) {
      return {};
    }
    return Utility.convertMap(reports);
  }

  Future<Map<String, String>> getSkinTypes() async {
    Map<dynamic,dynamic>? skinTypes = await _safeInvokeMethod<Map<dynamic,dynamic>>('getSkinTypes');
    if (skinTypes == null) {
      return {};
    }
    return Utility.convertMap(skinTypes);
  }

  Future<Image?> getAnalyzedImage(List<String> features) async {
    final base64Data = await _safeInvokeMethod<String?>('getAnalyzedImage', {"features": features});
    if (base64Data == null) {
      return null;
    }
    return Utility.base64ToImage(base64Data);
  }

  Future<Image?> getSkinTypeAnalyzedImage() async {
    final base64Data = await _safeInvokeMethod<String?>('getSkinTypeAnalyzedImage');
    if (base64Data == null) {
      return null;
    }
    return Utility.base64ToImage(base64Data);
  }

  Future<void> dispose() async {
    await _safeInvokeMethod<void>('dispose');
  }
}

