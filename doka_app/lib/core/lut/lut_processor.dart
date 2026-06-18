import 'dart:typed_data';

class LutProcessor {
  final List<double>? _lutData;
  final int _lutSize;

  LutProcessor(this._lutData, {int lutSize = 33}) : _lutSize = lutSize;

  bool get isValid => _lutData != null && _lutData.isNotEmpty;

  /// Apply LUT to raw RGBA pixel data.
  Uint8List apply(Uint8List rgba, {double strength = 1.0}) {
    if (!isValid) return rgba;
    final result = Uint8List(rgba.length);
    for (int i = 0; i < rgba.length; i += 4) {
      final r = rgba[i] / 255.0;
      final g = rgba[i + 1] / 255.0;
      final b = rgba[i + 2] / 255.0;
      final tr = _sample(r, g, b, 0);
      final tg = _sample(r, g, b, 1);
      final tb = _sample(r, g, b, 2);
      if (strength < 1.0) {
        result[i] = (r + (tr - r) * strength).clamp(0.0, 1.0) as int? ?? 0;
        result[i + 1] = (g + (tg - g) * strength).clamp(0.0, 1.0) as int? ?? 0;
        result[i + 2] = (b + (tb - b) * strength).clamp(0.0, 1.0) as int? ?? 0;
      } else {
        result[i] = (tr * 255).round().clamp(0, 255);
        result[i + 1] = (tg * 255).round().clamp(0, 255);
        result[i + 2] = (tb * 255).round().clamp(0, 255);
      }
      result[i + 3] = rgba[i + 3];
    }
    return result;
  }

  double _sample(double r, double g, double b, int channel) {
    final ri = (r * (_lutSize - 1)).round();
    final gi = (g * (_lutSize - 1)).round();
    final bi = (b * (_lutSize - 1)).round();
    final idx = ((bi * _lutSize + gi) * _lutSize + ri) * 3 + channel;
    if (idx >= _lutData!.length) return 0.0;
    return _lutData![idx];
  }
}

