import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect, Size;
import 'package:image/image.dart' as img;
import '../lut/lut_processor.dart';

class FilterService {
  Future<String> applyFilter({
    required String inputPath,
    required String outputPath,
    required LutProcessor lutProcessor,
    double strength = 1.0,
    Rect? faceRect,
    Size? imageSize,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    final pixels = Uint8List.fromList(image.getBytes());
    final filtered = lutProcessor.apply(pixels, strength: strength);

    if (faceRect != null && imageSize != null) {
      _applyFaceProtection(filtered, faceRect, imageSize, image.width, image.height, pixels);
    }

    final result = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: filtered.buffer,
      numChannels: 4,
    );
    final jpeg = img.encodeJpg(result, quality: 95);
    await File(outputPath).writeAsBytes(jpeg);
    return outputPath;
  }

  void _applyFaceProtection(Uint8List filtered, Rect faceRect, Size imgSize, int w, int h, Uint8List original) {
    final fx = (faceRect.left / imgSize.width * w).round();
    final fy = (faceRect.top / imgSize.height * h).round();
    final fw = (faceRect.width / imgSize.width * w).round();
    final fh = (faceRect.height / imgSize.height * h).round();
    final margin = (fw * 0.2).round();
    final x0 = (fx - margin).clamp(0, w);
    final y0 = (fy - margin).clamp(0, h);
    final x1 = (fx + fw + margin).clamp(0, w);
    final y1 = (fy + fh + margin).clamp(0, h);

    for (int y = y0; y < y1; y++) {
      final row = y * w * 4;
      for (int x = x0; x < x1; x++) {
        final i = row + x * 4;
        filtered[i] = (original[i] * 0.5 + filtered[i] * 0.5).round().clamp(0, 255);
        filtered[i + 1] = (original[i + 1] * 0.5 + filtered[i + 1] * 0.5).round().clamp(0, 255);
        filtered[i + 2] = (original[i + 2] * 0.5 + filtered[i + 2] * 0.5).round().clamp(0, 255);
      }
    }
  }
}
