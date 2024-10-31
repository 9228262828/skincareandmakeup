import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:flutter/material.dart';

class Utility {
  static Future<Image> resizeImage(Image image, double maxSize) async {
    final completer = Completer<ImageInfo>();

    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));

    final byteData = await completer.future
        .then((info) => info.image.toByteData(format: ui.ImageByteFormat.png));
    final bytes = byteData!.buffer.asUint8List();
    final imageSize = await getImageSize(bytes);

    final horizontalRatio = maxSize / imageSize.width;
    final verticalRatio = maxSize / imageSize.height;
    var ratio = min(horizontalRatio, verticalRatio);

    if (ratio >= 1.0) {
      ratio = 1.0;
    }

    int newWidth = (imageSize.width * ratio).round();
    int newHeight = (imageSize.height * ratio).round();

    return Image(
        image: ResizeImage(MemoryImage(bytes),
            width: newWidth, height: newHeight));
  }

  // Function to get the image dimensions
  static Future<Size> getImageSize(Uint8List imageBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return Size(
      frameInfo.image.width.toDouble(),
      frameInfo.image.height.toDouble(),
    );
  }

  static Future<String> imageToBase64(Image image) async {
    final completer = Completer<ImageInfo>();

    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));

    final byteData = await completer.future
        .then((info) => info.image.toByteData(format: ui.ImageByteFormat.png));
    final bytes = byteData!.buffer.asUint8List();
    final base64String = base64Encode(bytes);

    return base64String;
  }

  static Future<Image?> base64ToImage(String base64String) async {
    Base64Codec base64 = const Base64Codec();
    String newBase64String = base64.normalize(base64String);
    Uint8List bytes = base64.decode(newBase64String);
    return Image(image: MemoryImage(bytes));
  }

  static Map<String, String> convertMap(Map<dynamic, dynamic> originalMap) {
    Map<String, String> result = {};

    originalMap.forEach((key, value) {
      if (key is String && value is String) {
        result[key] = value;
      }
    });

    return result;
  }

  static Uint8List base64ToBytes(String base64String) {
    Base64Codec base64 = const Base64Codec();
    String newBase64String = base64.normalize(base64String);
    return base64.decode(newBase64String);
  }

  static Future<bool> saveImageToGallery(ui.Image image) async {
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return false;
    Map? result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List(), quality: 100);
    return result?['isSuccess'];
  }
}
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}