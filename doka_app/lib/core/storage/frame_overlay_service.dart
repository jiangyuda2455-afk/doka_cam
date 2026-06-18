import 'dart:io';
import 'package:image/image.dart' as img;

enum FrameStyle { polaroid, classicFilm, thinFrame }

class FrameOverlayService {
  Future<String> applyFrame({
    required String inputPath,
    required String outputPath,
    FrameStyle style = FrameStyle.polaroid,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) return inputPath;

    img.Image result;
    switch (style) {
      case FrameStyle.polaroid:
        result = _polaroidFrame(src);
        break;
      case FrameStyle.classicFilm:
        result = _classicFilmFrame(src);
        break;
      case FrameStyle.thinFrame:
        result = _thinFrame(src);
        break;
    }

    final jpeg = img.encodeJpg(result, quality: 92);
    await File(outputPath).writeAsBytes(jpeg);
    return outputPath;
  }

  img.Image _polaroidFrame(img.Image src) {
    final border = (src.width * 0.05).round();
    final bottomExtra = (src.width * 0.15).round();
    final out = img.Image(
      width: src.width + border * 2,
      height: src.height + border * 2 + bottomExtra,
    );
    img.fill(out, color: img.ColorRgba8(255, 255, 255, 255));
    img.compositeImage(out, src, dstX: border, dstY: border);
    // Add a subtle shadow below the photo area
    for (int x = border; x < out.width - border; x++) {
      for (int y = src.height + border; y < src.height + border + 4; y++) {
        if (y < out.height) {
          out.setPixelRgba(x, y, 200, 200, 200, 255);
        }
      }
    }
    return out;
  }

  img.Image _classicFilmFrame(img.Image src) {
    final border = (src.width * 0.04).round();
    final out = img.Image(
      width: src.width + border * 2,
      height: src.height + border * 2,
    );
    img.fill(out, color: img.ColorRgba8(20, 20, 20, 255));
    // Rounded corners effect
    img.compositeImage(out, src, dstX: border, dstY: border);
    return out;
  }

  img.Image _thinFrame(img.Image src) {
    final outer = (src.width * 0.03).round();
    final inner = (src.width * 0.02).round();
    final margin = outer + inner;
    final out = img.Image(
      width: src.width + margin * 2,
      height: src.height + margin * 2,
    );
    // Outer dark border
    img.fill(out, color: img.ColorRgba8(40, 40, 40, 255));
    // Inner white mat
    for (int y = outer; y < out.height - outer; y++) {
      for (int x = outer; x < out.width - outer; x++) {
        out.setPixelRgba(x, y, 240, 240, 240, 255);
      }
    }
    img.compositeImage(out, src, dstX: margin, dstY: margin);
    return out;
  }
}
