import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:skincare/channel/perfectlib_channel.dart';

class VtoSetting {
  final String productGuid;
  final String skuGuid;
  final String patternGuid;
  final String paletteGuid;
  final String wearingStyleGuid;

  const VtoSetting({
    this.productGuid = "",
    this.skuGuid = "",
    this.patternGuid = "",
    this.paletteGuid = "",
    this.wearingStyleGuid = "",
  });

  VtoSetting create(
   String? productGuid,
   String? skuGuid,
   String? patternGuid,
   String? paletteGuid,
   String? wearingStyleGuid
  ) {
    return VtoSetting(
      productGuid: productGuid ?? this.productGuid, 
      skuGuid: skuGuid ?? this.skuGuid, 
      patternGuid: patternGuid ?? this.patternGuid, 
      paletteGuid: paletteGuid ?? this.paletteGuid, 
      wearingStyleGuid: wearingStyleGuid ?? this.wearingStyleGuid,
    );
  }
}

class MakeupCamViewChannel {
  late MethodChannel _methodChannel;
  Function(String)? onError;
  Function(String)? onProgress;

  MakeupCamViewChannel(int id) {
    _methodChannel = MethodChannel('PerfectSDKMakeupCamView/$id');
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
    }
  }

  Future<T?> _safeInvokeMethod<T>(String methodName, [Map<dynamic, dynamic>? params]) async {
    try {
      return await _methodChannel.invokeMethod(methodName, {...?params});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<String?> takePicture() async {
      final base64Data = await _safeInvokeMethod<String?>('takePicture');
      if (base64Data == null) {
        return null;
      }
      return base64Data;
  }

  Future<void> startCamera() async {
    await _safeInvokeMethod<void>('startCamera');
  }

  Future<void> apply(VtoSetting setting) async {
    // Send the VtoSetting in Map format
    var params = {
      "product" : setting.productGuid,
      "sku" : setting.skuGuid,
      "palette" : setting.paletteGuid,
      "pattern" : setting.patternGuid,
      "wearingStyle" : setting.wearingStyleGuid,
    };
    await _safeInvokeMethod<void>('apply', params);
  }

  Future<void> applyLook(String lookGuid) async {
    await _safeInvokeMethod<void>('applyLook', {"lookGuid" : lookGuid});
  }

  Future<void> getProductIds() async {
    await _safeInvokeMethod<void>('getProductIds');
  }

  Future<Map> getIntensities() async {
    var map = await _safeInvokeMethod<Map>('getIntensities');
    if (map == null) {
      return {};
    }
    return map;
  }

  Future<void> setIntensities(Map intensities) async {
    await _safeInvokeMethod<void>('setIntensities', intensities);
  }

  Future<void> clear(PerfectEffect effect) async {
    await _safeInvokeMethod<void>('clear', {'effect' : effect.name});
  }

  Future<void> clearAllEffects() async {
    await _safeInvokeMethod<void>('clearAllEffects');
  }

  Future<void> dispose() async {
    await _safeInvokeMethod<void>('dispose');
  }
}