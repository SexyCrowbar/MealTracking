import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../core/constants.dart';

class ImagePrep {
  const ImagePrep._();

  /// Reads the file, decodes, resizes to max dimension based on quality
  /// setting, strips metadata (EXIF/GPS) by re-encoding to JPEG.
  static Future<Uint8List> prepareForUpload({
    required File file,
    String quality = PhotoQuality.medium,
    int jpegQuality = 85,
  }) async {
    final bytes = await file.readAsBytes();
    final maxDim = PhotoQuality.pxFor(quality);
    return prepareBytes(bytes, maxDim: maxDim, jpegQuality: jpegQuality);
  }

  static Uint8List prepareBytes(
    Uint8List bytes, {
    required int maxDim,
    int jpegQuality = 85,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode image');
    }
    img.Image working = decoded;
    final w = decoded.width;
    final h = decoded.height;
    if (w > maxDim || h > maxDim) {
      if (w >= h) {
        working = img.copyResize(decoded, width: maxDim, interpolation: img.Interpolation.average);
      } else {
        working = img.copyResize(decoded, height: maxDim, interpolation: img.Interpolation.average);
      }
    }
    // encodeJpg drops EXIF metadata in this package, providing privacy.
    return Uint8List.fromList(img.encodeJpg(working, quality: jpegQuality));
  }
}
