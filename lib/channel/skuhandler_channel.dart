import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:skincare/channel/perfectlib_channel.dart';

class SkuHandler {
  late MethodChannel _methodChannel;
  Function(Map)? onReturn;
  Function(String)? onError;
  Function(String)? onProgress;

  SkuHandler() {
    _methodChannel = const MethodChannel('PerfectSDKSkuHandlerMethodChannel');
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
      case 'progress':
        String progress = call.arguments as String;
        if (onProgress != null) {
          onProgress!(progress);
        }
        break;
      case 'onReturn':
        Map result = call.arguments as Map;
        if (onReturn != null) {
          onReturn!(result);
        }
        break;
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

  Future<bool> checkNeedUpdate() async {
    var needUpdate = await _safeInvokeMethod<bool>('checkNeedUpdate');
    if (needUpdate == null) {
      return false;
    }
    return needUpdate;
  }

  Future<bool> syncServer() async {
    var isSuccess = await _safeInvokeMethod<bool>('syncServer');
    if (isSuccess == null) {
      return false;
    }
    return isSuccess;
  }

  Future<List> getList(PerfectEffect effect) async {
    var list = await _safeInvokeMethod<List>('getList', {'effect' : effect.name});
    if (list == null) {
      return List.empty();
    }
    return [...list];
  }

  Future<List> getSkus(String productGuid) async {
    var skus = await _safeInvokeMethod<List>('getSkus', {'productGuid' : productGuid});
    if (skus == null) {
      return List.empty();
    }
    return [...skus];
  }

  Future<List> getWearingStyles(String skuGuid, String? wearingStyle) async {
    var params = {'skuGuid': skuGuid};
    if (wearingStyle != null) {
      params['wearingStyleGuid'] = wearingStyle;
    }

    var wearingStyles = await _safeInvokeMethod<List>('getWearingStyles', params);
    if (wearingStyles == null) {
      return List.empty();
    }
    return [...wearingStyles];
  }

  Future<List> getPalettes(String skuGuid, String? patternGuid) async {
    var params = {'skuGuid': skuGuid};
    if (patternGuid != null) {
      params['patternGuid'] = patternGuid;
    }

    var palettes = await _safeInvokeMethod<List>('getPalettes', params);
    if (palettes == null) {
      return List.empty();
    }
    return [...palettes];
  }

  Future<List> getPatterns(String skuGuid, String? paletteGuid) async {
    var params = {'skuGuid': skuGuid};
    if (paletteGuid != null) {
      params['paletteGuid'] = paletteGuid;
    }

    var patterns = await _safeInvokeMethod<List>('getPatterns', params);
    if (patterns == null) {
      return List.empty();
    }
    return [...patterns];
  }

  Future<void> clear() async {
    await _safeInvokeMethod<void>('clear');
  }

  Future<void> dispose() async {
    await _safeInvokeMethod<void>('dispose');
  }
}