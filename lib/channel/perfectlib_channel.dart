import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class PerfectLibConfiguration {
  final PerfectImageSource imageSource;
  final bool previewMode;
  final bool mappingMode;
  final bool developerMode;
  final String userId;
  final String configFile;
  final String modelFolder;

  const PerfectLibConfiguration({
    this.imageSource = PerfectImageSource.imageSourceFile,
    this.previewMode = false,
    this.mappingMode = false,
    this.developerMode = false,
    this.userId = "",
    this.configFile = "android/app/src/main/assets/perfectlib/config.json",
    this.modelFolder = "android/app/src/main/assets/model"
  });

  PerfectLibConfiguration build(
    PerfectImageSource? imageSource,
    bool? previewMode,
    bool? mappingMode,
    bool? developerMode,
    String? userId,
    String? configFile,
    String? modelFolder,
  ) {
    return PerfectLibConfiguration(
      imageSource: imageSource ?? this.imageSource, 
      previewMode: previewMode ?? this.previewMode, 
      mappingMode: mappingMode ?? this.mappingMode, 
      developerMode: developerMode ?? this.developerMode, 
      userId: userId ?? this.userId,
      configFile: configFile ?? this.configFile,
      modelFolder: modelFolder ?? this.modelFolder
    );
  }
}

enum PerfectImageSource {
  imageSourceFile,
  imageSourceUrl,
}

enum PerfectEffect {
  effectEyeshadow('Eyeshadow'), 
  effectEyelashes('Eyelashes'), 
  effectMascara('Mascara'), 
  effectEyeliner('Eyeliner'), 
  effectBlush('Blush'), 
  effectFoundation('Foundation'), 
  effectLipstick('Lipstick'), 
  effectLipLiner('Lipliner'), 
  effectEyeColor('EyeContact'), 
  effectEyebrow('Eyebrow'), 
  effectHighlighter('Highlighter'), 
  effectContour('Contour'), 
  effectHighlighterAndContour('HighlighterAndContour'), 
  effectHairColor('Hairdye'), 
  effectEyewear('Eyewear'),
  effectEyewear3D('Eyewear3D'),
  effectEarrings('Earrings'),
  effectBackground('Background'),
  effectBronzer('Bronzer'),
  effectConcealer('Concealer'),
  eyeshadow('Eyeshadow'),
  eyelashes('Eyelashes'),
  mascara('Mascara'),
  eyeliner('Eyeliner'),
  blush('Blush'),
  foundation('Foundation'),
  lipstick('Lipstick'),
  lipLiner('Lipliner'),
  eyeColor('EyeContact'),
  eyebrow('Eyebrow'),
  highlighter('Highlighter'),
  contour('Contour'),
  highlighterAndContour('HighlighterAndContour'),
  hairColor('Hairdye'),
  eyewear('Eyewear'),
  eyewear3D('Eyewear3D'),
  earrings('Earrings'),
  background('Background'),
  bronzer('Bronzer'),
  concealer('Concealer'),
  skinSmooth('SkinSmooth');


  const PerfectEffect(this.name);
  final String name;
}

PerfectEffect effectNameToPerfectEffect(String effect) {
  switch(effect) {
    case 'Eyeshadow' : return PerfectEffect.effectEyeshadow;
    case 'Eyelashes' : return PerfectEffect.effectEyelashes;
    case 'Mascara' : return PerfectEffect.effectMascara;
    case 'Eyeliner' : return PerfectEffect.effectEyeliner;
    case 'Blush' : return PerfectEffect.effectBlush;
    case 'Foundation' : return PerfectEffect.effectFoundation;
    case 'Lipstick' : return PerfectEffect.effectLipstick;
    case 'EyeContact' : return PerfectEffect.effectEyeColor;
    case 'Eyebrow' : return PerfectEffect.effectEyebrow;
    case 'Highlighter' : return PerfectEffect.effectHighlighter;
    case 'Contour' : return PerfectEffect.effectContour;
    case 'HighlighterAndContour' : return PerfectEffect.effectHighlighterAndContour;
    case 'Hairdye' : return PerfectEffect.effectHairColor;
    case 'Eyewear' : return PerfectEffect.effectEyewear;
    case 'Eyewear3D' : return PerfectEffect.effectEyewear3D;
    case 'Earrings' : return PerfectEffect.effectEarrings;
    case 'Background' : return PerfectEffect.effectBackground;
    case 'Bronzer' : return PerfectEffect.effectBronzer;
    case 'Concealer' : return PerfectEffect.effectConcealer;
    case 'SkinSmooth' : return PerfectEffect.skinSmooth;
    case 'Eyeshadow' : return PerfectEffect.eyeshadow;
    case 'Eyelashes' : return PerfectEffect.eyelashes;
    case 'Mascara' : return PerfectEffect.mascara;
    case 'Eyeliner' : return PerfectEffect.eyeliner;
    case 'Blush' : return PerfectEffect.blush;
    case 'Foundation' : return PerfectEffect.foundation;
    case 'Lipstick' : return PerfectEffect.lipstick;
    case 'Lipliner' : return PerfectEffect.lipLiner;
    case 'EyeContact' : return PerfectEffect.eyeColor;
    case 'Eyebrow' : return PerfectEffect.eyebrow;
    case 'Highlighter' : return PerfectEffect.highlighter;
    case 'Contour' : return PerfectEffect.contour;
    case 'HighlighterAndContour' : return PerfectEffect.highlighterAndContour;
    case 'Hairdye' : return PerfectEffect.hairColor;
    case 'Eyewear' : return PerfectEffect.eyewear;
    case 'Eyewear3D' : return PerfectEffect.eyewear3D;
    case 'Earrings' : return PerfectEffect.earrings;
    case 'Background' : return PerfectEffect.background;
    case 'Bronzer' : return PerfectEffect.bronzer;
    case 'Concealer' : return PerfectEffect.concealer;
    case 'SkinSmooth' : return PerfectEffect.skinSmooth;
    default:
      throw Exception('Invalid perfect effect name: $effect');
  }
}

class PerfectLibChannel {
  late MethodChannel _methodChannel;
  Function(String)? onError;

  PerfectLibChannel() {
    _methodChannel =  const MethodChannel('PerfectLibMethodChannel');
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

  Future<bool> init(PerfectLibConfiguration configuration) async {
      // Send the configuration in Map format
      var params = {
        "imageSource" : configuration.imageSource.index,
        "previewMode" : configuration.previewMode,
        "mappingMode" : configuration.mappingMode,
        "developerMode" : configuration.developerMode,
        "userId" : configuration.userId,
        "configFile" : configuration.configFile,
        "modelFolder" : configuration.modelFolder
      };

      var isSuccess = await _safeInvokeMethod<bool>('init', params);
      if (isSuccess == null) {
        return false;
      }
      return isSuccess;
  }

  Future<void> setCountryCode(String code) async {
    await _safeInvokeMethod<void>('setCountryCode', {'countryCode' : code});
  }

  Future<void> setLocaleCode(String code) async {
    await _safeInvokeMethod<void>('setLocaleCode', {'localeCode' : code});
  }

  Future<String> getCountryCode() async {
    var code = await _safeInvokeMethod<String>('getCountryCode');
    if (code == null) {
      return "";
    }
    return code;
  }

  Future<String> getLocaleCode() async {
    var code = await _safeInvokeMethod<String>('getLocaleCode');
    if (code == null) {
      return "";
    }
    return code;
  }

  Future<void> unload() async {
    await _safeInvokeMethod<void>('unload');
  }
}

