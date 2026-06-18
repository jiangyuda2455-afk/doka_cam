
import '../../models/filter_preset.dart';

class LutGenerator {
  static const int lutSize = 33;

  /// Generate 3D LUT data for a given filter preset.
  /// Returns a flat array of [R, G, B, R, G, B, ...] values (0.0-1.0).
  static List<double> generate(FilterPreset filter) {
    final data = List<double>.filled(lutSize * lutSize * lutSize * 3, 0.0);
    int idx = 0;
    for (int b = 0; b < lutSize; b++) {
      for (int g = 0; g < lutSize; g++) {
        for (int r = 0; r < lutSize; r++) {
          double rn = r / (lutSize - 1);
          double gn = g / (lutSize - 1);
          double bn = b / (lutSize - 1);

          final tr = _transform(filter, rn, gn, bn, 0);
          final tg = _transform(filter, rn, gn, bn, 1);
          final tb = _transform(filter, rn, gn, bn, 2);

          data[idx++] = tr.clamp(0.0, 1.0);
          data[idx++] = tg.clamp(0.0, 1.0);
          data[idx++] = tb.clamp(0.0, 1.0);
        }
      }
    }
    return data;
  }

  static double _transform(FilterPreset filter, double r, double g, double b, int channel) {
    switch (filter.name) {
      case 'fuji_pro_400h': return _fujiPro400H(r, g, b, channel);
      case 'fuji_classic_chrome': return _fujiClassicChrome(r, g, b, channel);
      case 'kodak_portra_160': return _kodakPortra160(r, g, b, channel);
      case 'kodak_portra_400': return _kodakPortra400(r, g, b, channel);
      case 'kodak_gold': return _kodakGold(r, g, b, channel);
      case 'agfa_vista': return _agfaVista(r, g, b, channel);
      case 'bw_classic': return _bwClassic(r, g, b, channel);
      case 'expired_film': return _expiredFilm(r, g, b, channel);
      default: return [r, g, b][channel];
    }
  }

  // Fuji Pro 400H: warm skin tones, soft contrast, green shadows
  static double _fujiPro400H(double r, double g, double b, int ch) {
    final contrast = 0.85;
    final warm = 1.08;
    final greenShadow = 0.95;
    switch (ch) {
      case 0: return _contrast(r * warm, contrast);
      case 1: return _contrast(g, contrast) * (g < 0.4 ? greenShadow : 1.0);
      case 2: return _contrast(b * 0.92, contrast);
      default: return 0.0;
    }
  }

  // Fuji Classic Chrome: muted shadows, warm midtones, cool highlights
  static double _fujiClassicChrome(double r, double g, double b, int ch) {
    final contrast = 0.75;
    final shadowWarm = 1.05;
    final highlightCool = 0.9;
    switch (ch) {
      case 0: return _contrast(r * shadowWarm, contrast);
      case 1: return _contrast(g * 0.95, contrast);
      case 2: return _contrast(b, contrast) * (b > 0.5 ? highlightCool : 1.0);
      default: return 0.0;
    }
  }

  // Kodak Portra 160: warm golden highlights, soft skin
  static double _kodakPortra160(double r, double g, double b, int ch) {
    final contrast = 0.8;
    final warm = 1.06;
    final saturation = 0.9;
    switch (ch) {
      case 0: return _contrast(r * warm, contrast);
      case 1: return _contrast(g * saturation, contrast);
      case 2: return _contrast(b * 0.88, contrast);
      default: return 0.0;
    }
  }

  // Kodak Portra 400: slightly more contrast than 160, warm
  static double _kodakPortra400(double r, double g, double b, int ch) {
    final contrast = 0.88;
    final warm = 1.04;
    switch (ch) {
      case 0: return _contrast(r * warm, contrast);
      case 1: return _contrast(g * 0.93, contrast);
      case 2: return _contrast(b * 0.85, contrast);
      default: return 0.0;
    }
  }

  // Kodak Gold: vibrant, warm yellows and greens
  static double _kodakGold(double r, double g, double b, int ch) {
    final contrast = 0.9;
    final sat = 1.15;
    switch (ch) {
      case 0: return _contrast(r * sat, contrast);
      case 1: return _contrast(g * sat * 1.1, contrast);
      case 2: return _contrast(b * 0.9, contrast);
      default: return 0.0;
    }
  }

  // Agfa Vista: punchy greens, cool blues
  static double _agfaVista(double r, double g, double b, int ch) {
    final contrast = 0.95;
    final greenBoost = 1.12;
    final blueBoost = 1.08;
    switch (ch) {
      case 0: return _contrast(r * 0.98, contrast);
      case 1: return _contrast(g * greenBoost, contrast);
      case 2: return _contrast(b * blueBoost, contrast);
      default: return 0.0;
    }
  }

  // Black & White Classic: desaturate, increase contrast
  static double _bwClassic(double r, double g, double b, int ch) {
    final luminance = r * 0.299 + g * 0.587 + b * 0.114;
    final contrast = 1.1;
    final result = _contrast(luminance, contrast);
    return result;
  }

  // Expired Film: faded, color-shifted, low contrast
  static double _expiredFilm(double r, double g, double b, int ch) {
    final contrast = 0.7;
    final fade = 0.15;
    final shiftR = 1.03;
    final shiftB = 1.08;
    switch (ch) {
      case 0: return _contrast(r * shiftR, contrast) * (1 - fade) + fade;
      case 1: return _contrast(g, contrast) * (1 - fade) + fade;
      case 2: return _contrast(b * shiftB, contrast) * (1 - fade) + fade;
      default: return 0.0;
    }
  }

  static double _contrast(double value, double amount) {
    return (value - 0.5) * amount + 0.5;
  }
}

