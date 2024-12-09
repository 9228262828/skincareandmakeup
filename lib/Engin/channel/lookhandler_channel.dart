import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LookHandler {
  late MethodChannel _methodChannel;
  Function(String)? onError;
  Function(String)? onProgress;

  LookHandler() {
    _methodChannel = const MethodChannel('PerfectSDKLookHandlerMethodChannel');
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
      var needToUpdate = await _safeInvokeMethod<bool>('checkNeedUpdate');
      if (needToUpdate == null) {
        return false;
      }
      return needToUpdate;
  }

  Future<bool> syncServer() async {
    var isSuccess = await _safeInvokeMethod<bool>('syncServer');
    if (isSuccess == null) {
        return false;
      }
      return isSuccess;
  }

  Future<List> getList() async {
    var list = await _safeInvokeMethod<List>('getList');
    if (list == null) {
      return List.empty();
    }
    print("list: $list");
    return [...list];
  }

  Future<List> downloadLook(List<String> lookGuids) async  {
    var list = await _safeInvokeMethod<List>('downloadLook', {'lookGuids' : lookGuids});
    if (list == null) {
      return List.empty();
    }
    return [...list];
  }

  Future<void> clear() async {
    await _safeInvokeMethod<void>('clear');
  }

  Future<void> dispose() async {
    await _safeInvokeMethod<void>('dispose');
  }
}